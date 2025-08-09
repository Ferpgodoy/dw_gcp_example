DECLARE table_exists BOOL;

-- Create external table with ISO-8859-1 encoding
CREATE OR REPLACE EXTERNAL TABLE raw.candidate_assets
OPTIONS (
  format = 'CSV',
  uris = ['gs://projeto_1_dw_raw/eleicoes/bem_candidato/{year}/*.csv'],
  skip_leading_rows = 1,
  field_delimiter = ';',
  allow_quoted_newlines = TRUE,
  encoding = 'ISO-8859-1'
);

-- Check if the table bronze.candidate_assets exists
SET table_exists = EXISTS (
  SELECT 1
  FROM bronze.INFORMATION_SCHEMA.TABLES
  WHERE table_name = 'candidate_assets'
);

-- If the table does not exist, create it with partitioning by year_partition (DATE)
IF NOT table_exists THEN

  CREATE TABLE bronze.candidate_assets
  PARTITION BY year_partition AS
  SELECT
    *,
    DATE({year}, 1, 1) AS year_partition,
    CURRENT_TIMESTAMP() AS insert_datetime
  FROM raw.candidate_assets
  QUALIFY RANK() OVER (ORDER BY _FILE_NAME DESC) = 1;

-- If the table already exists, update the partition for the given year
ELSE

  DELETE FROM bronze.candidate_assets
  WHERE year_partition = DATE({year}, 1, 1);

  INSERT INTO bronze.candidate_assets
  SELECT
    *,
    DATE({year}, 1, 1) AS year_partition,
    CURRENT_TIMESTAMP() AS insert_datetime
  FROM raw.candidate_assets
  QUALIFY RANK() OVER (ORDER BY _FILE_NAME DESC) = 1;

END IF;
