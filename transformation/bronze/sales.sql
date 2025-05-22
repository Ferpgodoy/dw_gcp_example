CREATE OR REPLACE EXTERNAL TABLE stage.sales
OPTIONS (
  format = 'JSON',
  uris = ['gs://{bucket}/{file_path}']
);

DELETE FROM bronze.sales
WHERE DATE = '{schedule_date}';


INSERT INTO bronze.sales (
  date, 
  campaign, 
  device_type, 
  channel, 
  total_price, 
  quantity, 
  is_first_purchase, 
  shipping, 
  status, 
  payment_method, 
  discount_percent, 
  customer, 
  currency, 
  product, 
  unit_price, 
  referral_source, 
  datetime, 
  sales_rep, 
  sale_id 
)
SELECT
  DATE '{schedule_date}' as date,
  campaign, 
  device_type, 
  channel, 
  total_price, 
  quantity, 
  is_first_purchase, 
  shipping, 
  status, 
  payment_method, 
  discount_percent, 
  customer, 
  currency, 
  product, 
  unit_price, 
  referral_source, 
  datetime, 
  sales_rep, 
  sale_id
FROM stage.sales;
