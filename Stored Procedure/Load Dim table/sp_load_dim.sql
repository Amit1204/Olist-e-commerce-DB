CREATE PROCEDURE ETL_Load_Dim_PaymentType
AS
BEGIN
    SET NOCOUNT ON;

    -- Insert new payment types from staging into the dimension table
    -- This is a simple lookup load
    INSERT INTO dim_payment_type (payment_type_name)
    SELECT DISTINCT payment_type FROM stg_payment_type
    WHERE payment_type NOT IN (SELECT payment_type_name FROM dim_payment_type);
    
    PRINT 'Updated dim_payment_type.';

END;
GO

CREATE PROCEDURE ETL_Load_Dim_OrderStatus
AS
BEGIN
    SET NOCOUNT ON;

    -- Insert new order statuses from staging into the dimension table
    -- This is a simple lookup load
    INSERT INTO dim_order_status (status_name)
    SELECT DISTINCT status FROM stg_order_status
    WHERE status NOT IN (SELECT status_name FROM dim_order_status);
    
    PRINT 'Updated dim_order_status.';

END;
GO

CREATE PROCEDURE ETL_Load_Dim_Seller
AS
BEGIN
    SET NOCOUNT ON;

    -- SCD Type 1: Only insert new sellers. 
    -- Join Staging data to compile the full location details
    INSERT INTO dim_seller (seller_id, seller_zip_code, seller_city, seller_state)
    SELECT
        S.seller_id,
        A.zip_code_prefix,
        Cy.city,
        St.state
    FROM stg_seller AS S
    INNER JOIN stg_address AS A ON S.address_id = A.address_id
    INNER JOIN stg_city AS Cy ON A.city_id = Cy.city_id
    INNER JOIN stg_state AS St ON A.state_id = St.state_id
    WHERE S.seller_id NOT IN (SELECT seller_id FROM dim_seller);
    
    PRINT 'Updated dim_seller.';

END;
GO

CREATE PROCEDURE ETL_Load_Dim_Product
AS
BEGIN
    SET NOCOUNT ON;

    -- SCD Type 1: Only insert new products.
    -- Join Staging product and category tables
    INSERT INTO dim_product (product_id, product_category_name, product_weight_g, product_length_cm, product_height_cm, product_width_cm)
    SELECT
        P.product_id,
        PC.product_category_name,
        P.product_weight_g,
        P.product_length_cm,
        P.product_height_cm,
        P.product_width_cm
    FROM stg_product AS P
    INNER JOIN stg_product_category AS PC ON P.product_category_id = PC.product_category_id
    WHERE P.product_id NOT IN (SELECT product_id FROM dim_product);
    
    PRINT 'Updated dim_product.';

END;
Go

CREATE OR ALTER PROCEDURE ETL_Load_Dim_Customer
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ETL_RUN_DATE DATETIME = GETDATE();


    SELECT 
        C.customer_id, 
        CAST(A.zip_code_prefix AS VARCHAR(20)) AS zip_code_prefix,
        Cy.city, 
        St.state
    INTO #CustomerSource
    FROM stg_customer AS C

    INNER JOIN stg_address AS A ON CAST(C.address_id AS INT) = A.address_id 
    INNER JOIN stg_city AS Cy ON A.city_id = Cy.city_id
    INNER JOIN stg_state AS St ON A.state_id = St.state_id;


    UPDATE T
    SET 
        T.is_current = 0,
        T.end_date = @ETL_RUN_DATE
    FROM dim_customer AS T

    INNER JOIN #CustomerSource AS Source 
        ON T.customer_id = Source.customer_id
    WHERE T.is_current = 1 
      AND (
          T.customer_zip_code <> Source.zip_code_prefix OR
          T.customer_city <> Source.city OR
          T.customer_state <> Source.state
      );


    INSERT INTO dim_customer (
        customer_id, 
        customer_zip_code, 
        customer_city, 
        customer_state, 
        effective_date, 
        is_current
    )
    SELECT 
        Source.customer_id,
        Source.zip_code_prefix,
        Source.city,
        Source.state,
        @ETL_RUN_DATE AS effective_date,
        1 AS is_current
    FROM #CustomerSource AS Source 
    LEFT JOIN dim_customer AS T 
        ON Source.customer_id = T.customer_id 
        AND T.is_current = 1

        AND T.customer_zip_code = Source.zip_code_prefix 
        AND T.customer_city = Source.city
        AND T.customer_state = Source.state
    WHERE T.customer_key IS NULL;
    
    DROP TABLE #CustomerSource;
    
    PRINT 'Successfully updated dim_customer (SCD Type 2).';

