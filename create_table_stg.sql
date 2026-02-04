CREATE TABLE stg_address (
    address_id INT PRIMARY KEY,
    zip_code_prefix INT,
    state_id INT,
    city_id INT
);

CREATE TABLE stg_city (
    city_id INT PRIMARY KEY,
    city VARCHAR(200)
);

CREATE TABLE stg_state (
    state_id INT PRIMARY KEY,
    state VARCHAR(200)
);

CREATE TABLE stg_product_category (
    product_category_id INT PRIMARY KEY,
    product_category_name VARCHAR(200)
);

CREATE TABLE stg_seller (
    seller_id INT PRIMARY KEY,
    address_id VARCHAR(200)
);

CREATE TABLE stg_customer (
    customer_id INT PRIMARY KEY,
    address_id VARCHAR(200)
);

CREATE TABLE stg_payment_type (
    payment_type_id INT PRIMARY KEY,
    payment_type VARCHAR(50) NOT NULL UNIQUE -- Changed from VARCHAR(200)
);

CREATE TABLE stg_order_status (
    status_id INT PRIMARY KEY,
    status VARCHAR(50) NOT NULL UNIQUE -- Changed from VARCHAR(200)
);

CREATE TABLE stg_payment (
    payment_id INT PRIMARY KEY,
    order_id INT,
    payment_type INT,
    payment_installemts INT,
    payment_value FLOAT
);

CREATE TABLE stg_product (
    product_id INT,
    product_category_id INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

CREATE TABLE stg_review (
    review_id INT PRIMARY KEY,
    order_id INT,
    review_score INT,
    review_comment_title NVARCHAR(MAX),
    review_comment_message NVARCHAR(MAX),
    review_answer_timestamp DATETIME
);

CREATE TABLE stg_order (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_status INT,
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME,
    -- Columns reflecting the combined OLTP table structure
    prod_sell_id INT,
    quantity INT,
    price FLOAT,
    freight_value FLOAT
);

CREATE TABLE stg_warehouse (
    prod_sell_id INT PRIMARY KEY,
    product_id INT,
    seller_id INT,
    stock INT,
    price_per_unit FLOAT,
    discount_percent DECIMAL(5,2) -- NEW COLUMN ADDED
);