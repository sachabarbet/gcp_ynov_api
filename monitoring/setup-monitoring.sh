#!/bin/bash
set -e

# Variables
APP_IP="${app_ip}"
MONITORING_DIR="/opt/monitoring"

# Mise à jour du système
apt-get update
apt-get install -y docker.io docker-compose curl git

# Démarrage de Docker
systemctl start docker
systemctl enable docker

# Création du répertoire de monitoring
mkdir -p $MONITORING_DIR
cd $MONITORING_DIR

# Configuration Prometheus
cat > prometheus.yml << EOF
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "alert_rules.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - localhost:9093

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'spring-boot-app'
    static_configs:
      - targets: ['$APP_IP:8080']
    metrics_path: '/actuator/prometheus'
    scrape_interval: 5s
EOF

# Règles d'alertes
cat > alert_rules.yml << EOF
groups:
- name: spring-boot-alerts
  rules:
  - alert: ApplicationDown
    expr: up{job="spring-boot-app"} == 0
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: "Spring Boot Application is down"
      description: "Spring Boot application has been down for more than 1 minute"

  - alert: HighMemoryUsage
    expr: jvm_memory_used_bytes{area="heap"} / jvm_memory_max_bytes{area="heap"} * 100 > 80
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "High memory usage detected"
      description: "JVM heap memory usage is above 80%"

  - alert: HighCPUUsage
    expr: system_cpu_usage > 0.8
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "High CPU usage detected"
      description: "System CPU usage is above 80%"
EOF

# Configuration Alertmanager
cat > alertmanager.yml << EOF
global:
  smtp_smarthost: 'localhost:587'
  smtp_from: 'alerts@yourcompany.com'

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'web.hook'

receivers:
- name: 'web.hook'
  webhook_configs:
  - url: 'http://localhost:5001/'
EOF

# Docker Compose pour le monitoring
cat > docker-compose.yml << EOF
services:
  prometheus:
    image: prom/prometheus:v2.45.0
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - ./alert_rules.yml:/etc/prometheus/alert_rules.yml
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--web.enable-lifecycle'
    restart: unless-stopped

  grafana:
    image: grafana/grafana:10.0.0
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin123
      - GF_SECURITY_ADMIN_USER=admin
    volumes:
      - grafana-storage:/var/lib/grafana
    restart: unless-stopped

  alertmanager:
    image: prom/alertmanager:v0.25.0
    ports:
      - "9093:9093"
    volumes:
      - ./alertmanager.yml:/etc/alertmanager/alertmanager.yml
    restart: unless-stopped

volumes:
  grafana-storage:
EOF

# Démarrage des services
docker-compose up -d

# Attendre que les services soient prêts
sleep 30

# Vérification que les services fonctionnent
curl -f http://localhost:9090/-/healthy || exit 1
curl -f http://localhost:3000/api/health || exit 1

echo "Monitoring stack deployed successfully!"
echo "Prometheus: http://$(curl -s ifconfig.me):9090"
echo "Grafana: http://$(curl -s ifconfig.me):3000 (admin/admin123)"
echo "Alertmanager: http://$(curl -s ifconfig.me):9093"