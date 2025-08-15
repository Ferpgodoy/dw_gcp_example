DECLARE table_exists BOOL;

-- Check if table exists
SET table_exists = EXISTS (
  SELECT 1
  FROM gold.INFORMATION_SCHEMA.TABLES
  WHERE table_name = 'candidates_scd'
);

-- if table doesnt exists, create it
IF NOT table_exists THEN

  CREATE TABLE gold.candidates_scd
  PARTITION BY year_partition
  AS 
  WITH t1 AS (
  SELECT
    election_year,
    turn_number,
    election_code,
    election_description,
    election_date,
    state_code,
    election_unit_code,
    election_unit_name,
    position_code,
    position_description,
    candidate_code,
    candidate_full_name,
    candidate_short_name,
    association_type,
    party_number,
    party_code,
    party_name,
    coalition_code,
    coalition_name,
    coalition_composition,
    birth_state,
    birth_date,
    voter_code
  FROM silver.candidates   
  WHERE year_partition = DATE({year}, 1, 1)
  ),

  t2 as (
    SELECT 
      election_code,
      candidate_code,
      ARRAY_AGG(STRUCT(
        candidate_asset_number,
        asset_type_code,
        asset_type_description,
        asset_description,
        asset_value
        )) as candidate_assets
    FROM silver.candidate_assets 
    WHERE year_partition = DATE({year}, 1, 1)
    GROUP BY 1,2
  ),

  t3 as (
    SELECT 
      election_code,
      candidate_code,
      ARRAY_AGG(STRUCT(
        social_media_number,
        social_media_url
        )) as social_media
    FROM silver.candidate_social_media
    WHERE year_partition = DATE({year}, 1, 1)
    GROUP BY 1,2
  ),

  t4 as (
    SELECT 
      election_code,
      candidate_code,
      ARRAY_AGG(STRUCT(
        revocation_number,
        reason_type,
        reason_type_description,
        reason_code,
        reason_description
        )) as revocation_reason
    FROM silver.revocation_reason 
    WHERE year_partition = DATE({year}, 1, 1)
    GROUP BY 1,2
  ),

  t5 as (
  SELECT 
    DATE({year}, 1, 1) as year_partition,
    CURRENT_TIMESTAMP() AS insert_datetime,
    c.*,
    ca.candidate_assets,
    csm.social_media,
    rr.revocation_reason
  FROM t1 c
  LEFT JOIN t2 ca
  ON c.candidate_code = ca.candidate_code
  AND c.election_code = ca.election_code
  LEFT JOIN t3 csm
  ON c.candidate_code = csm.candidate_code
  AND c.election_code = csm.election_code
  LEFT JOIN t4 rr
  ON c.candidate_code = rr.candidate_code
  AND c.election_code = rr.election_code
  )

  SELECT * FROM t5;

-- if table exists, delete data from partition and insert new data
ELSE

  DELETE FROM gold.candidates_scd
  WHERE year_partition = DATE({year}, 1, 1);

  INSERT INTO gold.candidates_scd
  WITH t1 AS (
  SELECT
    election_year,
    turn_number,
    election_code,
    election_description,
    election_date,
    state_code,
    election_unit_code,
    election_unit_name,
    position_code,
    position_description,
    candidate_code,
    candidate_full_name,
    candidate_short_name,
    association_type,
    party_number,
    party_code,
    party_name,
    coalition_code,
    coalition_name,
    coalition_composition,
    birth_state,
    birth_date,
    voter_code
  FROM silver.candidates   
  WHERE year_partition = DATE({year}, 1, 1)
  ),

  t2 as (
    SELECT 
      election_code,
      candidate_code,
      ARRAY_AGG(STRUCT(
        candidate_asset_number,
        asset_type_code,
        asset_type_description,
        asset_description,
        asset_value
        )) as candidate_assets
    FROM silver.candidate_assets 
    WHERE year_partition = DATE({year}, 1, 1)
    GROUP BY 1,2
  ),

  t3 as (
    SELECT 
      election_code,
      candidate_code,
      ARRAY_AGG(STRUCT(
        social_media_number,
        social_media_url
        )) as social_media
    FROM silver.candidate_social_media
    WHERE year_partition = DATE({year}, 1, 1)
    GROUP BY 1,2
  ),

  t4 as (
    SELECT 
      election_code,
      candidate_code,
      ARRAY_AGG(STRUCT(
        revocation_number,
        reason_type,
        reason_type_description,
        reason_code,
        reason_description
        )) as revocation_reason
    FROM silver.revocation_reason 
    WHERE year_partition = DATE({year}, 1, 1)
    GROUP BY 1,2
  ),

  t5 as (
  SELECT 
    DATE({year}, 1, 1) as year_partition,
    CURRENT_TIMESTAMP() AS insert_datetime,
    c.*,
    ca.candidate_assets,
    csm.social_media,
    rr.revocation_reason
  FROM t1 c
  LEFT JOIN t2 ca
  ON c.candidate_code = ca.candidate_code
  AND c.election_code = ca.election_code
  LEFT JOIN t3 csm
  ON c.candidate_code = csm.candidate_code
  AND c.election_code = csm.election_code
  LEFT JOIN t4 rr
  ON c.candidate_code = rr.candidate_code
  AND c.election_code = rr.election_code
  )

  SELECT * FROM t5;

END IF;
