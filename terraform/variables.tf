variable "project_id" {
  description = "ID do projeto GCP"
  type        = string
}

variable "bucket_name" {
  description = "Nome do bucket GCS"
  type        = string
}

variable "region" {
  description = "Região dos recursos"
  type        = string
  default     = "us-central1"
}
