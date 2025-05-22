provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_storage_bucket" "raw_bucket" {
  name     = var.bucket_name
  location = var.region
  force_destroy = true
}

resource "google_bigquery_dataset" "bronze" {
  dataset_id = "bronze"
  project    = var.project_id
  location   = var.region
}

resource "google_bigquery_dataset" "silver" {
  dataset_id = "silver"
  project    = var.project_id
  location   = var.region
}

resource "google_bigquery_dataset" "gold" {
  dataset_id = "gold"
  project    = var.project_id
  location   = var.region
}

resource "google_bigquery_dataset" "stage" {
  dataset_id = "stage"
  project    = var.project_id
  location   = var.region
}

resource "google_bigquery_dataset" "control" {
  dataset_id = "control"
  project    = var.project_id
  location   = var.region
}

resource "google_service_account" "etl_service_account" {
  account_id   = "etl-sa"
  display_name = "ETL Service Account"
}

resource "google_project_iam_member" "sa_storage_access" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.etl_service_account.email}"
}

resource "google_project_iam_member" "sa_bigquery_access" {
  project = var.project_id
  role    = "roles/bigquery.admin"
  member  = "serviceAccount:${google_service_account.etl_service_account.email}"
}
