SET STATISTICS TIME ON;
SELECT

    -- Granular Location Details

    cs.state_id AS State, -- State for context

    cc.city_id AS City_ID, -- The most granular geographic identifier

    

    -- Demand Metrics

    SUM(o.price) AS Total_City_Revenue,

    COUNT(o.order_id) AS Total_City_Orders,

    

    -- Contextual Data

    AVG(o.freight_value) AS Avg_Freight_Cost

FROM

    olist_order_dataset o

INNER JOIN

    olist_customers_dataset c ON o.customer_id = c.customer_id

INNER JOIN

    olist_address_dataset ca ON c.address_id = ca.address_id -- Customer Address

INNER JOIN

    olist_city_dataset cc ON ca.city_id = cc.city_id 

INNER JOIN

    olist_state_dataset cs ON ca.city_id = cs.state_id

GROUP BY

    cs.state_id,

    cc.city_id

ORDER BY

    Total_City_Revenue DESC;

SET STATISTICS TIME OFF;

CREATE INDEX IX_Orders_Covering ON olist_order_dataset (customer_id) 
    INCLUDE (quantity, price, freight_value, order_id);