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
  WITH t1 AS (
  SELECT
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
  QUALIFY ROW_NUMBER() OVER (PARTITION BY CD_ELEICAO, SQ_CANDIDATO ORDER BY SQ_CANDIDATO) = 1
  ),

  t2 as ( 
    SELECT *
    FROM bronze.candidate_assets ca
    WHERE ca.year_partition = DATE({year}, 1, 1)
    AND ca.ANO_ELEICAO = {year}
    AND ca.CD_TIPO_ELEICAO = 2
    QUALIFY ROW_NUMBER() OVER (PARTITION BY CD_ELEICAO, SQ_CANDIDATO, NR_ORDEM_BEM_CANDIDATO ORDER BY NR_ORDEM_BEM_CANDIDATO) = 1
  ),

  t3 as (
    SELECT 
      CD_ELEICAO,
      SQ_CANDIDATO,
      ARRAY_AGG(STRUCT(
      ca.NR_ORDEM_BEM_CANDIDATO as candidate_asset_number,
      ca.CD_TIPO_BEM_CANDIDATO as asset_type_code,
      ca.DS_TIPO_BEM_CANDIDATO as asset_type_description,
      ca.DS_BEM_CANDIDATO as asset_description,
      ca.VR_BEM_CANDIDATO as asset_value
      )) as candidate_assets
    FROM t2 ca
    GROUP BY 1,2
  ),

  t4 as (
  SELECT *
  FROM bronze.candidate_social_media csm
  WHERE csm.year_partition = DATE({year}, 1, 1)
  AND csm.AA_ELEICAO = {year}
  AND csm.CD_TIPO_ELEICAO = 2
  QUALIFY ROW_NUMBER() OVER(PARTITION BY CD_ELEICAO, SQ_CANDIDATO,NR_ORDEM_REDE_SOCIAL ORDER BY NR_ORDEM_REDE_SOCIAL) = 1
  ),

  t5 as (
    SELECT 
      CD_ELEICAO, 
      SQ_CANDIDATO,
      ARRAY_AGG(STRUCT(
        NR_ORDEM_REDE_SOCIAL as social_media_number,
        DS_URL as social_media_url
        )) as social_media
    FROM t4
    GROUP BY 1,2
  ),

  t6 as (
  SELECT 
    *,
    ROW_NUMBER() OVER (PARTITION BY CD_ELEICAO, SQ_CANDIDATO ORDER BY SQ_CANDIDATO) as revocation_number
  FROM bronze.revocation_reason rr
  WHERE rr.year_partition = DATE({year}, 1, 1)
  AND rr.ANO_ELEICAO = {year}
  AND rr.CD_TIPO_ELEICAO = 2
  ),

  t7 as (
    SELECT 
      CD_ELEICAO,
      SQ_CANDIDATO,
      ARRAY_AGG(STRUCT(
        rr.revocation_number,
        rr.TP_MOTIVO as reason_type,
        rr.DS_TP_MOTIVO as reason_type_description,
        rr.CD_MOTIVO as reason_code,
        rr.DS_MOTIVO as reason_description
      )) as revocation_reason
    FROM t6 rr
    GROUP BY 1,2
  ),

  t8 as (
  SELECT 
    DATE({year}, 1, 1) as year_partition,
    CURRENT_TIMESTAMP() AS insert_datetime,
    c.*,
    ca.candidate_assets,
    csm.social_media,
    rr.revocation_reason
  FROM t1 c
  LEFT JOIN t3 ca
  ON c.candidate_code = ca.SQ_CANDIDATO
  AND c.election_code = ca.CD_ELEICAO
  LEFT JOIN t5 csm
  ON c.candidate_code = csm.SQ_CANDIDATO
  AND c.election_code = csm.CD_ELEICAO
  LEFT JOIN t7 rr
  ON c.candidate_code = rr.SQ_CANDIDATO
  AND c.election_code = rr.CD_ELEICAO
  )

  SELECT * FROM t8;

