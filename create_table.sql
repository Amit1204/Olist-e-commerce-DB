CREATE TABLE olist_address_dataset (
	address_id INT PRIMARY KEY,
	zip_code_prefix INT,
	state_id INT,
	city_id INT
);


CREATE TABLE olist_city_dataset (
	city_id INT PRIMARY KEY,
	city VARCHAR (200)
);

CREATE TABLE olist_state_dataset (
	state_id INT PRIMARY KEY,
	state VARCHAR (200)
);

CREATE TABLE olist_product_category_dataset (
	product_category_id INT PRIMARY KEY,
	product_category_name VARCHAR (200)
);

CREATE TABLE olist_sellers_dataset (
	seller_id INT PRIMARY KEY,
	address_id VARCHAR (200)
);


CREATE TABLE olist_customers_dataset (
	customer_id INT PRIMARY KEY,
	address_id VARCHAR (200)
);


CREATE TABLE olist_order_payment_type_dataset (
	payment_type_id INT PRIMARY KEY,
	payment_type VARCHAR (200) UNIQUE NOT NULL
);


CREATE TABLE olist_order_status_dataset (
	status_id INT PRIMARY KEY,
	status VARCHAR (200) UNIQUE NOT NULL
);


CREATE TABLE olist_payments_dataset (
	payment_id INT PRIMARY KEY,
	order_id INT,
	payment_type INT,
	payment_installemts INT,
	payment_value FLOAT
);

CREATE TABLE olist_products_dataset (
	product_id INT,
	product_category_id INT,
	product_weight_g INT,
	product_length_cm INT,
	product_height_cm INT,
	product_width_cm INT
);

CREATE TABLE olist_order_review (
	review_id INT PRIMARY KEY,
	order_id INT,
	review_score INT,
	review_comment_title NVARCHAR(MAX),
	review_comment_message NVARCHAR(MAX),
	review_answer_timestamp DATETIME
);

CREATE TABLE olist_order_dataset (
	order_id INT PRIMARY KEY,
	customer_id INT,
	order_status INT,
	order_purchase_timestamp DATETIME,
	order_approved_at DATETIME,
	order_delivered_carrier_date DATETIME,
	order_delivered_customer_date DATETIME,
	order_estimated_delivery_date DATETIME,
	quantity INT,
	product_id INT,
	seller_id INT,
	price FLOAT, 
	freight_value FLOAT
);

CREATE TABLE olist_warehouse_dataset (
	prod_sell_id INT PRIMARY KEY,
	product_id INT,
	seller_id INT,
	stock INT,
	price_per_unit FLOAT
);
ALTER TABLE olist_warehouse_dataset
ALTER COLUMN discount_percent DECIMAL(5,2) NOT NULL;
UPDATE olist_warehouse_dataset
SET discount_percent = 0;

