DECLARE table_exists BOOL;

-- Check if table exists
SET table_exists = EXISTS (
  SELECT 1
  FROM silver.INFORMATION_SCHEMA.TABLES
  WHERE table_name = 'candidates'
);

-- if table doesnt exists, create it
IF NOT table_exists THEN

  CREATE TABLE silver.candidates
  PARTITION BY year_partition
  AS 
  SELECT
    DATE({year}, 1, 1) as year_partition,
    CURRENT_TIMESTAMP() AS insert_datetime,
    c.ANO_ELEICAO AS election_year,
    c.NR_TURNO AS turn_number,
    c.CD_ELEICAO AS election_code,
    c.DS_ELEICAO AS election_description,
    c.DT_ELEICAO AS election_date,
    c.SG_UF AS state_code,
    c.SG_UE AS election_unit_code,
    c.NM_UE AS election_unit_name,
    c.CD_CARGO AS position_code,
    c.DS_CARGO AS position_description,
    c.SQ_CANDIDATO AS candidate_code,
    c.NM_CANDIDATO AS candidate_full_name,
    c.NM_URNA_CANDIDATO AS candidate_short_name,
    c.TP_AGREMIACAO AS association_type,
    c.NR_PARTIDO AS party_number,
    c.SG_PARTIDO AS party_code,
    c.NM_PARTIDO AS party_name,
    c.SQ_COLIGACAO AS coalition_code,
    c.NM_COLIGACAO AS coalition_name,
    CASE
      WHEN c.TP_AGREMIACAO = 'COLIGAÇÃO' THEN SPLIT(c.DS_COMPOSICAO_COLIGACAO, ' / ')
      WHEN c.TP_AGREMIACAO IN ('PARTIDO ISOLADO', 'FEDERAÇÃO') THEN [c.DS_COMPOSICAO_COLIGACAO]
      ELSE NULL
    END AS coalition_composition,
    CASE 
      WHEN c.SG_UF_NASCIMENTO = 'Não divulgável' THEN NULL
      ELSE c.SG_UF_NASCIMENTO
    END AS birth_state,
    c.DT_NASCIMENTO AS birth_date,
    CASE 
      WHEN c.NR_TITULO_ELEITORAL_CANDIDATO = -4 THEN NULL
      ELSE c.NR_TITULO_ELEITORAL_CANDIDATO
    END AS voter_code
  FROM bronze.candidates c
  WHERE c.year_partition = DATE({year}, 1, 1)
  AND c.ANO_ELEICAO = {year}
  AND c.CD_TIPO_ELEICAO = 2
  QUALIFY ROW_NUMBER() OVER (PARTITION BY CD_ELEICAO, SQ_CANDIDATO ORDER BY SQ_CANDIDATO) = 1;

-- if table exists, delete data from partition and insert new data
ELSE

  DELETE FROM silver.candidates
  WHERE year_partition = DATE({year}, 1, 1);

  INSERT INTO silver.candidates
  SELECT
    DATE({year}, 1, 1) as year_partition,
    CURRENT_TIMESTAMP() AS insert_datetime,
    c.ANO_ELEICAO AS election_year,
    c.NR_TURNO AS turn_number,
    c.CD_ELEICAO AS election_code,
    c.DS_ELEICAO AS election_description,
    c.DT_ELEICAO AS election_date,
    c.SG_UF AS state_code,
    c.SG_UE AS election_unit_code,
    c.NM_UE AS election_unit_name,
    c.CD_CARGO AS position_code,
    c.DS_CARGO AS position_description,
    c.SQ_CANDIDATO AS candidate_code,
    c.NM_CANDIDATO AS candidate_full_name,
    c.NM_URNA_CANDIDATO AS candidate_short_name,
    c.TP_AGREMIACAO AS association_type,
    c.NR_PARTIDO AS party_number,
    c.SG_PARTIDO AS party_code,
    c.NM_PARTIDO AS party_name,
    c.SQ_COLIGACAO AS coalition_code,
    c.NM_COLIGACAO AS coalition_name,
    CASE
      WHEN c.TP_AGREMIACAO = 'COLIGAÇÃO' THEN SPLIT(c.DS_COMPOSICAO_COLIGACAO, ' / ')
      WHEN c.TP_AGREMIACAO IN ('PARTIDO ISOLADO', 'FEDERAÇÃO') THEN [c.DS_COMPOSICAO_COLIGACAO]
      ELSE NULL
    END AS coalition_composition,
    CASE 
      WHEN c.SG_UF_NASCIMENTO = 'Não divulgável' THEN NULL
      ELSE c.SG_UF_NASCIMENTO
    END AS birth_state,
    c.DT_NASCIMENTO AS birth_date,
    CASE 
      WHEN c.NR_TITULO_ELEITORAL_CANDIDATO = -4 THEN NULL
      ELSE c.NR_TITULO_ELEITORAL_CANDIDATO
    END AS voter_code
  FROM bronze.candidates c
  WHERE c.year_partition = DATE({year}, 1, 1)
  AND c.ANO_ELEICAO = {year}
  AND c.CD_TIPO_ELEICAO = 2
  QUALIFY ROW_NUMBER() OVER (PARTITION BY CD_ELEICAO, SQ_CANDIDATO ORDER BY SQ_CANDIDATO) = 1;

END IF;
