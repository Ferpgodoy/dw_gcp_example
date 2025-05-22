-- Usando uma data como string (ex: 'schedule_date') para extrair ano e mês
DELETE FROM gold.sales_per_month
WHERE year = EXTRACT(YEAR FROM DATE '{schedule_date}')
  AND month = EXTRACT(MONTH FROM DATE '{schedule_date}');


-- Insere os dados agregados
INSERT INTO gold.sales_per_month (year,month, quantity, total_price)
SELECT
  EXTRACT(YEAR FROM DATE '{schedule_date}') as year,
  EXTRACT(MONTH FROM DATE '{schedule_date}') as month,
  COALESCE(SUM(quantity),0) AS quantity,
  COALESCE(SUM(total_price),0)  AS total_price
FROM silver.sales
WHERE EXTRACT(YEAR FROM sale_date) = EXTRACT(year FROM DATE '{schedule_date}')
  AND EXTRACT(MONTH FROM sale_date) = EXTRACT(MONTH FROM DATE '{schedule_date}');