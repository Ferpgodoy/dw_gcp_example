DECLARE table_exists BOOL;

-- Create external table with ISO-8859-1 encoding
CREATE OR REPLACE EXTERNAL TABLE raw.voting_section_details
OPTIONS (
  format = 'CSV',
  uris = ['gs://{bucket_name}/eleicoes/detalhe_votacao_secao/{year}/*.csv'],
  skip_leading_rows = 1,
  field_delimiter = ';',
  allow_quoted_newlines = TRUE,
  encoding = 'ISO-8859-1'
);

-- Check if the table bronze.voting_section_details exists
SET table_exists = EXISTS (
  SELECT 1
  FROM bronze.INFORMATION_SCHEMA.TABLES
  WHERE table_name = 'voting_section_details'
);

-- If the table does not exist, create it with partitioning by year_partition (DATE)
IF NOT table_exists THEN

  CREATE TABLE bronze.voting_section_details
  PARTITION BY year_partition AS
  SELECT
    *,
    DATE({year}, 1, 1) AS year_partition,
    CURRENT_TIMESTAMP() AS insert_datetime
  FROM raw.voting_section_details
  QUALIFY RANK() OVER (ORDER BY _FILE_NAME DESC) = 1;

-- If the table already exists, update the partition for the given year
ELSE

  DELETE FROM bronze.voting_section_details
  WHERE year_partition = DATE({year}, 1, 1);

  INSERT INTO bronze.voting_section_details
  SELECT
    *,
    DATE({year}, 1, 1) AS year_partition,
    CURRENT_TIMESTAMP() AS insert_datetime
  FROM raw.voting_section_details
  QUALIFY RANK() OVER (ORDER BY _FILE_NAME DESC) = 1;

END IF;