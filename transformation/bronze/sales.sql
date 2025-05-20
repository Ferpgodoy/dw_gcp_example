drop table if exists stage.sales;

CREATE OR REPLACE EXTERNAL TABLE stage.sales
OPTIONS (
  format = 'JSON',
  uris = ['gs://{bucket}/{file_path}']
);

delete from bronze.sales
where date = '{data_agendamento}';

INSERT INTO bronze.sales (date, client, product, qntd, value,status)
SELECT
  '{data_agendamento}',
  cliente,
  produto,
  quantidade,
  CAST(valor AS NUMERIC),
  'teste' as status
FROM stage.sales;
