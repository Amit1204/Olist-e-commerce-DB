CREATE PROCEDURE sp_get_product_category
AS
BEGIN
  SET NOCOUNT ON; 
  select product_category_name from olist_product_category_dataset
END;
GO

CREATE PROCEDURE sp_get_product_for_category
    @product_category VARCHAR,
    @product_category_id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT @product_category_id = product_category_id FROM olist_product_category_dataset where product_category_name=@product_category
    IF EXISTS (SELECT 1 FROM olist_products_dataset WHERE product_category_id = @product_category_id)
        BEGIN
            SELECT product_id FROM olist_products_dataset WHERE product_category_id = @product_category_id
        END
    ELSE
        BEGIN
             RAISERROR('There is no product for this product category.', 16, 1);
            RETURN
        END

END;
GO

CREATE PROCEDURE sp_get_seller
    @product_id INT,
    @quantity INT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM olist_warehouse_dataset WHERE product_id = @product_id)
        SELECT seller_id, price_per_unit, discount_percent FROM olist_warehouse_dataset WHERE product_id = @product_id and stock>=@quantity;
    ELSE
        BEGIN
            RAISERROR('There is no seller for this product or does not have enough quantity', 16, 1);
            RETURN
        END
END;
GO

CREATE PROCEDURE sp_get_order
    @customer_id INT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM olist_order_dataset WHERE customer_id = @customer_id)
        SELECT order_id FROM olist_order_dataset WHERE customer_id = @customer_id;
    ELSE
        BEGIN
            RAISERROR('There are no order for this customer.', 16, 1);
            RETURN
        END
END;
GO

CREATE PROCEDURE sp_check_customer_exist
    @customer_id INT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM olist_customers_dataset WHERE customer_id = @customer_id)
        SELECT 1 AS seller_exists
    ELSE
        SELECT 0 AS seller_exists
END;
GO

CREATE PROCEDURE sp_update_add_review
    @order_id INT,
    @review_score INT,
    @review_comment_title NVARCHAR(MAX) = NULL,
    @review_comment_message NVARCHAR(MAX) = NULL,
    @review_answer_timestamp DATETIME = NULL
AS 
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM olist_order_review WHERE order_id = @order_id)
        BEGIN
            UPDATE olist_order_review SET
            review_score = @review_score,
            review_comment_title = @review_comment_title,
            review_comment_message =  @review_comment_message,
            review_answer_timestamp = GETDATE()

            SELECT 1 AS REVIEW
        END
    ELSE
        BEGIN 
            INSERT INTO olist_order_review (order_id, review_score, review_comment_title, review_comment_message, review_answer_timestamp)
            VALUES  (@order_id, @review_score, @review_comment_title, @review_comment_message, @review_answer_timestamp );
            SELECT 1 AS REVIEW
        END
    

END;
GO

CREATE PROCEDURE sp_get_order_details
    @customer_id INT
AS 
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM olist_order_dataset WHERE customer_id = @customer_id)
        BEGIN
            select order_id, olist_order_status_dataset.status, olist_order_dataset.order_approved_at, olist_order_dataset.order_delivered_customer_date,product_id, seller_id
            quantity, price, freight_value
            from olist_order_dataset join olist_order_status_dataset 
            ON olist_order_dataseT.order_status = olist_order_status_dataset.status_id 
            WHERE customer_id = @customer_id
        END
    ELSE
        BEGIN 
            RAISERROR('There are no order for this customer.', 16, 1);
            RETURN
        END 
END;
GO

CREATE PROC sp_order
    @customer_id INT,
    @product_id INT,
    @seller_id INT,
    @quantity INT,
    @payment_type  VARCHAR(50),
    @payment_type_id INT,
    @payment_installemts INT,
    @prod_sell_id INT
    
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM olist_warehouse_dataset WHERE seller_id = @seller_id AND product_id = @product_id AND stock>@quantity)
        BEGIN
            DECLARE @freight_value FLOAT,@order_id INT,@price FLOAT
            SET @order_id = NEXT VALUE FOR dbo.Seq_olist_order

            SELECT @freight_value = CAST(RAND() * 100 AS DECIMAL(5,2))

            SELECT @price = price_per_unit*@quantity, @prod_sell_id = prod_sell_id FROM olist_warehouse_dataset WHERE seller_id = @seller_id AND product_id = @product_id 

            INSERT INTO olist_order_dataset(order_id,customer_id,order_status,order_purchase_timestamp,quantity,price,freight_value,prod_sell_id) VALUES
            (@order_id,@customer_id,1, GETDATE(),@quantity,@price,@freight_value,@prod_sell_id)

            UPDATE olist_warehouse_dataset SET stock = stock-@quantity WHERE seller_id = @seller_id AND product_id = @product_id

            SELECT @payment_type_id = payment_type_id FROM olist_order_payment_type_dataset WHERE payment_type = @payment_type

            INSERT INTO olist_payments_dataset(order_id,payment_type,payment_installemts,payment_value) VALUES
            (@order_id, @payment_type_id,@payment_installemts,@price+@freight_value)

            SELECT 1 AS ORDERED
        END
    ELSE
        BEGIN
            RAISERROR('Either the seller does not ship this product or does not have sufficient stock', 16, 1);
            RETURN
        END
  END;
  GO

CREATE PROC sp_get_product_for_category
    @product_category VARCHAR(100)

AS
BEGIN
    DECLARE @product_category_id INT;
   
    select @product_category_id = product_category_id from olist_product_category_dataset where product_category_name = @product_category
    IF EXISTS (select 1 from olist_products_dataset where product_category_id = @product_category_id)
        BEGIN
            select product_id from olist_products_dataset where product_category_id = @product_category_id
        END
    ELSE
        BEGIN
            RAISERROR('No product for this category.', 16, 1);
                RETURN
        END
END;
go

