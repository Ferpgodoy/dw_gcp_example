DECLARE table_exists BOOL;

-- Check if table exists
SET table_exists = EXISTS (
  SELECT 1
  FROM gold.INFORMATION_SCHEMA.TABLES
  WHERE table_name = 'electorate_profile_aggregated'
);

-- if table doesnt exists, create it
IF NOT table_exists THEN

  CREATE TABLE gold.electorate_profile_aggregated
  PARTITION BY year_partition
  AS 
  SELECT
    DATE({year}, 1, 1) AS year_partition,
    CURRENT_TIMESTAMP() AS insert_datetime,
    state_code,
    city_code,
    city_name,
    election_zone_number,
    gender_code,
    gender_description,
    age_range_code,
    age_range_description,
    education_level_code,
    education_level_description,
    race_code,
    race_description,
    SUM(quantity_electors) as quantity_electors,
    SUM(quantity_biometric_electors) as quantity_biometric_electors,
    SUM(quantity_disabled_electors) as quantity_disabled_electors
  FROM silver.electorate_profile
  WHERE year_partition = DATE({year}, 1, 1)
  GROUP BY ALL;
  
-- if table exists, delete data from partition and insert new data
ELSE

  DELETE FROM gold.electorate_profile_aggregated
  WHERE year_partition = DATE({year}, 1, 1);

  INSERT INTO gold.electorate_profile_aggregated
  SELECT
    DATE({year}, 1, 1) AS year_partition,
    CURRENT_TIMESTAMP() AS insert_datetime,
    state_code,
    city_code,
    city_name,
    election_zone_number,
    gender_code,
    gender_description,
    age_range_code,
    age_range_description,
    education_level_code,
    education_level_description,
    race_code,
    race_description,
    SUM(quantity_electors) as quantity_electors,
    SUM(quantity_biometric_electors) as quantity_biometric_electors,
    SUM(quantity_disabled_electors) as quantity_disabled_electors
  FROM silver.electorate_profile
  WHERE year_partition = DATE({year}, 1, 1)
  GROUP BY ALL;

END IF;
