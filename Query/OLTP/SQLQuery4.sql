SET STATISTICS TIME ON;

SELECT

    sq.Product_Rank,
    sq.product_category_id,
    sq.product_id,
    w.seller_id,

    SUM(o.quantity * o.price) AS Seller_Revenue_Contribution,
    SUM(o.quantity) AS Seller_Quantity_Sold,
    sq.Product_Total_Revenue
FROM
    olist_order_dataset o
INNER JOIN
    olist_warehouse_dataset w ON o.prod_sell_id = w.prod_sell_id
INNER JOIN

    (
        SELECT --TOP 10
            p_sub.product_id,
            p_sub.product_category_id,
            SUM(o_sub.quantity * o_sub.price) AS Product_Total_Revenue,
            ROW_NUMBER() OVER (ORDER BY SUM(o_sub.quantity * o_sub.price) DESC) as Product_Rank
        FROM
            olist_order_dataset o_sub
        INNER JOIN
            olist_warehouse_dataset w_sub ON o_sub.prod_sell_id = w_sub.prod_sell_id
        INNER JOIN
            olist_products_dataset p_sub ON w_sub.product_id = p_sub.product_id
        GROUP BY
            p_sub.product_id,
            p_sub.product_category_id
        --ORDER BY
            --Product_Total_Revenue DESC
    ) sq ON w.product_id = sq.product_id
WHERE
    Product_Rank<=10
GROUP BY
    sq.Product_Rank,
    sq.product_category_id,
    sq.product_id,
    w.seller_id,
    sq.Product_Total_Revenue
ORDER BY
    sq.Product_Rank,
    Seller_Revenue_Contribution DESC;

SET STATISTICS TIME OFF;

CREATE NONCLUSTERED INDEX IX_Order_ProdSellQuantPrice
ON olist_order_dataset (order_id)
INCLUDE (prod_sell_id, quantity, price);

CREATE NONCLUSTERED INDEX IX_Products_ID_CategoryID
ON olist_products_dataset (product_id)
INCLUDE (product_category_id);

CREATE NONCLUSTERED INDEX IX_Products_Seller_ID
ON olist_warehouse_dataset (prod_sell_id)
INCLUDE (product_id, seller_id);

drop INDEX IX_Order_ProdSellQuantPrice on olist_order_dataset
drop index IX_Products_ID_CategoryID on olist_products_dataset
drop index IX_Products_Seller_ID on olist_warehouse_dataset