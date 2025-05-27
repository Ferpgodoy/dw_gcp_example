
# Project 1: Data Warehouse with Airflow, Astro CLI, and GCP

This project demonstrates building a data pipeline using Apache Airflow with Astro CLI, Docker, and Google Cloud Platform (GCP).  
The goal is to orchestrate data ingestion from APIs, store data in Google Cloud Storage (GCS), and perform layered transformations in BigQuery following the Medallion Architecture (Bronze, Silver, and Gold).

## 🚀 Technologies Used

- [Apache Airflow](https://airflow.apache.org/) with [Astro CLI](https://www.astronomer.io/docs/astro/cli/install-cli/)
- [Docker](https://www.docker.com/)
- [Google Cloud Platform (GCP)](https://cloud.google.com/)
  - Google Cloud Storage (GCS)
  - BigQuery

## 📁 Project Structure

```
projeto_1_dw/
├── dags/                   # Airflow DAGs
├── migrations/             # SQL scripts to version database structure
├── python_scripts/         # Helper Python scripts
├── transformation/         # SQL scripts for transformations (Bronze, Silver, Gold)
├── config/
│   └── secrets/            # Credential files (not versioned)
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

## ⚙️ Prerequisites

Before starting, make sure you have the following installed and configured:

- [Astro CLI](https://www.astronomer.io/docs/astro/cli/install-cli/)
- [Docker](https://www.docker.com/get-started)
- An active project on [Google Cloud Platform (GCP)](https://cloud.google.com/)

## ☁️ GCP Setup

1. **Create a project in GCP**  
   If you don’t have one yet, create a new project in the [GCP Console](https://console.cloud.google.com/).

2. **Enable the required APIs**:
   - Cloud Storage
   - BigQuery

3. **Create a bucket in GCS**:
   - Suggested name: `raw`
   - This bucket will store raw data extracted from APIs.

4. **Create BigQuery datasets**:
   - `control`
   - `raw`
   - `bronze`
   - `silver`
   - `gold`

5. **Create a service account in GCP**:
   - Grant the necessary permissions to access GCS and BigQuery.
   - Generate a JSON key for this account.
   - Save the JSON key file in the `config/secrets/` folder of the project as `gcp_credentials.json`.

## 🛠️ Environment Setup

1. **Clone the repository**:

```bash
git clone https://github.com/Ferpgodoy/projeto_1_dw.git
cd projeto_1_dw
```

2. **Configure environment variables**:
   - Create a `.env` file based on `.env.example`.
   - Update the variables as needed, especially those related to GCP.

3. **Start the local environment using Astro CLI**:

```bash
astro dev start
```

This command will build and start the required Docker containers for Airflow.

4. **Access the Airflow UI**:
   - Go to [http://localhost:8080](http://localhost:8080)
   - Default credentials:
     - User: `admin`
     - Password: `admin`

## 📄 Running the DAGs

- The main DAG is `dag_sales_update`, located in the `dags/` folder.
- The DAG performs these steps:
  1. Generates fake sales data.
  2. Stores the data in the `raw` GCS bucket using the folder structure described above.
  3. Executes layered transformations in BigQuery: Bronze → Silver → Gold.

## 📝 Notes

- The `terraform/` directory is present but not configured yet.
- Ensure the GCP credential JSON file is correctly placed in `config/secrets/` and referenced properly in environment variables.
- Verify the service account has sufficient permissions for GCS and BigQuery to avoid permission issues.

## 📬 Contact

For questions or suggestions, please reach out:

- GitHub: [@Ferpgodoy](https://github.com/Ferpgodoy)

