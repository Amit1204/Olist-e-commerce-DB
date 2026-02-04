--Raise error if review score is not between 1-5
CREATE TRIGGER trg_review_score_check
ON olist_order_review
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE review_score not in (1,2,3,4,5) OR review_score IS NULL
    )
    BEGIN
        RAISERROR('Review score must be between 1 and 5.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO 

-- Check if stock in inserted rows is less than 0
CREATE TRIGGER trg_stock_warehouse_check
ON olist_warehouse_dataset
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE stock < 0)
    BEGIN
        RAISERROR('Stock cannot be less than 0', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO