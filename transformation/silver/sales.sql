delete from silver.sales
where date = '{data_agendamento}';

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
and date = '{data_agendamento}';
