CREATE TABLE dim_date (
    date_key INT PRIMARY KEY,
    full_date DATE NOT NULL,
    day INT,
    month INT,
    year INT,
    quarter INT,
    day_of_week INT,
    month_name VARCHAR(20),
    day_name VARCHAR(20)
);

CREATE TABLE dim_customer (
    customer_key INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT NOT NULL,
    customer_zip_code VARCHAR(MAX) NOT NULL,
    customer_city VARCHAR(MAX) NOT NULL,
    customer_state VARCHAR(MAX) NOT NULL,
    effective_date VARCHAR(MAX) NOT NULL,
    end_date VARCHAR(MAX),
    is_current VARCHAR(MAX) NOT NULL
);

CREATE TABLE dim_seller (
    seller_key INT IDENTITY(1,1) PRIMARY KEY,
    seller_id INT NOT NULL,
    seller_zip_code VARCHAR(MAX) NOT NULL,
    seller_city VARCHAR(MAX) NOT NULL,
    seller_state VARCHAR(MAX) NOT NULL
);

CREATE TABLE dim_product (
    product_key INT IDENTITY(1,1) PRIMARY KEY,
    product_id INT NOT NULL,
    product_category_name VARCHAR(MAX) NOT NULL,
    product_weight_g VARCHAR(MAX),
    product_length_cm VARCHAR(MAX),
    product_height_cm VARCHAR(MAX),
    product_width_cm VARCHAR(MAX)
);


CREATE TABLE dim_order_status (
    status_key INT IDENTITY(1,1) PRIMARY KEY,
    status_name VARCHAR(50) not null unique,
);

CREATE TABLE dim_payment_type (
    payment_type_key INT IDENTITY(1,1) PRIMARY KEY,
    payment_type_name VARCHAR(50) not null unique,
);

CREATE TABLE fact_order (
    order_key INT IDENTITY(1,1) PRIMARY KEY,
    customer_key INT NOT NULL,
    product_key INT NOT NULL,
    seller_key INT NOT NULL,
    order_status_key INT NOT NULL,
    order_purchase_date_key INT NOT NULL,
    order_approved_date_key INT,
    order_delivered_carrier_date_key INT,
    order_delivered_customer_date_key INT,
    order_estimated_delivery_date_key INT NOT NULL,
    order_id INT NOT NULL UNIQUE,
    quantity INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    freight_value DECIMAL(10,2) NOT NULL,
    total_amount DECIMAL(10,2),
    discount_percent DECIMAL(5,2),
    discount_amount DECIMAL(10,2),
    unit_cost DECIMAL(10,2),
    gross_profit DECIMAL(10,2),
    CONSTRAINT FK_fact_order_customer FOREIGN KEY (customer_key) REFERENCES dim_customer(customer_key),
    CONSTRAINT FK_fact_order_product FOREIGN KEY (product_key) REFERENCES dim_product(product_key),
    CONSTRAINT FK_fact_order_seller FOREIGN KEY (seller_key) REFERENCES dim_seller(seller_key),
    CONSTRAINT FK_fact_order_status FOREIGN KEY (order_status_key) REFERENCES dim_order_status(status_key),
    CONSTRAINT FK_fact_order_purchase_date FOREIGN KEY (order_purchase_date_key) REFERENCES dim_date(date_key),
    CONSTRAINT FK_fact_order_approved_date FOREIGN KEY (order_approved_date_key) REFERENCES dim_date(date_key),
    CONSTRAINT FK_fact_order_delivered_carrier_date FOREIGN KEY (order_delivered_carrier_date_key) REFERENCES dim_date(date_key),
    CONSTRAINT FK_fact_order_delivered_customer_date FOREIGN KEY (order_delivered_customer_date_key) REFERENCES dim_date(date_key),
    CONSTRAINT FK_fact_order_estimated_delivery_date FOREIGN KEY (order_estimated_delivery_date_key) REFERENCES dim_date(date_key)
);
CREATE TABLE fact_payment (
    payment_key INT IDENTITY(1,1) PRIMARY KEY,
    payment_type_key INT NOT NULL,
    transaction_date_key INT NOT NULL,
    order_id INT NOT NULL,
    payment_value DECIMAL(10,2) NOT NULL,
    payment_installments INT,
    CONSTRAINT FK_fact_payment_type FOREIGN KEY (payment_type_key) REFERENCES dim_payment_type(payment_type_key),
    CONSTRAINT FK_fact_payment_date FOREIGN KEY (transaction_date_key) REFERENCES dim_date(date_key)
);

CREATE TABLE fact_inventory_snapshot (
    inventory_snapshot_key INT IDENTITY(1,1) PRIMARY KEY,
    snapshot_date_key INT NOT NULL,
    product_key INT NOT NULL,
    seller_key INT NOT NULL,
    stock_level INT,
    current_unit_price DECIMAL(10,2),
    current_discount_rate DECIMAL(5,2),
    avg_cost_at_snapshot DECIMAL(10,2),
    CONSTRAINT FK_fact_inventory_date FOREIGN KEY (snapshot_date_key) REFERENCES dim_date(date_key),
    CONSTRAINT FK_fact_inventory_product FOREIGN KEY (product_key) REFERENCES dim_product(product_key),
    CONSTRAINT FK_fact_inventory_seller FOREIGN KEY (seller_key) REFERENCES dim_seller(seller_key),
    CONSTRAINT UQ_inventory_snapshot_grain UNIQUE (snapshot_date_key, product_key, seller_key)
);