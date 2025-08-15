DECLARE table_exists BOOL;

-- Check if table exists
SET table_exists = EXISTS (
  SELECT 1
  FROM gold.INFORMATION_SCHEMA.TABLES
  WHERE table_name = 'positions'
);

-- if table doesnt exists, create it
IF NOT table_exists THEN

  CREATE TABLE gold.positions
  PARTITION BY year_partition AS
  SELECT
    DATE({year}, 1, 1) AS year_partition,
    CURRENT_TIMESTAMP() AS insert_datetime,
    election_year,
    election_code,
    election_description,
    election_date,
    inauguration_date,
    state_code,
    election_unit_code,
    election_unit_name,
    position_code,
    position_description,
    quantity_positions
  FROM silver.positions
  WHERE year_partition = DATE({year}, 1, 1);

-- if table exists, delete data from partition and insert new data
ELSE

  DELETE FROM gold.positions
  WHERE year_partition = DATE({year}, 1, 1);

  INSERT INTO gold.positions
  SELECT
    DATE({year}, 1, 1) AS year_partition,
    CURRENT_TIMESTAMP() AS insert_datetime,
    election_year,
    election_code,
    election_description,
    election_date,
    inauguration_date,
    state_code,
    election_unit_code,
    election_unit_name,
    position_code,
    position_description,
    quantity_positions
  FROM silver.positions
  WHERE year_partition = DATE({year}, 1, 1);

END IF;
