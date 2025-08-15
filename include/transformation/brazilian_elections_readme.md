# Brazilian Election Datasets - Medallion Architecture

This repository contains the transformation pipeline for Brazilian Election Datasets following the Medallion Architecture: RAW → BRONZE → SILVER → GOLD.

## Data Lake Structure (RAW Layer)

The raw data is stored in Google Cloud Storage (GCS) with the following folder structure:

```
dataset_name/year/timestamp.csv
```

For each dataset, only the latest CSV per year is ingested into BRONZE via an external table.

## BRONZE Layer

The BRONZE layer creates external tables over the latest snapshots of raw CSV files. This layer ingests the data without transformations and keeps the raw structure intact. All BRONZE tables are ingested after accessing GCS CSV files via external tables under the `raw` schema.

## SILVER Layer

The SILVER layer applies data cleaning, deduplication, and standardization. Each table is derived from one or more BRONZE tables.

## GOLD Layer

The GOLD layer produces analytics-ready tables, often unifying multiple SILVER tables or aggregating data.

## Table Reference

| Layer  | Table Name                        | Upstream Tables (Source)                                              | Table Type      |
|--------|----------------------------------|-----------------------------------------------------------------------|----------------|
| RAW    | raw.candidates                    | GCS CSV snapshot file (consulta_cand dataset)                                     | External Table |
| RAW    | raw.candidate_assets              | GCS CSV snapshot file (bem_candidato dataset)                                     | External Table |
| RAW    | raw.candidate_social_media        | GCS CSV snapshot file (rede_social_candidato dataset)                                     | External Table |
| RAW    | raw.revocation_reason             | GCS CSV snapshot file (motivo_cassacao dataset)                                     | External Table |
| RAW    | raw.positions                     | GCS CSV snapshot file (consulta_vagas dataset)                                     | External Table |
| RAW    | raw.electorate_profile            | GCS CSV snapshot file (perfil_eleitorado dataset)                                     | External Table |
| RAW    | raw.voting_section_details        | GCS CSV snapshot file (detalhe_votacao_secao dataset)                                     | External Table |
| BRONZE | bronze.candidates                 | raw.candidates                                                        | Table          |
| BRONZE | bronze.candidate_assets           | raw.candidate_assets                                                  | Table          |
| BRONZE | bronze.candidate_social_media     | raw.candidate_social_media                                            | Table          |
| BRONZE | bronze.revocation_reason          | raw.revocation_reason                                                 | Table          |
| BRONZE | bronze.positions                  | raw.positions                                                         | Table          |
| BRONZE | bronze.electorate_profile         | raw.electorate_profile                                                | Table          |
| BRONZE | bronze.voting_section_details     | raw.voting_section_details                                            | Table          |
| SILVER | silver.candidates                 | bronze.candidates                                                     | Table          |
| SILVER | silver.candidate_assets           | bronze.candidate_assets                                               | Table          |
| SILVER | silver.candidate_social_media     | bronze.candidate_social_media                                         | Table          |
| SILVER | silver.revocation_reason          | bronze.revocation_reason                                              | Table          |
| SILVER | silver.positions                  | bronze.positions                                                      | Table          |
| SILVER | silver.electorate_profile         | bronze.electorate_profile                                             | Table          |
| SILVER | silver.voting_section_details     | bronze.voting_section_details                                         | Table          |
| GOLD   | gold.candidates_scd               | silver.candidates, silver.candidate_assets, silver.candidate_social_media, silver.revocation_reason | Table |
| GOLD   | gold.candidates_unified           | gold.candidates_scd                                                   | Table          |
| GOLD   | gold.positions                    | silver.positions                                                      | Table          |
| GOLD   | gold.electorate_profile_aggregated | silver.electorate_profile                                           | Table          |
| GOLD   | gold.voting_results               | silver.voting_section_details                                         | Table          |


