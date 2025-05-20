CREATE TABLE `projeto-1-dw.bronze.sales` (
  date DATE NOT NULL,
  client STRING NOT NULL,
  product STRING NOT NULL,
  qntd INT64 NOT NULL,
  value NUMERIC NOT NULL,
  status STRING NOT NULL
);

CREATE TABLE `projeto-1-dw.silver.sales` (
  date DATE NOT NULL,
  client STRING NOT NULL,
  product STRING NOT NULL,
  qntd INT64 NOT NULL,
  value NUMERIC NOT NULL,
  status STRING NOT NULL
);

CREATE TABLE `projeto-1-dw.gold.sales_per_month` (
  year INT64 NOT NULL,
  month INT64 NOT NULL,
  qntd INT64 NOT NULL,
  value NUMERIC NOT NULL
);
