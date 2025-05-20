variable "project_id" {
  description = "spherical-proxy-460312-b8"
  type        = string
  default     = "spherical-proxy-460312-b8"
}

variable "region" {
  description = "Région GCP par défaut"
  type        = string
  default     = "europe-west1"
}

variable "zone" {
  description = "Zone GCP par défaut"
  type        = string
  default     = "europe-west1-b"
}

variable "gcs_bucket" {
  description = "Bucket GCS pour le state Terraform"
  type        = string
  default     = "bucket-gcp-ynov"
}
