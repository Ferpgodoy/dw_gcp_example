DECLARE table_exists BOOL;

-- Check if table exists
SET table_exists = EXISTS (
  SELECT 1
  FROM silver.INFORMATION_SCHEMA.TABLES
  WHERE table_name = 'electorate_profile'
);

-- if table doesnt exists, create it
IF NOT table_exists THEN

  CREATE TABLE silver.electorate_profile
  PARTITION BY year_partition
  AS 
  SELECT
    DATE({year}, 1, 1) AS year_partition,
    CURRENT_TIMESTAMP() AS insert_datetime,
    SG_UF as state_code,
    CD_MUNICIPIO as city_code,
    NM_MUNICIPIO as city_name,
    NR_ZONA as election_zone_number,
    CD_GENERO as gender_code,
    DS_GENERO as gender_description,
    CD_ESTADO_CIVIL as marital_status_code,
    DS_ESTADO_CIVIL as marital_status_description,
    CD_FAIXA_ETARIA as age_range_code,
    DS_FAIXA_ETARIA as age_range_description,
    CD_GRAU_ESCOLARIDADE as education_level_code,
    DS_GRAU_ESCOLARIDADE as education_level_description,
    CD_RACA_COR as race_code,
    DS_RACA_COR as race_description,
    CD_IDENTIDADE_GENERO as gender_identity_code,
    DS_IDENTIDADE_GENERO as gender_identity_description,
    CD_QUILOMBOLA as quilombo_community_code,
    DS_QUILOMBOLA as quilombo_community_description,
    CD_INTERPRETE_LIBRAS as libras_interpreter_code,
    DS_INTERPRETE_LIBRAS as libras_interpreter_description,
    QT_ELEITORES_PERFIL as quantity_electors,
    QT_ELEITORES_BIOMETRIA as quantity_biometric_electors,
    QT_ELEITORES_DEFICIENCIA as quantity_disabled_electors
  FROM bronze.electorate_profile
  WHERE year_partition = DATE({year}, 1, 1)
  AND ANO_ELEICAO = {year};
  
-- if table exists, delete data from partition and insert new data
ELSE

  DELETE FROM silver.electorate_profile
  WHERE year_partition = DATE({year}, 1, 1);

  INSERT INTO silver.electorate_profile
  SELECT
    DATE({year}, 1, 1) AS year_partition,
    CURRENT_TIMESTAMP() AS insert_datetime,
    SG_UF as state_code,
    CD_MUNICIPIO as city_code,
    NM_MUNICIPIO as city_name,
    NR_ZONA as election_zone_number,
    CD_GENERO as gender_code,
    DS_GENERO as gender_description,
    CD_ESTADO_CIVIL as marital_status_code,
    DS_ESTADO_CIVIL as marital_status_description,
    CD_FAIXA_ETARIA as age_range_code,
    DS_FAIXA_ETARIA as age_range_description,
    CD_GRAU_ESCOLARIDADE as education_level_code,
    DS_GRAU_ESCOLARIDADE as education_level_description,
    CD_RACA_COR as race_code,
    DS_RACA_COR as race_description,
    CD_IDENTIDADE_GENERO as gender_identity_code,
    DS_IDENTIDADE_GENERO as gender_identity_description,
    CD_QUILOMBOLA as quilombo_community_code,
    DS_QUILOMBOLA as quilombo_community_description,
    CD_INTERPRETE_LIBRAS as libras_interpreter_code,
    DS_INTERPRETE_LIBRAS as libras_interpreter_description,
    QT_ELEITORES_PERFIL as quantity_electors,
    QT_ELEITORES_BIOMETRIA as quantity_biometric_electors,
    QT_ELEITORES_DEFICIENCIA as quantity_disabled_electors
  FROM bronze.electorate_profile
  WHERE year_partition = DATE({year}, 1, 1)
  AND ANO_ELEICAO = {year};

END IF;
