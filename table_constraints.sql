ALTER TABLE olist_state_dataset
ALTER COLUMN state VARCHAR(200) NOT NULL; -- state not null in state dataset


ALTER TABLE olist_city_dataset -- city not null in city dataset
ALTER COLUMN city VARCHAR(200) NOT NULL; 

ALTER TABLE olist_address_dataset -- city not null in address dataset
ALTER COLUMN city_id INT NOT NULL;


ALTER TABLE olist_address_dataset --state not null in address dataset
ALTER COLUMN state_id INT NOT NULL;

ALTER TABLE olist_address_dataset --zip_code not null in address dataset
ALTER COLUMN zip_code_prefix INT NOT NULL;

ALTER TABLE olist_address_dataset --fk city_id from city dataset
ADD CONSTRAINT fk_address_city
FOREIGN KEY (city_id)
REFERENCES olist_city_dataset(city_id)

ALTER TABLE olist_address_dataset --fk state from state dataset
ADD CONSTRAINT fk_address_state
FOREIGN KEY (state_id)
REFERENCES olist_state_dataset(state_id)

ALTER TABLE olist_address_dataset --combination of city_id, state_id, zip_code_prefix is unique in address dataset
ADD CONSTRAINT uq_address_city_state_zip
UNIQUE (city_id, state_id, zip_code_prefix);

ALTER TABLE olist_product_category_dataset -- product_category not null
ALTER COLUMN product_category_name VARCHAR (200) NOT NULL;

--CONSTRAINTS ON SELLER DATASET
ALTER TABLE olist_sellers_dataset --address_id not nullt
ALTER COLUMN address_id INT NOT NULL;

ALTER TABLE olist_sellers_dataset --fk address_id from address dataset
ADD CONSTRAINT fk_seller_address
FOREIGN KEY (address_id)
REFERENCES olist_address_dataset(address_id);

--CONSTRAINTS ON CUSTOMER DATASET
ALTER TABLE olist_customers_dataset --address_id not null
ALTER COLUMN address_id INT NOT NULL;

ALTER TABLE olist_customers_dataset --fk address_id from address dataset
ADD CONSTRAINT fk_customer_address
FOREIGN KEY (address_id)
REFERENCES olist_address_dataset(address_id);

--CONSTRAINTS ON PAYMENT DATASET
ALTER TABLE olist_payments_dataset --order_id not null
ALTER COLUMN order_id INT NOT NULL;

ALTER TABLE olist_payments_dataset --payment value not null
ALTER COLUMN payment_value FLOAT NOT NULL;

ALTER TABLE olist_payments_dataset --payment type not null
ALTER COLUMN payment_type INT NOT NULL

ALTER TABLE olist_payments_dataset --payment installments not null
ALTER COLUMN payment_installemts INT NOT NULL

ALTER TABLE olist_payments_dataset --fk order_id from order dataset
ADD CONSTRAINT fk_order_id_payment
FOREIGN KEY (order_id)
REFERENCES olist_order_dataset(order_id);

ALTER TABLE olist_payments_dataset --fk payment_type
ADD CONSTRAINT fk_payment_type_id
FOREIGN KEY (payment_type)
REFERENCES olist_order_payment_type_dataset(payment_type_id);

--CONSTRAINTS ON PRODUCT DATASET
ALTER TABLE olist_products_dataset --fk product_category_id
ADD CONSTRAINT fk_product_category 
FOREIGN KEY (product_category_id)
REFERENCES olist_product_category_dataset(product_category_id);

--CONSTRAINTS ON ORDER REVIEW DATASET
ALTER TABLE olist_order_review --order_id not null
ALTER COLUMN order_id INT NOT NULL;

ALTER TABLE olist_order_review --review_score not null
ALTER COLUMN review_score INT NOT NULL;

ALTER TABLE olist_order_review -- chrck review score in 1 to 5
ADD CONSTRAINT chk_review_score
CHECK (review_score IN (1,2,3,4,5));

ALTER TABLE olist_order_review --fk order_id from order dataset
ADD CONSTRAINT fk_order_id_review
FOREIGN KEY (order_id)
REFERENCES olist_order_dataset(order_id);

