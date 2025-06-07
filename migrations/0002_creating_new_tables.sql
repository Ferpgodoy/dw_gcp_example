CREATE TABLE `{PROJECT_ID}.bronze.sales` (
  date DATE NOT NULL,
  client STRING NOT NULL,
  product STRING NOT NULL,
  qntd INT64 NOT NULL,
  value NUMERIC NOT NULL,
  status STRING NOT NULL
);

CREATE TABLE `{PROJECT_ID}.silver.sales` (
  date DATE NOT NULL,
  client STRING NOT NULL,
  product STRING NOT NULL,
  qntd INT64 NOT NULL,
  value NUMERIC NOT NULL,
  status STRING NOT NULL
);

CREATE TABLE `{PROJECT_ID}.gold.sales_per_month` (
  year INT64 NOT NULL,
  month INT64 NOT NULL,
  qntd INT64 NOT NULL,
  value NUMERIC NOT NULL
);
