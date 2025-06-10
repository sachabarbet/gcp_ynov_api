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

resource "google_compute_instance" "monitoring" {
  name         = "monitoring-server"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata_startup_script = file("setup-monitoring.sh")

  tags = ["monitoring", "http-server"]
}

resource "google_compute_firewall" "monitoring" {
  name    = "allow-monitoring"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["3000", "9090", "9093"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["monitoring"]
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