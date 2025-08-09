DECLARE table_exists BOOL;

-- Check if table exists
SET table_exists = EXISTS (
  SELECT 1
  FROM silver.INFORMATION_SCHEMA.TABLES
  WHERE table_name = 'voting_section_details'
);

-- if table doesnt exists, create it
IF NOT table_exists THEN

  CREATE TABLE silver.voting_section_details
  PARTITION BY year_partition
  AS 
  SELECT
    DATE({year}, 1, 1) as year_partition,
    CURRENT_TIMESTAMP() AS insert_datetime,
    ANO_ELEICAO AS election_year,
    NR_TURNO AS turn_number,
    CD_ELEICAO AS election_code,
    DS_ELEICAO AS election_description,
    DT_ELEICAO AS election_date,
    SG_UF AS state_code,
    SG_UE AS election_unit_code,
    NM_UE AS election_unit_name,
    NR_ZONA as election_zone_code,
    NR_SECAO as election_session_code,
    CD_CARGO as position_code,
    DS_CARGO as position_description,
    QT_APTOS as quantity_eligible_votes,
    QT_COMPARECIMENTO as quantity_turnout_votes,
    QT_ABSTENCOES as quantity_abstentions_votes,
    QT_VOTOS_NOMINAIS as quantity_nominal_votes,
    QT_VOTOS_BRANCOS as quantity_blank_votes,
    QT_VOTOS_NULOS as quantity_null_votes,
    QT_VOTOS_LEGENDA as quantity_party_votes,
    QT_VOTOS_ANULADOS_APU_SEP as quantity_judicial_annulled_votes
  FROM bronze.voting_section_details
  WHERE year_partition = DATE({year}, 1, 1)
  AND ANO_ELEICAO = {year}
  AND CD_TIPO_ELEICAO = 2
  QUALIFY ROW_NUMBER() OVER(PARTITION BY CD_ELEICAO,SG_UE,NR_ZONA,NR_SECAO,CD_CARGO ORDER BY CD_CARGO)=1;

-- if table exists, delete data from partition and insert new data
ELSE

  DELETE FROM silver.voting_section_details
  WHERE year_partition = DATE({year}, 1, 1);

  INSERT INTO silver.voting_section_details
  SELECT
    DATE({year}, 1, 1) as year_partition,
    CURRENT_TIMESTAMP() AS insert_datetime,
    ANO_ELEICAO AS election_year,
    NR_TURNO AS turn_number,
    CD_ELEICAO AS election_code,
    DS_ELEICAO AS election_description,
    DT_ELEICAO AS election_date,
    SG_UF AS state_code,
    SG_UE AS election_unit_code,
    NM_UE AS election_unit_name,
    NR_ZONA as election_zone_code,
    NR_SECAO as election_session_code,
    CD_CARGO as position_code,
    DS_CARGO as position_description,
    QT_APTOS as quantity_eligible_votes,
    QT_COMPARECIMENTO as quantity_turnout_votes,
    QT_ABSTENCOES as quantity_abstentions_votes,
    QT_VOTOS_NOMINAIS as quantity_nominal_votes,
    QT_VOTOS_BRANCOS as quantity_blank_votes,
    QT_VOTOS_NULOS as quantity_null_votes,
    QT_VOTOS_LEGENDA as quantity_party_votes,
    QT_VOTOS_ANULADOS_APU_SEP as quantity_judicial_annulled_votes
  FROM bronze.voting_section_details
  WHERE year_partition = DATE({year}, 1, 1)
  AND ANO_ELEICAO = {year}
  AND CD_TIPO_ELEICAO = 2
  QUALIFY ROW_NUMBER() OVER(PARTITION BY CD_ELEICAO,SG_UE,NR_ZONA,NR_SECAO,CD_CARGO ORDER BY CD_CARGO)=1;

END IF;
