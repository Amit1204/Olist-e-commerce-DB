SET STATISTICS TIME ON;
SELECT
    p.product_id,
    p.product_category_id,
    s.seller_id,
    SUM(o.quantity * o.price) AS Seller_Revenue_Contribution,
    SUM(o.quantity) AS Seller_Quantity_Sold
FROM
    olist_order_dataset o
INNER JOIN
    olist_warehouse_dataset w ON o.prod_sell_id = w.prod_sell_id
INNER JOIN
    olist_products_dataset p ON w.product_id = p.product_id
INNER JOIN
    olist_sellers_dataset s ON w.seller_id = s.seller_id
WHERE
    p.product_id IN (
        SELECT TOP 10
            p_sub.product_id
        FROM
            olist_order_dataset o_sub
        INNER JOIN
            olist_warehouse_dataset w_sub ON o_sub.prod_sell_id = w_sub.prod_sell_id
        INNER JOIN
            olist_products_dataset p_sub ON w_sub.product_id = p_sub.product_id
        GROUP BY
            p_sub.product_id
        ORDER BY
            SUM(o_sub.quantity * o_sub.price) DESC
    )
GROUP BY
    p.product_id,
    p.product_category_id,
    s.seller_id
ORDER BY

    p.product_id,
    Seller_Revenue_Contribution DESC;
SET STATISTICS TIME OFF;