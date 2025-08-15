DECLARE table_exists BOOL;

-- Check if table exists
SET table_exists = EXISTS (
  SELECT 1
  FROM silver.INFORMATION_SCHEMA.TABLES
  WHERE table_name = 'revocation_reason'
);

-- if table doesnt exists, create it
IF NOT table_exists THEN

  CREATE TABLE silver.revocation_reason
  PARTITION BY year_partition
  AS 
  SELECT 
    DATE({year}, 1, 1) as year_partition,
    CURRENT_TIMESTAMP() AS insert_datetime,
    CD_ELEICAO AS election_code,
    SQ_CANDIDATO AS candidate_code,
    ROW_NUMBER() OVER(PARTITION BY CD_ELEICAO, SQ_CANDIDATO ORDER BY SQ_CANDIDATO) AS revocation_number,
    TP_MOTIVO as reason_type,
    DS_TP_MOTIVO as reason_type_description,
    CD_MOTIVO as reason_code,
    DS_MOTIVO as reason_description
  FROM bronze.revocation_reason ca
  WHERE year_partition = DATE({year}, 1, 1)
  AND ANO_ELEICAO = {year}
  AND CD_TIPO_ELEICAO = 2;

-- if table exists, delete data from partition and insert new data
ELSE

  DELETE FROM silver.revocation_reason
  WHERE year_partition = DATE({year}, 1, 1);

  INSERT INTO silver.revocation_reason
  SELECT 
    DATE({year}, 1, 1) as year_partition,
    CURRENT_TIMESTAMP() AS insert_datetime,
    CD_ELEICAO AS election_code,
    SQ_CANDIDATO AS candidate_code,
    ROW_NUMBER() OVER(PARTITION BY CD_ELEICAO, SQ_CANDIDATO ORDER BY SQ_CANDIDATO) AS revocation_number,
    TP_MOTIVO as reason_type,
    DS_TP_MOTIVO as reason_type_description,
    CD_MOTIVO as reason_code,
    DS_MOTIVO as reason_description
  FROM bronze.revocation_reason ca
  WHERE year_partition = DATE({year}, 1, 1)
  AND ANO_ELEICAO = {year}
  AND CD_TIPO_ELEICAO = 2;


END IF;
