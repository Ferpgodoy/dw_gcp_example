# Infrastructure (Terraform)

This folder contains Terraform configuration files to define and manage the infrastructure of the project. Only the following files are versioned:

* `main.tf` — Defines the resources, provider configuration, and structure of the infrastructure.
* `variables.tf` — Declares input variables used by Terraform.

## Execution Flow

Terraform is executed automatically through GitHub Actions workflows (`deploy-prd.yml` and `deploy-stage.yml`) located in `.github/workflows/`. The workflow performs the following steps:

1. **Ensure Backend Bucket Exists**
   Checks if the Google Cloud Storage (GCS) backend bucket exists. If not, it creates the bucket.

   ```bash
   if ! gsutil ls -b gs://${TF_BACKEND_BUCKET} > /dev/null 2>&1; then
     gsutil mb -p ${GCP_PROJECT_ID} -l ${REGION} gs://${TF_BACKEND_BUCKET}
   fi
   ```

2. **Create `terraform.tfvars`**
   Generates the `terraform.tfvars` file with environment-specific variables:

   ```hcl
   project_id  = "${GCP_PROJECT_ID}"
   gcp_key     = "../config/secrets/gcp_credentials.json"
   bucket      = "${GCP_BUCKET_NAME}"
   region      = "${REGION}"
   ```

3. **Create `backend.tf`**
   Configures the Terraform backend to use GCS:

   ```hcl
   terraform {
     backend "gcs" {
       bucket  = "${TF_BACKEND_BUCKET}"
       prefix  = "infra"
     }
   }
   ```

4. **Setup Terraform**
   Installs the required Terraform version (1.6.6).

5. **Run Terraform**
   Executes Terraform commands in the `infra` directory:

   ```bash
   terraform init
   terraform plan -var-file=terraform.tfvars
   terraform apply -auto-approve -var-file=terraform.tfvars
   ```

## Required Environment Variables and Secrets at GitHub

The workflows rely on the following environment secrets defined at GitHub to execute correctly.

* `GCP_PROJECT_ID` — Google Cloud project ID.
* `GCP_BUCKET_NAME` — Default GCS bucket name.
* `TF_BACKEND_BUCKET` — Bucket for storing Terraform state.
* `REGION` — GCP region where resources will be created.
* `GCP_CREDENTIALS_JSON` — Google Cloud JSON key for the service account.

This workflow ensures that infrastructure changes are applied consistently across environments, using environment variables to configure project-specific settings.
