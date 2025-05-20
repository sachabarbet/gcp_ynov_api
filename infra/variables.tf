variable "project_id" {
  description = "spherical-proxy-460312-b8"
  type        = string
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
}

variable "gcp_credentials_file" {
  description = "Chemin vers le fichier JSON de la SA"
  type        = string
  default     = "../gha-creds.json"
}