#!/bin/bash
sudo apt update
sudo apt install -y docker.io docker-compose

# Clone your monitoring config
git clone https://github.com/your-repo/monitoring-config.git
cd monitoring-config

# Start monitoring stack
sudo docker-compose -f docker-compose.monitoring.yml up -d