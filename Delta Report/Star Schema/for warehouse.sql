CREATE TABLE ETL_Control_Table (
        ETLSourceKey    VARCHAR(100) PRIMARY KEY,
        LastUpdateTime  DATETIME NOT NULL,  
);

INSERT INTO ETL_Control_Table (ETLSourceKey, LastUpdateTime)
VALUES ('olist_customers_stg', '2025-12-02 19:03:00.000');

CREATE PROCEDURE ETL_Load_stg_customer
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @OltpDbName VARCHAR(50) = 'olist_ecommerce_db.dbo.';
    DECLARE @LastUpdateTime DATETIME;
    DECLARE @SourceKey VARCHAR(100) = 'olist_customers_stg';

    SELECT @LastUpdateTime = LastUpdateTime
    FROM ETL_Control_Table
    WHERE ETLSourceKey = @SourceKey;

    TRUNCATE TABLE stg_customer;

    INSERT INTO stg_customer (customer_id, address_id)
    SELECT 
        customer_id, 
        address_id
    FROM olist_ecommerce_db.dbo.olist_customers_dataset
    WHERE ModifiedDate > @LastUpdateTime;

    UPDATE ETL_Control_Table
    SET 
        LastUpdateTime = SYSDATETIME()
    WHERE 
        ETLSourceKey = @SourceKey;
END
GO

EXEC ETL_Load_stg_customer;

select * from stg_customer;
select * from ETL_Control_Table;

EXEC ETL_Load_Dim_Customer;

select * from dim_customer where customer_id = 3