CREATE PROCEDURE ETL_Report_Top10_Product_Seller_Contribution
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        sq.Product_Rank,
        dp.product_category_name,
        dp.product_id,
        ds.seller_id,
        

        SUM(fo.total_amount) AS Seller_Net_Revenue_Contribution,
        SUM(fo.quantity) AS Seller_Quantity_Sold,
        sq.Product_Total_Net_Revenue
    FROM
 
        fact_order fo
    INNER JOIN

        dim_seller ds ON fo.seller_key = ds.seller_key
    INNER JOIN

        dim_product dp ON fo.product_key = dp.product_key
    INNER JOIN

        (
            SELECT TOP 10 
                dp_sub.product_id,
                SUM(fo_sub.total_amount) AS Product_Total_Net_Revenue,

                ROW_NUMBER() OVER (ORDER BY SUM(fo_sub.total_amount) DESC) AS Product_Rank
            FROM
                fact_order fo_sub
            INNER JOIN
                dim_product dp_sub ON fo_sub.product_key = dp_sub.product_key
            GROUP BY
                dp_sub.product_id
            ORDER BY
                Product_Total_Net_Revenue DESC
        ) sq ON dp.product_id = sq.product_id
    
    GROUP BY
        sq.Product_Rank,
        dp.product_category_name,
        dp.product_id,
        ds.seller_id,
        sq.Product_Total_Net_Revenue
    ORDER BY
        sq.Product_Rank,
        Seller_Net_Revenue_Contribution DESC;

END;
GO

CREATE NONCLUSTERED INDEX IX_DimProduct_ProductID
ON dim_product (product_id)
INCLUDE (product_key, product_category_name);

CREATE NONCLUSTERED INDEX IX_FactOrder_ProductRevenue
ON fact_order (product_key)
INCLUDE (total_amount, quantity);
drop index IX_DimProduct_ProductID on dim_product

SET STATISTICS TIME ON;
exec ETL_Report_Top10_Product_Seller_Contribution
SET STATISTICS TIME OFF;