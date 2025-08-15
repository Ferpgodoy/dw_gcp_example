# Brazilian Election Datasets - Medallion Architecture

This repository contains the transformation pipeline for Brazilian Election Datasets following the Medallion Architecture: RAW → BRONZE → SILVER → GOLD.

## Data Lake Structure (RAW Layer)

The raw data is stored in Google Cloud Storage (GCS) with the following folder structure:

```
dataset_name/year/timestamp.csv
```

For each dataset, only the latest CSV per year is ingested into BRONZE via an external table.

## BRONZE Layer

The BRONZE layer creates external tables over the latest snapshots of raw CSV files. This layer ingests the data without transformations and keeps the raw structure intact. All BRONZE tables are accessed via external tables under the `raw` schema.

## SILVER Layer

The SILVER layer applies data cleaning, deduplication, and standardization. Each table is derived from one or more BRONZE tables.

## GOLD Layer

The GOLD layer produces analytics-ready tables, often unifying multiple SILVER tables or aggregating data.

## Table Reference

| Layer  | Table Name                        | Upstream Tables (Source)                                              |
|--------|----------------------------------|-----------------------------------------------------------------------|
| BRONZE | bronze.candidates                 | GCS CSV snapshot (accessed by external table under raw schema)       |
| BRONZE | bronze.candidate_assets           | GCS CSV snapshot (accessed by external table under raw schema)       |
| BRONZE | bronze.candidate_social_media     | GCS CSV snapshot (accessed by external table under raw schema)       |
| BRONZE | bronze.revocation_reason          | GCS CSV snapshot (accessed by external table under raw schema)       |
| BRONZE | bronze.positions                  | GCS CSV snapshot (accessed by external table under raw schema)       |
| BRONZE | bronze.electorate_profile         | GCS CSV snapshot (accessed by external table under raw schema)       |
| BRONZE | bronze.voting_section_details     | GCS CSV snapshot (accessed by external table under raw schema)       |
| SILVER | silver.candidates                 | bronze.candidates                                                     |
| SILVER | silver.candidate_assets           | bronze.candidate_assets                                               |
| SILVER | silver.candidate_social_media     | bronze.candidate_social_media                                         |
| SILVER | silver.revocation_reason          | bronze.revocation_reason                                              |
| SILVER | silver.positions                  | bronze.positions                                                      |
| SILVER | silver.electorate_profile         | bronze.electorate_profile                                             |
| SILVER | silver.voting_section_details     | bronze.voting_section_details                                         |
| GOLD   | gold.candidates_scd               | silver.candidates, silver.candidate_assets, silver.candidate_social_media, silver.revocation_reason |
| GOLD   | gold.candidates_unified           | gold.candidates_scd                                                   |
| GOLD   | gold.positions                    | silver.positions                                                      |
| GOLD   | gold.electorate_profile_aggregated | silver.electorate_profile                                           |
| GOLD   | gold.voting_results               | silver.voting_section_details                                         |

## Architecture Diagram

```mermaid
flowchart TD
    subgraph RAW[RAW Layer]
        direction TB
        A[candidates.csv] -->|latest snapshot per year| B[BRONZE Layer]
        A2[candidate_assets.csv] --> B
        A3[candidate_social_media.csv] --> B
        A4[revocation_reason.csv] --> B
        A5[positions.csv] --> B
        A6[electorate_profile.csv] --> B
        A7[voting_section_details.csv] --> B
    end

    subgraph BRONZE[BRONZE Layer]
        direction TB
        B --> C[SILVER Layer]
    end

    subgraph SILVER[SILVER Layer]
        direction TB
        C1[silver.candidates] --> D[GOLD Layer]
        C2[silver.candidate_assets] --> D
        C3[silver.candidate_social_media] --> D
        C4[silver.revocation_reason] --> D
        C5[silver.positions] --> D
        C6[silver.electorate_profile] --> D
        C7[silver.voting_section_details] --> D
    end

    subgraph GOLD[GOLD Layer]
        direction TB
        D1[gold.candidates_scd]
        D2[gold.candidates_unified]
        D3[gold.positions]
        D4[gold.electorate_profile_aggregated]
        D5[gold.voting_results]
    end

    B --> C1
    B --> C2
    B --> C3
    B --> C4
    B --> C5
    B --> C6
    B --> C7

    C1 --> D1
    C2 --> D1
    C3 --> D1
    C4 --> D1
    D1 --> D2
    C5 --> D3
    C6 --> D4
    C7 --> D5
```

