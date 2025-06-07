variable "project_id" {
  description = "ID do projeto GCP"
  type        = string
}

variable "region" {
  description = "Região dos recursos"
  type        = string
  default     = "us-central1"
}

variable "gcp_key" {
  description = "chave"
  type        = string
}

variable "bucket" {
  description = "bucket"
  type        = string
}
