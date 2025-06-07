-- Define a data de particionamento, primeiro dia do mês
DECLARE variable DATE DEFAULT DATE_TRUNC(DATE('{schedule_date}'), MONTH);

-- Deleta os dados na partição do mês específico
DELETE FROM gold.sales_per_month
WHERE partition_year_month = variable;

-- Insere os dados agregados para a partição do mês
INSERT INTO gold.sales_per_month (partition_year_month, year, month, quantity, total_price)
SELECT
  variable,
  EXTRACT(YEAR FROM variable) AS year,
  EXTRACT(MONTH FROM variable) AS month,
  COALESCE(SUM(quantity), 0) AS quantity,
  COALESCE(SUM(total_price), 0) AS total_price
FROM silver.sales
WHERE DATE_TRUNC(sale_date, MONTH) = variable;
