    EXEC ETL_Load_stg_address;
    EXEC ETL_Load_stg_city;
    EXEC ETL_Load_stg_state;
    EXEC ETL_Load_stg_product_category;
    EXEC ETL_Load_stg_seller;
    EXEC ETL_Load_stg_customer;
    EXEC ETL_Load_stg_payment_type;
    EXEC ETL_Load_stg_order_status;
    EXEC ETL_Load_stg_product;
    EXEC ETL_Load_stg_warehouse;
    EXEC ETL_Load_stg_order;
    EXEC ETL_Load_stg_review;
    EXEC ETL_Load_stg_payment;

    EXEC ETL_Load_Dim_PaymentType;
    EXEC ETL_Load_Dim_OrderStatus;
    EXEC ETL_Load_Dim_Seller;
    EXEC ETL_Load_Dim_Product;
    EXEC ETL_Load_Dim_Customer;
    EXEC ETL_Load_Dim_Date
    EXEC ETL_Load_Fact_Order;
    EXEC ETL_Load_Fact_Payment;

  