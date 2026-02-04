ALTER TABLE olist_customers_dataset
ADD ModifiedDate DATETIME
CONSTRAINT DF_ModifiedDate DEFAULT SYSDATETIME() NOT NULL;


UPDATE olist_customers_dataset
SET ModifiedDate = '2025-12-02 19:00:00.000';

CREATE TRIGGER trg_olist_customers_dataset_ModifiedDate
ON olist_customers_dataset
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE t
    SET ModifiedDate = SYSDATETIME()
    FROM olist_customers_dataset AS t
    INNER JOIN inserted AS i ON t.customer_id = i.customer_id
END;



select * from olist_customers_dataset where customer_id =3

UPDATE olist_customers_dataset
SET address_id = 757 where customer_id = 3


select * from olist_address_dataset 
select * from olist_city_dataset where city_id = 206