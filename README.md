
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
├── .astro                    # Astro configs
├── .github                   # Github Actions, with workflows for stage and prd
│   └── workflows/  
├── dags/                     # Airflow DAGs
│   └── tasks/                # Contains Airflow Tasks
├── include/  
│   ├── python_scripts/           # Helper Python scripts
│   │   │── api_reader.py         # Generic function to read data from diverse APIs in JSON format
│   │   │── api_reader.py         # Function to delete blobs in GCS
│   │   ├── execute_migrations.py # Function that executes SQL scripts in migrations/ to version database structure
│   │   ├── fetch_credentials.py  # Function that uses Terraform output to update GCP credentials on config/secrets
│   │   ├── gcs_uploader.py       # Diverse functions to upload different format files to GCS
│   │   ├── generate_fake_data.py # Diverse functions that generate different types of fake data, e.g. sales
│   │   └── read_sql_scripts.py   # Python script that reads SQL scripts parametized with '{}'
│   └── transformation/           # SQL scripts for transformations (Bronze, Silver, Gold)
│       ├── bronze/               # Ingests raw data into BigQuery with minimal transformation
│       ├── silver/               # Cleans and filters data, handles missing values, sets schema, and normalizes column names
│       └── gold/                 # Aggregates and derives final metrics used in dashboards or reports; adds business value
├── infra/
│   │── main.tf               # Defines the core infrastructure resources
│   └── variables.tf          # Declares reusable input variables and their types
├── migrations/               # DDL (Data Definition Language) SQL scripts to version database structure
├── config/
│   └── secrets/              # Credential files (not versioned)
├── .env                      # environment variables (not versioned)
├── .env.example              # Example environment variables
├── Dockerfile                # Docker configuration
├── requirements.txt          # Project dependencies
├── requirements-ci.txt       # Project dependencies used in CI/CD
└── README.md                 # Project documentation
```

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
   - Update the variables as needed.
   - Save the JSON key file generated for the GCP service account in the `config/secrets/` folder of the project as `gcp_credentials.json`.

3. **Setup backend for Terraform**:
```bash
# Load environment variables from .env file
export $(grep -v '^#' .env | xargs)

# Ensure the backend bucket exists
echo "Checking if bucket $TF_BACKEND_BUCKET exists..."
if ! gsutil ls -b gs://$TF_BACKEND_BUCKET > /dev/null 2>&1; then
  echo "Bucket does not exist. Creating..."
  gsutil mb -p $GCP_PROJECT_ID -l $REGION gs://$TF_BACKEND_BUCKET
else
  echo "Bucket already exists."
fi

# Create terraform.tfvars file
cat <<EOF > infra/terraform.tfvars
project_id  = "$GCP_PROJECT_ID"
gcp_key = "../config/secrets/gcp_credentials.json"
bucket = "$GCP_BUCKET_NAME"
region = "$REGION"
EOF
echo "File infra/terraform.tfvars created."

# Create backend.tf file
cat <<EOF > infra/backend.tf
terraform {
  backend "gcs" {
    bucket  = "$TF_BACKEND_BUCKET"
    prefix  = "infra"
  }
}
EOF
echo "File infra/backend.tf created."
```

4. **Create Resources with Terraform**:
```bash
# 1. access infra folder
cd infra

# 2. export GCP credentials location
export GOOGLE_APPLICATION_CREDENTIALS=../config/secrets/gcp_credentials.json

# 2. inicialize Terraform
terraform init

# 4. visualize creation plan
terraform plan -var-file=terraform.tfvars

# 5. apply Terraform resource creation
terraform apply -auto-approve -var-file=terraform.tfvars

## 6. back to root folder
cd ..
```

5. **Start the local environment using Astro CLI**:

```bash
astro dev start
```

This command will build and start the required Docker containers for Airflow.

6. **Access the Airflow UI**:
   - Go to [http://localhost:8080](http://localhost:8080)
   - Default credentials:
     - User: `admin`
     - Password: `admin`

## 📂 Detailed Documentation

For more details on specific parts of the project, see the subfolder READMEs:

- [Migrations](migrations/README.md) — Explains the SQL migration scripts, execution flow, and GitHub Actions integration.
- [Infrastructure](infra/README.md) — Explains Terraform configuration, variables, backend setup, and GitHub workflows for deployment.
- [Medallion Architecture](include/transformation/README.md) — Describes the transformation layers, data flow, and processing logic following the Medallion Architecture pattern.

## 📬 Contact

For questions or suggestions, please reach out:

- GitHub: [@Ferpgodoy](https://github.com/Ferpgodoy)