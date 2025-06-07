DROP TABLE IF EXISTS `{PROJECT_ID}.bronze.sales`;

CREATE TABLE `{PROJECT_ID}.bronze.sales` (
  date DATE,
  campaign STRING,
  device_type STRING,
  channel STRING,
  total_price FLOAT64,
  quantity INT64,
  is_first_purchase BOOL,
  shipping STRUCT<
    shipping_cost FLOAT64,
    shipping_method STRING,
    address STRING,
    country STRING,
    state STRING,
    city STRING,
    zip_code INT64
  >,
  status STRING,
  payment_method STRING,
  discount_percent INT64,
  customer STRUCT<
    loyalty_points INT64,
    phone STRING,
    email STRING,
    gender STRING,
    birth_date DATE,
    name STRING,
    customer_id STRING
  >,
  currency STRING,
  product STRUCT<
    warranty_years INT64,
    brand STRING,
    name STRING,
    sku STRING,
    category STRING,
    product_id STRING
  >,
  unit_price FLOAT64,
  referral_source STRING,
  datetime TIMESTAMP,
  sales_rep STRUCT<
    name STRING,
    sales_rep_id STRING
  >,
  sale_id STRING
)
PARTITION BY date;

DROP TABLE IF EXISTS {PROJECT_ID}.silver.sales;

CREATE TABLE {PROJECT_ID}.silver.sales (
  sale_date DATE,
  sale_id STRING,
  sale_timestamp TIMESTAMP,
  customer_name STRING,
  customer_email STRING,
  product_name STRING,
  quantity INT64,
  unit_price FLOAT64,
  total_price FLOAT64,
  payment_method STRING,
  order_status STRING,
  is_first_purchase BOOL
)
PARTITION BY sale_date
CLUSTER BY sale_id, customer_email, product_name;

DROP TABLE IF EXISTS {PROJECT_ID}.gold.sales_per_month;

CREATE TABLE {PROJECT_ID}.gold.sales_per_month (
  partition_year_month DATE,  
  year INT64,
  month INT64,
  quantity INT64,
  total_price FLOAT64
)
PARTITION BY partition_year_month
CLUSTER BY year, month;