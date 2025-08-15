DECLARE table_exists BOOL;

-- Check if table exists
SET table_exists = EXISTS (
  SELECT 1
  FROM silver.INFORMATION_SCHEMA.TABLES
  WHERE table_name = 'candidate_social_media'
);

-- if table doesnt exists, create it
IF NOT table_exists THEN

  CREATE TABLE silver.candidate_social_media
  PARTITION BY year_partition
  AS 
  SELECT 
    DATE({year}, 1, 1) as year_partition,
    CURRENT_TIMESTAMP() AS insert_datetime,
    AA_ELEICAO AS election_code,
    SQ_CANDIDATO AS candidate_code,
    NR_ORDEM_REDE_SOCIAL as social_media_number,
    DS_URL as social_media_url
  FROM bronze.candidate_social_media ca
  WHERE year_partition = DATE({year}, 1, 1)
  AND AA_ELEICAO = {year}
  AND CD_TIPO_ELEICAO = 2
  QUALIFY ROW_NUMBER() OVER (PARTITION BY CD_ELEICAO, SQ_CANDIDATO, NR_ORDEM_REDE_SOCIAL ORDER BY NR_ORDEM_REDE_SOCIAL) = 1;

-- if table exists, delete data from partition and insert new data
ELSE

  DELETE FROM silver.candidate_social_media
  WHERE year_partition = DATE({year}, 1, 1);

  INSERT INTO silver.candidate_social_media
  SELECT 
    DATE({year}, 1, 1) as year_partition,
    CURRENT_TIMESTAMP() AS insert_datetime,
    AA_ELEICAO AS election_code,
    SQ_CANDIDATO AS candidate_code,
    NR_ORDEM_REDE_SOCIAL as social_media_number,
    DS_URL as social_media_url
  FROM bronze.candidate_social_media ca
  WHERE year_partition = DATE({year}, 1, 1)
  AND AA_ELEICAO = {year}
  AND CD_TIPO_ELEICAO = 2
  QUALIFY ROW_NUMBER() OVER (PARTITION BY CD_ELEICAO, SQ_CANDIDATO, NR_ORDEM_REDE_SOCIAL ORDER BY NR_ORDEM_REDE_SOCIAL) = 1;


END IF;
