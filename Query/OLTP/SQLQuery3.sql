SET STATISTICS TIME ON;
WITH RankedProducts AS (
    SELECT TOP 10
        p.product_id,
        p.product_category_id,
        SUM(o.quantity * o.price) AS Product_Total_Revenue,

        ROW_NUMBER() OVER (ORDER BY SUM(o.quantity * o.price) DESC) as Product_Rank
    FROM
        olist_order_dataset o
    INNER JOIN
        olist_warehouse_dataset w ON o.prod_sell_id = w.prod_sell_id
    INNER JOIN
        olist_products_dataset p ON w.product_id = p.product_id
    GROUP BY
        p.product_id,
        p.product_category_id
    ORDER BY Product_Rank
)

SELECT
    rp.Product_Rank,
    rp.product_category_id,
    rp.product_id,
    s.seller_id,

    SUM(o.quantity * o.price) AS Seller_Revenue_Contribution,
    SUM(o.quantity) AS Seller_Quantity_Sold,

    rp.Product_Total_Revenue
FROM
    olist_order_dataset o
INNER JOIN
    olist_warehouse_dataset w ON o.prod_sell_id = w.prod_sell_id
INNER JOIN
    olist_products_dataset p ON w.product_id = p.product_id
INNER JOIN
    olist_sellers_dataset s ON w.seller_id = s.seller_id
INNER JOIN
    RankedProducts rp ON p.product_id = rp.product_id
--WHERE
    --rp.Product_Rank <= 10
GROUP BY
    rp.Product_Rank,
    rp.product_category_id,
    rp.product_id,
    s.seller_id,
    rp.Product_Total_Revenue
ORDER BY
    rp.Product_Rank,                           
    Seller_Revenue_Contribution DESC;
SET STATISTICS TIME OFF;