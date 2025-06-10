# Instance pour le monitoring
resource "google_compute_instance" "monitoring" {
  name         = "monitoring-server-${var.environment}"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
      size  = 20
    }
  }

  network_interface {
    network = "default"
    access_config {
      # IP publique éphémère
    }
  }

  # Script de démarrage pour installer Docker et le monitoring
  metadata_startup_script = templatefile("${path.module}/../monitoring/setup-monitoring.sh", {
    app_ip = google_compute_instance.app.network_interface[0].access_config[0].nat_ip
  })

  tags = ["monitoring", "http-server"]

  # Dépend de l'instance principale
  depends_on = [google_compute_instance.app]
}

# Règle de firewall pour le monitoring
resource "google_compute_firewall" "monitoring" {
  name    = "allow-monitoring-${var.environment}"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["3000", "9090", "9093", "22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["monitoring"]
}

# Output pour récupérer l'IP du serveur de monitoring
output "monitoring_ip" {
  value = google_compute_instance.monitoring.network_interface[0].access_config[0].nat_ip
}