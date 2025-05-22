delete from silver.sales
where date = '{schedule_date}';

INSERT INTO bronze.sales (date, client, product, qntd, value,status)
SELECT
  date,
  client,
  product,
  qntd,
  value,
  status
FROM bronze.sales
where status = 'teste'
and date = '{schedule_date}';
