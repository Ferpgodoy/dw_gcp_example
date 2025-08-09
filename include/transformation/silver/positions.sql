DECLARE table_exists BOOL;

-- Check if table exists
SET table_exists = EXISTS (
  SELECT 1
  FROM silver.INFORMATION_SCHEMA.TABLES
  WHERE table_name = 'positions'
);

-- if table doesnt exists, create it
IF NOT table_exists THEN

  CREATE TABLE silver.positions
  PARTITION BY year_partition AS
  SELECT
    DATE({year}, 1, 1) AS year_partition,
    CURRENT_TIMESTAMP() AS insert_datetime,
    ANO_ELEICAO AS election_year,
    CD_ELEICAO AS election_code,
    DS_ELEICAO AS election_description,
    DT_ELEICAO AS election_date,
    DT_POSSE AS inauguration_date,
    SG_UF AS state_code,
    SG_UE AS election_unit_code,
    NM_UE AS election_unit_name,
    CD_CARGO AS position_code,
    DS_CARGO AS position_description,
    QT_VAGA AS quantity_positions
  FROM bronze.positions
  WHERE year_partition = DATE({year}, 1, 1)
  AND ANO_ELEICAO = {year}
  AND CD_TIPO_ELEICAO = 2
  QUALIFY ROW_NUMBER() OVER(PARTITION BY CD_ELEICAO,SG_UE,CD_CARGO)=1;

-- if table exists, delete data from partition and insert new data
ELSE

  DELETE FROM silver.positions
  WHERE year_partition = DATE({year}, 1, 1);

  INSERT INTO silver.positions
  SELECT
    DATE({year}, 1, 1) AS year_partition,
    CURRENT_TIMESTAMP() AS insert_datetime,
    ANO_ELEICAO AS election_year,
    CD_ELEICAO AS election_code,
    DS_ELEICAO AS election_description,
    DT_ELEICAO AS election_date,
    DT_POSSE AS inauguration_date,
    SG_UF AS state_code,
    SG_UE AS election_unit_code,
    NM_UE AS election_unit_name,
    CD_CARGO AS position_code,
    DS_CARGO AS position_description,
    QT_VAGA AS quantity_positions
  FROM bronze.positions
  WHERE year_partition = DATE({year}, 1, 1)
  AND ANO_ELEICAO = {year}
  AND CD_TIPO_ELEICAO = 2
  QUALIFY ROW_NUMBER() OVER(PARTITION BY CD_ELEICAO,SG_UE,CD_CARGO)=1;

END IF;
