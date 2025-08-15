DECLARE table_exists BOOL;

-- Check if table exists
SET table_exists = EXISTS (
  SELECT 1
  FROM silver.INFORMATION_SCHEMA.TABLES
  WHERE table_name = 'candidate_assets'
);

-- if table doesnt exists, create it
IF NOT table_exists THEN

  CREATE TABLE silver.candidate_assets
  PARTITION BY year_partition
  AS 
  SELECT 
    DATE({year}, 1, 1) as year_partition,
    CURRENT_TIMESTAMP() AS insert_datetime,
    CD_ELEICAO AS election_code,
    SQ_CANDIDATO AS candidate_code,
    NR_ORDEM_BEM_CANDIDATO as candidate_asset_number,
    CD_TIPO_BEM_CANDIDATO as asset_type_code,
    DS_TIPO_BEM_CANDIDATO as asset_type_description,
    DS_BEM_CANDIDATO as asset_description,
    VR_BEM_CANDIDATO as asset_value
  FROM bronze.candidate_assets ca
  WHERE year_partition = DATE({year}, 1, 1)
  AND ANO_ELEICAO = {year}
  AND CD_TIPO_ELEICAO = 2
  QUALIFY ROW_NUMBER() OVER (PARTITION BY CD_ELEICAO, SQ_CANDIDATO, NR_ORDEM_BEM_CANDIDATO ORDER BY NR_ORDEM_BEM_CANDIDATO) = 1;

-- if table exists, delete data from partition and insert new data
ELSE

  DELETE FROM silver.candidate_assets
  WHERE year_partition = DATE({year}, 1, 1);

  INSERT INTO silver.candidate_assets
  SELECT 
    DATE({year}, 1, 1) as year_partition,
    CURRENT_TIMESTAMP() AS insert_datetime,
    CD_ELEICAO AS election_code,
    SQ_CANDIDATO AS candidate_code,
    NR_ORDEM_BEM_CANDIDATO as candidate_asset_number,
    CD_TIPO_BEM_CANDIDATO as asset_type_code,
    DS_TIPO_BEM_CANDIDATO as asset_type_description,
    DS_BEM_CANDIDATO as asset_description,
    VR_BEM_CANDIDATO as asset_value
  FROM bronze.candidate_assets ca
  WHERE year_partition = DATE({year}, 1, 1)
  AND ANO_ELEICAO = {year}
  AND CD_TIPO_ELEICAO = 2
  QUALIFY ROW_NUMBER() OVER (PARTITION BY CD_ELEICAO, SQ_CANDIDATO, NR_ORDEM_BEM_CANDIDATO ORDER BY NR_ORDEM_BEM_CANDIDATO) = 1;


END IF;