END;
GO

CREATE PROCEDURE ETL_Load_Fact_Order
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO fact_order (
        customer_key, product_key, seller_key, order_status_key,
        order_purchase_date_key, order_approved_date_key, order_delivered_carrier_date_key,
        order_delivered_customer_date_key, order_estimated_delivery_date_key,
        order_id, quantity, price, freight_value, 
        discount_percent, discount_amount, total_amount, unit_cost, gross_profit
    )
    SELECT

        DC.customer_key,
        DP.product_key,
        DS.seller_key,
        DStat.status_key AS order_status_key,

        -- Date Keys
        DDatePurchase.date_key,
        DDateApproved.date_key,
        DDateCarrier.date_key,
        DDateCustomer.date_key,
        DDateEstimated.date_key,

        O.order_id,
        O.quantity,
        O.price,
        O.freight_value,
        
        -- Discount percentage from warehouse lookup
        W.discount_percent,

        -- CALCULATED: Discount Amount = (Price * Quantity) * Discount_Percent / 100
        CAST((O.price * O.quantity) * (W.discount_percent / 100.0) AS DECIMAL(10,2)) AS discount_amount,
        
        -- CALCULATED: Total Amount (Net Revenue) = (Price * Quantity) * (1 - Discount_Percent/100) + Freight_Value
        CAST((O.price * O.quantity) * (1 - (W.discount_percent / 100.0)) + O.freight_value AS DECIMAL(10,2)) AS total_amount,

        -- Unit Cost ASSUMPTION (70% of unit price)
        CAST((O.price * 0.70) AS DECIMAL(10,2)) AS unit_cost,
        
        -- CALCULATED: Gross Profit = Total_Amount (Net Revenue) - (Unit_Cost * Quantity)
        CAST(((O.price * O.quantity) * (1 - (W.discount_percent / 100.0)) + O.freight_value) - (O.price * 0.70 * O.quantity) AS DECIMAL(10,2)) AS gross_profit
      

    FROM
        stg_order AS O

    INNER JOIN
        stg_warehouse AS W ON O.prod_sell_id = W.prod_sell_id

    INNER JOIN 
        dim_customer AS DC ON O.customer_id = DC.customer_id
        AND CAST(O.order_purchase_timestamp AS DATE) >= CAST(DC.effective_date AS DATE) -- ADDED CAST
        AND (CAST(O.order_purchase_timestamp AS DATE) < CAST(DC.end_date AS DATE) OR DC.end_date IS NULL) -- ADDED CAST

    INNER JOIN
        dim_product AS DP ON W.product_id = DP.product_id
    INNER JOIN
        dim_seller AS DS ON W.seller_id = DS.seller_id
    -- Join 5: Order Status Dimension (Lookup by status text)
    INNER JOIN
        stg_order_status AS SS ON O.order_status = SS.status_id 
    INNER JOIN
        dim_order_status AS DStat ON SS.status = DStat.status_name

    INNER JOIN
        dim_date AS DDatePurchase ON CAST(O.order_purchase_timestamp AS DATE) = DDatePurchase.full_date
    LEFT JOIN
        dim_date AS DDateApproved ON CAST(O.order_approved_at AS DATE) = DDateApproved.full_date
    LEFT JOIN
        dim_date AS DDateCarrier ON CAST(O.order_delivered_carrier_date AS DATE) = DDateCarrier.full_date
    LEFT JOIN
        dim_date AS DDateCustomer ON CAST(O.order_delivered_customer_date AS DATE) = DDateCustomer.full_date
    INNER JOIN
        dim_date AS DDateEstimated ON CAST(O.order_estimated_delivery_date AS DATE) = DDateEstimated.full_date
    -- Only insert new records
    LEFT JOIN fact_order AS FO ON O.order_id = FO.order_id
    WHERE FO.order_key IS NULL;
    
    PRINT 'Loaded fact_order.';

