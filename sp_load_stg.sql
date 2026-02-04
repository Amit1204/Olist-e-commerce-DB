CREATE PROCEDURE ETL_Load_stg_state
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @OltpDbName VARCHAR(50) = 'olist_ecommerce_db.dbo.';

    TRUNCATE TABLE stg_state;
    
    INSERT INTO stg_state (state_id, state)
    SELECT 
        state_id, 
        state 
    FROM olist_ecommerce_db.dbo.olist_state_dataset;
    
    PRINT 'Loaded stg_state.';
END;
GO

CREATE PROCEDURE ETL_Load_stg_city
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @OltpDbName VARCHAR(50) = 'olist_ecommerce_db.dbo.';

    TRUNCATE TABLE stg_city;
    
    INSERT INTO stg_city (city_id, city)
    SELECT 
        city_id, 
        city 
    FROM olist_ecommerce_db.dbo.olist_city_dataset;
    
    PRINT 'Loaded stg_city.';
END;
GO

CREATE PROCEDURE ETL_Load_stg_address
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @OltpDbName VARCHAR(50) = 'olist_ecommerce_db.dbo.';

    TRUNCATE TABLE stg_address;
    
    INSERT INTO stg_address (address_id, zip_code_prefix, state_id, city_id)
    SELECT 
        address_id, 
        zip_code_prefix, 
        state_id, 
        city_id 
    FROM olist_ecommerce_db.dbo.olist_address_dataset;
    
    PRINT 'Loaded stg_address.';
END;
GO

CREATE PROCEDURE ETL_Load_stg_product_category
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @OltpDbName VARCHAR(50) = 'olist_ecommerce_db.dbo.';

    TRUNCATE TABLE stg_product_category;
    
    INSERT INTO stg_product_category (product_category_id, product_category_name)
    SELECT 
        product_category_id, 
        product_category_name 
    FROM olist_ecommerce_db.dbo.olist_product_category_dataset;
    
    PRINT 'Loaded stg_product_category.';
END;
GO

CREATE PROCEDURE ETL_Load_stg_seller
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @OltpDbName VARCHAR(50) = 'olist_ecommerce_db.dbo.';

    TRUNCATE TABLE stg_seller;
    
    INSERT INTO stg_seller (seller_id, address_id)
    SELECT 
        seller_id, 
        address_id 
    FROM olist_ecommerce_db.dbo.olist_sellers_dataset;
    
    PRINT 'Loaded stg_seller.';
END;
GO

CREATE PROCEDURE ETL_Load_stg_customer
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @OltpDbName VARCHAR(50) = 'olist_ecommerce_db.dbo.';

    TRUNCATE TABLE stg_customer;
    
    INSERT INTO stg_customer (customer_id, address_id)
    SELECT 
        customer_id, 
        address_id 
    FROM olist_ecommerce_db.dbo.olist_customers_dataset;
    
    PRINT 'Loaded stg_customer.';
END;
GO

CREATE PROCEDURE ETL_Load_stg_payment_type
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @OltpDbName VARCHAR(50) = 'olist_ecommerce_db.dbo.';

    TRUNCATE TABLE stg_payment_type;
    
    INSERT INTO stg_payment_type (payment_type_id, payment_type)
    SELECT 
        payment_type_id, 
        payment_type 
    FROM olist_ecommerce_db.dbo.olist_order_payment_type_dataset;
    
    PRINT 'Loaded stg_payment_type.';
END;
GO

CREATE PROCEDURE ETL_Load_stg_order_status
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @OltpDbName VARCHAR(50) = 'olist_ecommerce_db.dbo.';

    TRUNCATE TABLE stg_order_status;
    
    INSERT INTO stg_order_status (status_id, status)
    SELECT 
        status_id, 
        status 
    FROM olist_ecommerce_db.dbo.olist_order_status_dataset;
    
    PRINT 'Loaded stg_order_status.';
END;
GO

CREATE PROCEDURE ETL_Load_stg_payment
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @OltpDbName VARCHAR(50) = 'olist_ecommerce_db.dbo.';

    TRUNCATE TABLE stg_payment;
    
    INSERT INTO stg_payment (payment_id, order_id, payment_type, payment_installemts, payment_value)
    SELECT 
        payment_id, 
        order_id, 
        payment_type, 
        payment_installemts, 
        payment_value 
    FROM olist_ecommerce_db.dbo.olist_payments_dataset;
    
    PRINT 'Loaded stg_payment.';
END;
GO

CREATE PROCEDURE ETL_Load_stg_product
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @OltpDbName VARCHAR(50) = 'olist_ecommerce_db.dbo.';

    TRUNCATE TABLE stg_product;
    
    INSERT INTO stg_product (product_id, product_category_id, product_weight_g, product_length_cm, product_height_cm, product_width_cm)
    SELECT 
        product_id, 
        product_category_id, 
        product_weight_g, 
        product_length_cm, 
        product_height_cm, 
        product_width_cm 
    FROM olist_ecommerce_db.dbo.olist_products_dataset;
    
    PRINT 'Loaded stg_product.';
END;
GO

CREATE PROCEDURE ETL_Load_stg_review
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @OltpDbName VARCHAR(50) = 'olist_ecommerce_db.dbo.';

    TRUNCATE TABLE stg_review;
    
    INSERT INTO stg_review (review_id, order_id, review_score, review_comment_title, review_comment_message, review_answer_timestamp)
    SELECT 
        review_id, 
        order_id, 
        review_score, 
        review_comment_title, 
        review_comment_message, 
        review_answer_timestamp 
    FROM olist_ecommerce_db.dbo.olist_order_review;
    
    PRINT 'Loaded stg_review.';
END;
GO

CREATE PROCEDURE ETL_Load_stg_order
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @OltpDbName VARCHAR(50) = 'olist_ecommerce_db.dbo.';

    TRUNCATE TABLE stg_order;
    
    INSERT INTO stg_order (order_id, customer_id, order_status, order_purchase_timestamp, order_approved_at, order_delivered_carrier_date, order_delivered_customer_date, order_estimated_delivery_date, prod_sell_id, quantity, price, freight_value)
    SELECT 
        order_id, 
        customer_id, 
        order_status, 
        order_purchase_timestamp, 
        order_approved_at, 
        order_delivered_carrier_date, 
        order_delivered_customer_date, 
        order_estimated_delivery_date, 
        prod_sell_id, 
        quantity, 
        price, 
        freight_value
    FROM olist_ecommerce_db.dbo.olist_order_dataset;
    
    PRINT 'Loaded stg_order.';
END;
GO

CREATE PROCEDURE ETL_Load_stg_warehouse
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @OltpDbName VARCHAR(50) = 'olist_ecommerce_db.dbo.';

    TRUNCATE TABLE stg_warehouse;
    
    INSERT INTO stg_warehouse (prod_sell_id, product_id, seller_id, stock, price_per_unit, discount_percent)
    SELECT 
        prod_sell_id, 
        product_id, 
        seller_id, 
        stock, 
        price_per_unit, 
        discount_percent 
    FROM olist_ecommerce_db.dbo.olist_warehouse_dataset;
    
    PRINT 'Loaded stg_warehouse.';
END;
GO