## Architecture Diagram
```mermaid
flowchart TD
    %% GCS
    GCS_CAND["GCS CSV snapshot (consulta_cand)"]
    GCS_ASSETS["GCS CSV snapshot (bem_candidato)"]
    GCS_SOCIAL["GCS CSV snapshot (rede_social_candidato)"]
    GCS_REVOCATION["GCS CSV snapshot (motivo_cassacao)"]
    GCS_POSITIONS["GCS CSV snapshot (consulta_vagas)"]
    GCS_PROFILE["GCS CSV snapshot (perfil_eleitorado)"]
    GCS_VOTING["GCS CSV snapshot (detalhe_votacao_secao)"]

    %% RAW
    raw_candidates["raw.candidates"]
    raw_candidate_assets["raw.candidate_assets"]
    raw_candidate_social_media["raw.candidate_social_media"]
    raw_revocation_reason["raw.revocation_reason"]
    raw_positions["raw.positions"]
    raw_electorate_profile["raw.electorate_profile"]
    raw_voting_section_details["raw.voting_section_details"]

    %% BRONZE
    bronze_candidates["bronze.candidates"]
    bronze_candidate_assets["bronze.candidate_assets"]
    bronze_candidate_social_media["bronze.candidate_social_media"]
    bronze_revocation_reason["bronze.revocation_reason"]
    bronze_positions["bronze.positions"]
    bronze_electorate_profile["bronze.electorate_profile"]
    bronze_voting_section_details["bronze.voting_section_details"]

    %% SILVER
    silver_candidates["silver.candidates"]
    silver_candidate_assets["silver.candidate_assets"]
    silver_candidate_social_media["silver.candidate_social_media"]
    silver_revocation_reason["silver.revocation_reason"]
    silver_positions["silver.positions"]
    silver_electorate_profile["silver.electorate_profile"]
    silver_voting_section_details["silver.voting_section_details"]

    %% GOLD
    gold_candidates_scd["gold.candidates_scd"]
    gold_candidates_unified["gold.candidates_unified"]
    gold_positions["gold.positions"]
    gold_electorate_profile_aggregated["gold.electorate_profile_aggregated"]
    gold_voting_results["gold.voting_results"]

    %% RELAÇÕES GCS -> RAW
    GCS_CAND --> raw_candidates
    GCS_ASSETS --> raw_candidate_assets
    GCS_SOCIAL --> raw_candidate_social_media
    GCS_REVOCATION --> raw_revocation_reason
    GCS_POSITIONS --> raw_positions
    GCS_PROFILE --> raw_electorate_profile
    GCS_VOTING --> raw_voting_section_details

    %% RELAÇÕES RAW -> BRONZE
    raw_candidates --> bronze_candidates
    raw_candidate_assets --> bronze_candidate_assets
    raw_candidate_social_media --> bronze_candidate_social_media
    raw_revocation_reason --> bronze_revocation_reason
    raw_positions --> bronze_positions
    raw_electorate_profile --> bronze_electorate_profile
    raw_voting_section_details --> bronze_voting_section_details

    %% RELAÇÕES BRONZE -> SILVER
    bronze_candidates --> silver_candidates
    bronze_candidate_assets --> silver_candidate_assets
    bronze_candidate_social_media --> silver_candidate_social_media
    bronze_revocation_reason --> silver_revocation_reason
    bronze_positions --> silver_positions
    bronze_electorate_profile --> silver_electorate_profile
    bronze_voting_section_details --> silver_voting_section_details

    %% RELAÇÕES SILVER -> GOLD
    silver_candidates --> gold_candidates_scd
    silver_candidate_assets --> gold_candidates_scd
    silver_candidate_social_media --> gold_candidates_scd
    silver_revocation_reason --> gold_candidates_scd

    gold_candidates_scd --> gold_candidates_unified
    silver_positions --> gold_positions
    silver_electorate_profile --> gold_electorate_profile_aggregated
    silver_voting_section_details --> gold_voting_results
