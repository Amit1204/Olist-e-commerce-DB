CREATE PROCEDURE sp_update_stock
    @seller_id INT,
    @product_id INT,
    @add_stock INT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM olist_warehouse_dataset WHERE seller_id = @seller_id AND product_id = @product_id )
        BEGIN
            -- Update stock
            UPDATE olist_warehouse_dataset
            SET stock = stock + @add_stock
            WHERE seller_id = @seller_id AND product_id = @product_id;

            SELECT 1 AS updated_stock
        END
    ELSE
        BEGIN
            RAISERROR('Product id is not listed for the seller.', 16, 1);
            RETURN
        END
END;
GO

CREATE PROCEDURE sp_apply_discount_all_products
    @seller_id INT,
    @discount_percent DECIMAL(5,2)
AS
BEGIN
    SET NOCOUNT ON;
    -- Apply discount on all seller's products
    UPDATE olist_warehouse_dataset
    SET discount_percent = @discount_percent
    WHERE seller_id = @seller_id;

    SELECT 1 AS discount_applied;
END;
GO

CREATE PROCEDURE sp_apply_discount_single_product
    @seller_id INT,
    @product_id INT,
    @discount_percent DECIMAL(5,2)
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM olist_warehouse_dataset WHERE seller_id = @seller_id AND product_id = @product_id)
        BEGIN
        -- Apply discount on that product
            UPDATE olist_warehouse_dataset
            SET discount_percent = @discount_percent
            WHERE seller_id = @seller_id AND product_id = @product_id;

            SELECT 1 AS discount_applied 
         END
    ELSE
    BEGIN
            RAISERROR('Product id is not listed for the seller.', 16, 1);
            RETURN
        END
END;
GO

CREATE PROCEDURE sp_add_product_to_warehouse
    @seller_id INT,
    @product_id INT,
    @price_per_unit DECIMAL(10,2),
    @discount_percent DECIMAL(5,2),
    @initial_stock INT
AS
BEGIN
    SET NOCOUNT ON;
    --Check if seller already sells this product
    IF NOT EXISTS (
        SELECT 1 FROM olist_products_dataset 
        WHERE product_id = @product_id
    )
    BEGIN
        RAISERROR('The product is not listed in the product dataset.', 16, 1);
        RETURN
    END;
    IF EXISTS (
        SELECT 1 FROM olist_warehouse_dataset 
        WHERE seller_id = @seller_id AND product_id = @product_id
    )
    BEGIN
        RAISERROR('This product is already listed by the seller.', 16, 1);
        RETURN
    END;

    -- Step: Insert into warehouse
    INSERT INTO olist_warehouse_dataset (product_id, seller_id, stock, price_per_unit, discount_percent)
    VALUES (@product_id, @seller_id, @initial_stock, @price_per_unit, @discount_percent);

    SELECT 1 AS product_added;
END;
GO

CREATE PROCEDURE sp_update_price
    @seller_id INT,
    @product_id INT,
    @new_price DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM olist_warehouse_dataset WHERE seller_id = @seller_id AND product_id = @product_id)
        BEGIN
            UPDATE olist_warehouse_dataset
            SET price_per_unit = @new_price
            WHERE seller_id = @seller_id AND product_id = @product_id;

            SELECT 1 AS price_updated
            END
    ELSE
        BEGIN
            RAISERROR('Product id is not listed for the seller.', 16, 1);
            RETURN
        END  
END;
GO

CREATE PROCEDURE sp_remove_product_from_warehouse
    @seller_id INT,
    @product_id INT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM olist_warehouse_dataset WHERE seller_id = @seller_id AND product_id = @product_id)
        BEGIN
            -- Set stock to zero instead of deleting
            UPDATE olist_warehouse_dataset
            SET stock = 0
            WHERE seller_id = @seller_id AND product_id = @product_id;

            SELECT 1 AS product_removed;
        END
    ELSE
          BEGIN
            RAISERROR('Product id is not listed for the seller.', 16, 1);
            RETURN
        END 
END;
GO

CREATE PROCEDURE sp_check_seller_exists
    @seller_id INT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM olist_sellers_dataset WHERE seller_id = @seller_id)
        SELECT 1 AS seller_exists
    ELSE
        SELECT 0 AS seller_exists
END;
GO


CREATE PROCEDURE sp_get_product
    @seller_id INT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM olist_warehouse_dataset WHERE seller_id = @seller_id)
        SELECT product_id FROM olist_warehouse_dataset WHERE seller_id = @seller_id
    ELSE
        BEGIN
            RAISERROR('There is no product listed for the seller.', 16, 1);
            RETURN
        END
END;
GO


