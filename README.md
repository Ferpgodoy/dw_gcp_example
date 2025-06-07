
# Project: Data Warehouse with Airflow, Astro CLI, and GCP

This project demonstrates building a data pipeline using Apache Airflow with Astro CLI, Docker, and Google Cloud Platform (GCP).  
The goal is to orchestrate data ingestion from APIs, store data in Google Cloud Storage (GCS), and perform layered transformations in BigQuery following the Medallion Architecture (Bronze, Silver, and Gold).

## 🚀 Technologies Used

- [Apache Airflow](https://airflow.apache.org/) with [Astro CLI](https://www.astronomer.io/docs/astro/cli/install-cli/)
- [Docker](https://www.docker.com/)
- [Google Cloud Platform (GCP)](https://cloud.google.com/)
  - Google Cloud Storage (GCS)
  - BigQuery
- [Terraform](https://developer.hashicorp.com/terraform)

## 📁 Project Structure

```
projeto_1_dw/.astro
├── .astro                  # Astro configs
├── dags/                   # Airflow DAGs
├── python_scripts/         # Helper Python scripts
│   │── api_reader.py       # Generic function to read data from diverse APIs in JSON format
│   ├── execute_migrations.py # Function that executes SQL scripts in migrations/ to version database structure
│   ├── fetch_credentials.py # Function that uses Terraform output to update GCP credentials on config/secrets
│   ├── gcs_uploader.py     # Diverse functions to upload different format files to GCS
│   ├── generate_fake_data.py # Diverse functions that generate different types of fake data, e.g. sales
│   └── read_sql_scripts.py # Python script that reads SQL scripts parametized with '{}'
├── transformation/         # SQL scripts for transformations (Bronze, Silver, Gold)
│   ├── bronze/             # Ingests raw data into BigQuery with minimal transformation
│   ├── silver/             # Cleans and filters data, handles missing values, sets schema, and normalizes column names
│   └── gold/               # Aggregates and derives final metrics used in dashboards or reports; adds business value
├── migrations/             # DDL (Data Definition Language) SQL scripts to version database structure
├── config/
│   └── secrets/            # Credential files (not versioned)
│   └── secrets.example/    # Examples of Credential files (versioned)
├── .env                    # environment variables (not versioned)
├── .env.example            # Example environment variables
├── Dockerfile              # Docker configuration
├── requirements.txt        # Project dependencies
└── README.md               # Project documentation
```

## ☁️ Raw Bucket Folder Structure

The raw data is stored in the GCS bucket with the following folder structure:

```
sales/
  └── <execution_date>/
        └── <timestamp>.json
```

- `<execution_date>`: The date when the DAG runs and extracts the data (format: YYYY-MM-DD).
- `<timestamp>.json`: The JSON file containing the sales data extracted, named with the timestamp of the extraction.

This structure helps organize the raw sales data by execution date and extraction time. 
It enables the project to retain historical files uploaded for each day, facilitating data auditing. 
Additionally, the latest file in each folder can always be used for backfilling purposes.

## ⚙️ Prerequisites

Before starting, make sure you have the following installed and configured:

- [Astro CLI](https://www.astronomer.io/docs/astro/cli/install-cli/)
- [Docker](https://www.docker.com/get-started)
- An active project on [Google Cloud Platform (GCP)](https://cloud.google.com/)
- [Terraform](https://developer.hashicorp.com/terraform/install)

## ☁️ GCP Setup

1. **Create a project in GCP**  
   If you don’t have one yet, create a new project in the [GCP Console](https://console.cloud.google.com/).

2. **Create a service account in GCP**:
   - Grant the necessary permissions:
      - roles/storage.admin
      - roles/bigquery.admin
      - roles/serviceusage.serviceUsageAdmin
   - Generate a JSON key for this account.
   

## 🛠️ Environment Setup

1. **Clone the repository**:

```bash
git clone https://github.com/Ferpgodoy/dw_gcp_example.git
cd dw_gcp_example
```

2. **Configure environment variables**:
   - Create a `.env` file based on `.env.example`.
   - Create a `terraform.tfvars` file based on `example.tvars`.
   - Update the variables as needed.
   - Save the JSON key file generated for the GCP service account in the `config/secrets/` folder of the project as `gcp_credentials.json`.

3. **Create Resources with Terraform**:
```bash
# 1. access infra folder
cd infra

# 2. inicialize Terraform
terraform init

# 3. create or select project workspace
terraform workspace new <project-id> || terraform workspace select <project-id>

# 4. visualize creation plan
terraform plan

# 5. apply Terraform resource creation
terraform apply
```

4. **Start the local environment using Astro CLI**:

```bash
astro dev start
```

This command will build and start the required Docker containers for Airflow.

5. **Access the Airflow UI**:
   - Go to [http://localhost:8080](http://localhost:8080)
   - Default credentials:
     - User: `admin`
     - Password: `admin`

## 📄 Running the DAGs

- The primary DAG, named `dag_sales_update`, is located in the `dags/dag_01.py` file.
- This DAG performs the following steps while keeping the pipeline lightweight by updating data for only one day at a time:
  1. Generates fake sales data for the current execution day.
  2. Stores the generated data in the `raw` GCS bucket, following the folder structure described above.
  3. Executes layered transformations in BigQuery, updating only the data for that specific day through the Bronze → Silver → Gold stages.
- In case of any issues, backfill runs can be triggered to reprocess and update data for multiple days as needed.


## 📝 Notes

- The `terraform/` directory is present but not configured yet.
- Ensure the GCP credential JSON file is correctly placed in `config/secrets/` and referenced properly in environment variables.
- Verify the service account has sufficient permissions for GCS and BigQuery to avoid permission issues.

## 📬 Contact

For questions or suggestions, please reach out:

- GitHub: [@Ferpgodoy](https://github.com/Ferpgodoy)