-- if table exists, delete data from partition and insert new data
ELSE

  DELETE FROM silver.candidates
  WHERE year_partition = DATE({year}, 1, 1);

  INSERT INTO silver.candidates
  WITH t1 AS (
  SELECT
    c.ano_eleicao AS election_year,
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
  QUALIFY ROW_NUMBER() OVER (PARTITION BY CD_ELEICAO, SQ_CANDIDATO ORDER BY SQ_CANDIDATO) = 1
  ),

  t2 as ( 
    SELECT *
    FROM bronze.candidate_assets ca
    WHERE ca.year_partition = DATE({year}, 1, 1)
    AND ca.ANO_ELEICAO = {year}
    AND ca.CD_TIPO_ELEICAO = 2
    QUALIFY ROW_NUMBER() OVER (PARTITION BY CD_ELEICAO, SQ_CANDIDATO, NR_ORDEM_BEM_CANDIDATO ORDER BY NR_ORDEM_BEM_CANDIDATO) = 1
  ),

  t3 as (
    SELECT 
      CD_ELEICAO,
      SQ_CANDIDATO,
      ARRAY_AGG(STRUCT(
      ca.NR_ORDEM_BEM_CANDIDATO as candidate_asset_number,
      ca.CD_TIPO_BEM_CANDIDATO as asset_type_code,
      ca.DS_TIPO_BEM_CANDIDATO as asset_type_description,
      ca.DS_BEM_CANDIDATO as asset_description,
      ca.VR_BEM_CANDIDATO as asset_value
      )) as candidate_assets
    FROM t2 ca
    GROUP BY 1,2
  ),

  t4 as (
  SELECT *
  FROM bronze.candidate_social_media csm
  WHERE csm.year_partition = DATE({year}, 1, 1)
  AND csm.AA_ELEICAO = {year}
  AND csm.CD_TIPO_ELEICAO = 2
  QUALIFY ROW_NUMBER() OVER(PARTITION BY CD_ELEICAO, SQ_CANDIDATO,NR_ORDEM_REDE_SOCIAL ORDER BY NR_ORDEM_REDE_SOCIAL) = 1
  ),

  t5 as (
    SELECT 
      CD_ELEICAO, 
      SQ_CANDIDATO,
      ARRAY_AGG(STRUCT(
        NR_ORDEM_REDE_SOCIAL as social_media_number,
        DS_URL as social_media_url
        )) as social_media
    FROM t4
    GROUP BY 1,2
  ),

  t6 as (
  SELECT 
    *,
    ROW_NUMBER() OVER (PARTITION BY CD_ELEICAO, SQ_CANDIDATO ORDER BY SQ_CANDIDATO) as revocation_number
  FROM bronze.revocation_reason rr
  WHERE rr.year_partition = DATE({year}, 1, 1)
  AND rr.ANO_ELEICAO = {year}
  AND rr.CD_TIPO_ELEICAO = 2
  ),

  t7 as (
    SELECT 
      CD_ELEICAO,
      SQ_CANDIDATO,
      ARRAY_AGG(STRUCT(
        rr.revocation_number,
        rr.TP_MOTIVO as reason_type,
        rr.DS_TP_MOTIVO as reason_type_description,
        rr.CD_MOTIVO as reason_code,
        rr.DS_MOTIVO as reason_description
      )) as revocation_reason
    FROM t6 rr
    GROUP BY 1,2
  ),

  t8 as (
  SELECT 
    DATE({year}, 1, 1) as year_partition,
    CURRENT_TIMESTAMP() AS insert_datetime,
    c.*,
    ca.candidate_assets,
    csm.social_media,
    rr.revocation_reason
  FROM t1 c
  LEFT JOIN t3 ca
  ON c.candidate_code = ca.SQ_CANDIDATO
  AND c.election_code = ca.CD_ELEICAO
  LEFT JOIN t5 csm
  ON c.candidate_code = csm.SQ_CANDIDATO
  AND c.election_code = csm.CD_ELEICAO
  LEFT JOIN t7 rr
  ON c.candidate_code = rr.SQ_CANDIDATO
  AND c.election_code = rr.CD_ELEICAO
  )

  SELECT * FROM t8;

END IF;