END;
GO

CREATE PROCEDURE ETL_Load_Fact_Payment
AS
BEGIN
    SET NOCOUNT ON;

    -- Load transactional data into fact_payment (Payment Transaction Grain)
    INSERT INTO fact_payment (
        payment_type_key,
        transaction_date_key,
        order_id,
        payment_value,
        payment_installments
    )
    SELECT
        DPT.payment_type_key,
        DDatePurchase.date_key AS transaction_date_key, 
        P.order_id,
        P.payment_value,
        P.payment_installemts

    FROM
        stg_payment AS P
    -- Join 1: Payment Type Dimension
    INNER JOIN
        stg_payment_type AS SPT ON P.payment_type = SPT.payment_type_id
    INNER JOIN
        dim_payment_type AS DPT ON SPT.payment_type = DPT.payment_type_name
    -- Join 2: Date Dimension (Joined via stg_order to link payment to order purchase date)
    INNER JOIN
        stg_order AS O ON P.order_id = O.order_id
    INNER JOIN
        dim_date AS DDatePurchase ON CAST(O.order_purchase_timestamp AS DATE) = DDatePurchase.full_date
    -- Only insert payments not already in fact_payment (prevents accidental duplication during re-runs)
    LEFT JOIN fact_payment AS FP ON P.order_id = FP.order_id AND P.payment_value = FP.payment_value
    WHERE FP.payment_key IS NULL;
    
    PRINT 'Loaded fact_payment.';

END;
GO

CREATE OR ALTER PROCEDURE ETL_Load_Dim_Date
AS
BEGIN
    SET NOCOUNT ON;

    -- Define the start and end boundaries for the date generation
    DECLARE @StartDate DATE = '2016-01-01';
    DECLARE @EndDate DATE = '2026-12-31';

    -- IMPORTANT FIX: Use DELETE FROM instead of TRUNCATE TABLE.
    -- DELETE FROM respects Foreign Key constraints, allowing the procedure to run 
    -- even when dim_date is referenced by fact tables.
    DELETE FROM dim_date; 
    
    -- Use a Recursive CTE to generate all dates between the start and end
    WITH DateGenerator AS (
        -- Anchor Member: Start with the initial date
        SELECT 
            @StartDate AS DateValue
        
        UNION ALL
        
        -- Recursive Member: Increment the date by one day until the EndDate
        SELECT 
            DATEADD(DAY, 1, DateValue)
        FROM DateGenerator
        WHERE DATEADD(DAY, 1, DateValue) <= @EndDate
    )
    -- Insert all generated dates and calculated attributes into the dim_date table
    INSERT INTO dim_date (
        date_key,
        full_date,
        day,
        month,
        year,
        quarter,
        day_of_week,
        month_name,
        day_name
    )
    SELECT
        -- date_key: Use YYYYMMDD format for the key (e.g., 20160101)
        CAST(FORMAT(DateValue, 'yyyyMMdd') AS INT) AS date_key,
        
        -- full_date
        DateValue AS full_date,
        
        -- day: Day number (1-31)
        DAY(DateValue) AS day,
        
        -- month: Month number (1-12)
        MONTH(DateValue) AS month,
        
        -- year: Full year (2016-2026)
        YEAR(DateValue) AS year,
        
        -- quarter: Quarter number (1-4)
        DATEPART(QUARTER, DateValue) AS quarter,
        
        -- day_of_week: Day of week (1=Sunday, 2=Monday, ..., 7=Saturday)
        DATEPART(WEEKDAY, DateValue) AS day_of_week,
        
        -- month_name: Full month name (e.g., January, February)
        FORMAT(DateValue, 'MMMM', 'en-US') AS month_name,
        
        -- day_name: Full day name (e.g., Monday, Tuesday)
        FORMAT(DateValue, 'dddd', 'en-US') AS day_name
        
    FROM DateGenerator
    -- This option is required for recursive CTEs that generate more than 100 rows
    OPTION (MAXRECURSION 0); 

    PRINT 'dim_date table cleared and re-loaded successfully with dates from 2016-01-01 to 2026-12-31.';

END;
GO
































