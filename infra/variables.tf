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
