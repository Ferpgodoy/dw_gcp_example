-- Usando uma data como string (ex: 'schedule_date') para extrair ano e mês
DELETE FROM gold.sales_per_month
WHERE year = EXTRACT(YEAR FROM DATE '{schedule_date}')
  AND month = EXTRACT(MONTH FROM DATE '{schedule_date}');


-- Insere os dados agregados
INSERT INTO gold.sales_per_month (year,month, qntd, value)
SELECT
  EXTRACT(YEAR FROM DATE '{schedule_date}'),
  EXTRACT(MONTH FROM DATE '{schedule_date}'),
  COALESCE(SUM(qntd),0) AS qntd,
  COALESCE(SUM(value),0)  AS value
FROM silver.sales
WHERE EXTRACT(YEAR FROM date) = EXTRACT(year FROM DATE '{schedule_date}')
  AND EXTRACT(MONTH FROM date) = EXTRACT(MONTH FROM DATE '{schedule_date}');