--CONSTRAINTS ON ORDER DATASET
ALTER TABLE olist_order_dataset --customer_id not null
ALTER COLUMN customer_id INT NOT NULL;

ALTER TABLE olist_order_dataset --order_status not null
ALTER COLUMN order_status INT NOT NULL;

ALTER TABLE olist_order_dataset --quantity not null
ALTER COLUMN quantity INT NOT NULL;

ALTER TABLE olist_order_dataset --product_id not null
ALTER COLUMN product_id INT NOT NULL;

ALTER TABLE olist_order_dataset --seller_id not null
ALTER COLUMN seller_id INT NOT NULL;

ALTER TABLE olist_order_dataset --price not null
ALTER COLUMN price FLOAT NOT NULL;

ALTER TABLE olist_order_dataset --freight_value not null
ALTER COLUMN freight_value FLOAT NOT NULL;

ALTER TABLE olist_order_dataset --fk customer_id from customer dataset
ADD CONSTRAINT fk_customer_id_order
FOREIGN KEY (customer_id)
REFERENCES olist_customers_dataset(customer_id);

ALTER TABLE olist_order_dataset --fk order_status_id from order_status dataset
ADD CONSTRAINT fk_order_status_id_order
FOREIGN KEY (order_status)
REFERENCES olist_order_status_dataset(status_id);

ALTER TABLE olist_order_dataset --fk product_id from product dataset
ADD CONSTRAINT fk_product_id_order
FOREIGN KEY (product_id)
REFERENCES olist_products_dataset(product_id);

ALTER TABLE olist_order_dataset --fk seller_id from seller dataset
ADD CONSTRAINT fk_seller_id_order
FOREIGN KEY (seller_id)
REFERENCES olist_sellers_dataset(seller_id);

--CONSTRAINTS ON WAREHOUSE DATASET
ALTER TABLE olist_warehouse_dataset --product_id not null
ALTER COLUMN product_id INT NOT NULL;

ALTER TABLE olist_warehouse_dataset -- seller_id not null
ALTER COLUMN seller_id INT NOT NULL;

ALTER TABLE olist_warehouse_dataset --stock not null
ALTER COLUMN stock INT NOT NULL;

ALTER TABLE olist_warehouse_dataset
ALTER COLUMN price_per_unit INT NOT NULL;

ALTER TABLE olist_warehouse_dataset --fk seller_id from seller dataset
ADD CONSTRAINT fk_seller_id_warehouse
FOREIGN KEY (seller_id)
REFERENCES olist_sellers_dataset(seller_id);

ALTER TABLE olist_warehouse_dataset --fk product_id from product dataset
ADD CONSTRAINT fk_product_id_warehouse
FOREIGN KEY (product_id)
REFERENCES olist_products_dataset(product_id);

ALTER TABLE olist_warehouse_dataset --combination of product_id, seller_id is unique in warehouse dataset
ADD CONSTRAINT uq_prod_sell_in_warehouse
UNIQUE (product_id, seller_id);


ALTER TABLE olist_order_dataset
ADD prod_sell_id INT;
UPDATE olist_order_dataset
SET prod_sell_id = w.prod_sell_id
FROM olist_order_dataset o
INNER JOIN olist_warehouse_dataset w
    ON o.product_id = w.product_id
   AND o.seller_id = w.seller_id;

ALTER TABLE olist_order_dataset
DROP CONSTRAINT fk_product_id_order

ALTER TABLE olist_order_dataset
DROP CONSTRAINT fk_seller_id_order

ALTER TABLE olist_order_dataset
DROP COLUMN product_id, seller_id;



ALTER TABLE olist_order_dataset --fk prod_sell_id from warehouse dataset
ADD CONSTRAINT fk_prod_sell_id_order
FOREIGN KEY (prod_sell_id)
REFERENCES olist_warehouse_dataset(prod_sell_id);
ALTER TABLE olist_order_dataset --prod_sell_id not null
ALTER COLUMN prod_sell_id INT NOT NULL;