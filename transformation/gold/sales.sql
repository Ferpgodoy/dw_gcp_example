-- Usando uma data como string (ex: 'data_agendamento') para extrair ano e mês
DELETE FROM gold.sales_per_month
WHERE year = EXTRACT(YEAR FROM DATE '{data_agendamento}')
  AND month = EXTRACT(MONTH FROM DATE '{data_agendamento}');


-- Insere os dados agregados
INSERT INTO gold.sales_per_month (year,month, qntd, value)
SELECT
  EXTRACT(YEAR FROM DATE '{data_agendamento}'),
  EXTRACT(MONTH FROM DATE '{data_agendamento}'),
  COALESCE(SUM(qntd),0) AS qntd,
  COALESCE(SUM(value),0)  AS value
FROM silver.sales
WHERE EXTRACT(YEAR FROM date) = EXTRACT(year FROM DATE '{data_agendamento}')
  AND EXTRACT(MONTH FROM date) = EXTRACT(MONTH FROM DATE '{data_agendamento}');