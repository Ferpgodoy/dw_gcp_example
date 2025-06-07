provider "google" {
  credentials = file(var.gcp_key)
  project = var.project_id
  region  = var.region
}

resource "google_project_service" "storage" {
  service = "storage.googleapis.com"
  project = var.project_id
}

resource "google_project_service" "bigquery" {
  service = "bigquery.googleapis.com"
  project = var.project_id
}

resource "google_project_service" "cloudresourcemanager" {
  service = "cloudresourcemanager.googleapis.com"
  project = var.project_id
  disable_on_destroy = false
}

resource "google_storage_bucket" "raw_bucket" {
  name     = var.bucket
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

resource "google_bigquery_dataset" "raw" {
  dataset_id = "raw"
  project    = var.project_id
  location   = var.region
}

resource "google_bigquery_dataset" "control" {
  dataset_id = "control"
  project    = var.project_id
  location   = var.region
}