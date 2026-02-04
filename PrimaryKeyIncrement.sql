DECLARE @maxID INT;
DECLARE @sql NVARCHAR(MAX);
SELECT @maxID = ISNULL(MAX(order_id), 0) FROM olist_order_dataset;

SET @sql = 'CREATE SEQUENCE dbo.Seq_olist_order
            AS INT
            START WITH ' + CAST(@maxID + 1 AS NVARCHAR(20)) + '
            INCREMENT BY 1;';

EXEC (@sql);

ALTER TABLE olist_order_dataset
ADD CONSTRAINT DF_olist_order
DEFAULT (NEXT VALUE FOR dbo.Seq_olist_order) FOR order_id;


DECLARE @maxID1 INT;
DECLARE @sql1 NVARCHAR(MAX);
SELECT @maxID1 = ISNULL(MAX(prod_sell_id), 0) FROM olist_warehouse_dataset;

SET @sql1 = 'CREATE SEQUENCE dbo.Seq_olist_warehouse
            AS INT
            START WITH ' + CAST(@maxID1 + 1 AS NVARCHAR(20)) + '
            INCREMENT BY 1;';

EXEC (@sql1);

ALTER TABLE olist_warehouse_dataset
ADD CONSTRAINT DF_olist_warehouse
DEFAULT (NEXT VALUE FOR dbo.Seq_olist_warehouse) FOR prod_sell_id;

DECLARE @maxID2 INT;
DECLARE @sql2 NVARCHAR(MAX);
SELECT @maxID2 = ISNULL(MAX(payment_id), 0) FROM olist_payments_dataset;

SET @sql2 = 'CREATE SEQUENCE dbo.Seq_olist_payment
            AS INT
            START WITH ' + CAST(@maxID2 + 1 AS NVARCHAR(20)) + '
            INCREMENT BY 1;';

EXEC (@sql2);

ALTER TABLE olist_payments_dataset
ADD CONSTRAINT DF_olist_payment
DEFAULT (NEXT VALUE FOR dbo.Seq_olist_payment) FOR payment_id;

DECLARE @maxID3 INT;
DECLARE @sql3 NVARCHAR(MAX);
SELECT @maxID3 = ISNULL(MAX(review_id), 0) FROM olist_order_review;

SET @sql3 = 'CREATE SEQUENCE dbo.Seq_olist_review
            AS INT
            START WITH ' + CAST(@maxID3 + 1 AS NVARCHAR(20)) + '
            INCREMENT BY 1;';

EXEC (@sql3);

ALTER TABLE olist_order_review
ADD CONSTRAINT DF_olist_review
DEFAULT (NEXT VALUE FOR dbo.Seq_olist_review) FOR review_id;

DECLARE @maxID4 INT;
DECLARE @sql4 NVARCHAR(MAX);
SELECT @maxID4 = ISNULL(MAX(seller_id), 0) FROM olist_sellers_dataset;

SET @sql4 = 'CREATE SEQUENCE dbo.Seq_olist_seller
            AS INT
            START WITH ' + CAST(@maxID4 + 1 AS NVARCHAR(20)) + '
            INCREMENT BY 1;';

EXEC (@sql4);

ALTER TABLE olist_sellers_dataset
ADD CONSTRAINT DF_olist_seller
DEFAULT (NEXT VALUE FOR dbo.Seq_olist_seller) FOR seller_id;

DECLARE @maxID5 INT;
DECLARE @sql5 NVARCHAR(MAX);
SELECT @maxID5 = ISNULL(MAX(customer_id), 0) FROM olist_customers_dataset;

SET @sql5 = 'CREATE SEQUENCE dbo.Seq_olist_customer
            AS INT
            START WITH ' + CAST(@maxID5 + 1 AS NVARCHAR(20)) + '
            INCREMENT BY 1;';

EXEC (@sql5);

ALTER TABLE olist_customers_dataset
ADD CONSTRAINT DF_olist_customer
DEFAULT (NEXT VALUE FOR dbo.Seq_olist_customer) FOR customer_id;

DECLARE @maxID6 INT;
DECLARE @sql6 NVARCHAR(MAX);
SELECT @maxID6 = ISNULL(MAX(product_id), 0) FROM olist_products_dataset;

SET @sql6 = 'CREATE SEQUENCE dbo.Seq_olist_product
            AS INT
            START WITH ' + CAST(@maxID6 + 1 AS NVARCHAR(20)) + '
            INCREMENT BY 1;';

EXEC (@sql6);

ALTER TABLE olist_products_dataset
ADD CONSTRAINT DF_olist_product
DEFAULT (NEXT VALUE FOR dbo.Seq_olist_product) FOR product_id;