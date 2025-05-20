provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_compute_network" "vpc" {
  name = "springboot-vpc"
}

resource "google_compute_firewall" "fw" {
  name    = "springboot-fw"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22", "8080"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_instance" "app" {
  name         = "springboot-app"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-2004-lts"
    }
  }

  network_interface {
    network = google_compute_network.vpc.name
    access_config {}
  }
}