DELETE FROM silver.sales
WHERE sale_date = '{schedule_date}';

INSERT INTO silver.sales (
  sale_date,
  sale_id,
  sale_timestamp,
  customer_name,
  customer_email,
  product_name,
  quantity,
  unit_price,
  total_price,
  payment_method,
  order_status,
  is_first_purchase
)
SELECT
  -- Tipagem de data
  date AS sale_date,

  -- Tipagem e validação básica
  SAFE_CAST(sale_id AS STRING) AS sale_id,
  SAFE_CAST(datetime AS TIMESTAMP) AS sale_timestamp,

  -- Customer info
  SAFE_CAST(customer.name AS STRING) AS customer_name,
  NULLIF(customer.email, '') AS customer_email,

  -- Produto e venda
  SAFE_CAST(product.name AS STRING) AS product_name,
  SAFE_CAST(quantity AS INT64) AS quantity,
  SAFE_CAST(unit_price AS FLOAT64) AS unit_price,
  SAFE_CAST(total_price AS FLOAT64) AS total_price,

  -- Pagamento
  SAFE_CAST(payment_method AS STRING) AS payment_method,
  SAFE_CAST(status AS STRING) AS order_status,

  -- Flags
  SAFE_CAST(is_first_purchase AS BOOL) AS is_first_purchase

FROM bronze.sales

-- Filtro de qualidade: status válido, datas correspondentes
WHERE SAFE_CAST(status AS STRING) != 'Cancelled'
  AND DATE(datetime) = DATE('{schedule_date}')
