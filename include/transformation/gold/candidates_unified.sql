DECLARE table_exists BOOL;

-- Check if the table 'candidates_unified' exists in the 'gold' dataset
SET table_exists = EXISTS (
  SELECT 1
  FROM gold.INFORMATION_SCHEMA.TABLES
  WHERE table_name = 'candidates_unified'
);

-- If the table does not exist, create it partitioned by voter_code, based on query t1 (you can replace t1 by your actual query)
IF NOT table_exists THEN

  CREATE TABLE gold.candidates_unified AS
  WITH t1 AS (
      SELECT 
          c.*, 
          -- Sum of asset values per candidate (nulls treated as 0)
          SUM(COALESCE(asset.asset_value, 0)) AS asset_value
      FROM gold.candidates_scd c
      LEFT JOIN UNNEST(candidate_assets) AS asset
      WHERE turn_number = 1
      GROUP BY ALL
  )

  SELECT
      MIN(candidate_full_name) AS candidate_full_name,
      MIN(candidate_short_name) AS candidate_short_name,
      MIN(birth_date) AS birth_date,
      MIN(birth_state) AS birth_state,
      voter_code,
      ARRAY_AGG(
          STRUCT(
              election_year,
              election_description,
              state_code,
              election_unit_code,
              election_unit_name,
              position_code,
              position_description,
              candidate_code,
              party_number,
              party_name,
              asset_value
          )
      ) AS candidate_evolution
  FROM t1
  GROUP BY voter_code;

-- If the table exists, delete all data and insert new data
ELSE

  TRUNCATE TABLE gold.candidates_unified;

  INSERT INTO gold.candidates_unified

  WITH t1 AS (
      SELECT 
          c.*, 
          SUM(COALESCE(asset.asset_value, 0)) AS asset_value
      FROM gold.candidates_scd c
      LEFT JOIN UNNEST(candidate_assets) AS asset
      WHERE turn_number = 1
      GROUP BY ALL
  )

  SELECT
      MIN(candidate_full_name) AS candidate_full_name,
      MIN(candidate_short_name) AS candidate_short_name,
      MIN(birth_date) AS birth_date,
      MIN(birth_state) AS birth_state,
      voter_code,
      ARRAY_AGG(
          STRUCT(
              election_year,
              election_description,
              state_code,
              election_unit_code,
              election_unit_name,
              position_code,
              position_description,
              candidate_code,
              party_number,
              party_name,
              asset_value
          )
      ) AS candidate_evolution
  FROM t1
  GROUP BY voter_code;

END IF;
