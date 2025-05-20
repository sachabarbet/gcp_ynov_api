# API Hello World Endpoints
GET /hello : retourne "hello"
GET /hello/{name} : retourne "hello {name}"
GET /hello-dog : retourne "hello dog"

# Choix d'infrastructure
GitHub Actions : pour l'intégration et le déploiement continus (CI/CD)
Terraform : pour la provision automatisée de l'infrastructure sur GCP
Ansible : pour la configuration et le déploiement de l'application
Google Cloud Platform (GCP) : hébergement de l'application
Spring Boot (Java 21, Maven) : développement de l'API
release.sh : script de versionnement et de déploiement

# Structure du projet
.
├── api/             # Code source de l'API Spring Boot
├── infra/           # Fichiers Terraform pour l'infrastructure
├── ansible/         # Playbooks Ansible pour le déploiement
├── .github/         # Workflows GitHub Actions
└── release.sh       # Script de release et déploiement

## Fonctionnement du Pipeline CI/CD

### Vue d'ensemble
Notre pipeline CI/CD automatise l'intégration, les tests et le déploiement de l'API Hello World, assurant une livraison continue de manière fiable et efficace. Le pipeline est entièrement géré via GitHub Actions et déclenché automatiquement lors de différents événements Git.

### Déclencheurs du pipeline
Le pipeline est déclenché lors des événements suivants:
- Push sur la branche `main`
- Création d'une pull request vers `main`
- Création d'un tag de version (`v*.*.*`)
- Déclenchement manuel via `workflow_dispatch`

### Étapes du pipeline

#### 1. Vérification du code
```log
2025-04-15T10:22:18.901Z [INFO] Run actions/checkout@v3
2025-04-15T10:22:19.652Z [INFO] Checking out repository at ref: refs/heads/main
2025-04-15T10:22:20.109Z [INFO] Repository checkout completed successfully
```

#### 2. Configuration de l'environnement
- Installation de Java 21
- Installation de Terraform
- Configuration de Git pour les commits automatiques

```log
2025-04-15T10:22:25.312Z [INFO] Using JDK distribution: temurin
2025-04-15T10:22:25.456Z [INFO] Resolved Java version: 21.0.2+13
2025-04-15T10:22:26.982Z [INFO] JDK installed successfully

2025-04-15T10:22:28.523Z [INFO] Terraform version: 1.6.6
2025-04-15T10:22:29.312Z [INFO] Terraform installed successfully
```

#### 3. Versionnement automatique
Le script `release.sh` analyse le message de commit pour déterminer le type de version à incrémenter (MAJOR, MINOR, PATCH).

```log
2025-04-15T10:22:32.145Z [INFO] Running release script
2025-04-15T10:22:32.658Z [INFO] Current version: 1.2.5
2025-04-15T10:22:32.785Z [INFO] Analyzing commit message...
2025-04-15T10:22:32.842Z [INFO] Patch update detected
2025-04-15T10:22:32.901Z [INFO] New version: 1.2.6
2025-04-15T10:22:33.456Z [INFO] Version updated and committed
2025-04-15T10:22:34.123Z [INFO] Tag v1.2.6 created and pushed
```

#### 4. Authentification GCP
```log
2025-04-15T10:22:38.456Z [INFO] Authenticating to Google Cloud
2025-04-15T10:22:40.123Z [INFO] Successfully authenticated to GCP
```

#### 5. Déploiement de l'infrastructure avec Terraform
```log
2025-04-15T10:22:42.568Z [INFO] Initializing Terraform
2025-04-15T10:22:45.489Z [INFO] Terraform initialized
2025-04-15T10:22:45.712Z [INFO] Running terraform apply
2025-04-15T10:23:15.321Z [INFO] Apply complete! Resources: 0 added, 1 changed, 0 destroyed.
```

#### 6. Configuration SSH et déploiement avec Ansible
```log
2025-04-15T10:23:18.456Z [INFO] Setting up SSH keys
2025-04-15T10:23:19.120Z [INFO] SSH keys configured successfully
2025-04-15T10:23:19.658Z [INFO] Running Ansible playbook
2025-04-15T10:24:32.157Z [INFO] Ansible playbook completed successfully
```

### Obstacles rencontrés et solutions

#### 1. Échec d'authentification GCP

**Problème:** Le pipeline échouait lors de l'authentification à Google Cloud Platform.

```log
2025-04-10T15:45:23.456Z [ERROR] Error authenticating to Google Cloud: Service account key not found or invalid
```

**Solution:** Mise à jour des secrets GitHub Actions pour inclure la clé du compte de service correctement formatée.

```log
2025-04-11T09:12:34.789Z [INFO] Updated GCP_SA_KEY secret in GitHub repository
2025-04-11T09:15:56.123Z [INFO] GCP authentication successful with updated key
```

#### 2. Échec du déploiement Ansible

**Problème:** Le déploiement Ansible échouait en raison de problèmes de permissions.

```log
2025-04-14T11:23:45.678Z [ERROR] Ansible: Permission denied when executing 'mvn' command
2025-04-14T11:23:45.789Z [ERROR] fatal: [35.205.135.126]: FAILED! => {"changed": false, "msg": "Failed to build Maven project", "rc": 1}
```

**Solution:** Ajout d'étapes pour configurer correctement les permissions utilisateur dans le playbook Ansible.

```log
2025-04-14T16:12:34.567Z [INFO] Added user permission configuration to Ansible playbook
2025-04-14T16:15:43.210Z [INFO] Updated mkdir command with sudo
2025-04-14T16:23:45.678Z [INFO] Ansible deployment successful with permission fixes
```

### 3. Problèmes de service systemd

**Problème:** Le service Spring Boot ne démarrait pas correctement après le déploiement.

```log
2025-04-15T09:12:34.567Z [ERROR] Job for springboot.service failed. See 'systemctl status springboot.service' for details.
2025-04-15T09:12:35.678Z [ERROR] systemd[1]: springboot.service: Main process exited, code=exited, status=1/FAILURE
```

**Solution:** Correction du fichier de service systemd et ajout de logs détaillés.

```log
2025-04-15T10:05:23.456Z [INFO] Updated systemd service file with correct working directory and environment variables
2025-04-15T10:05:45.678Z [INFO] Added JVM options for better memory management
2025-04-15T10:06:12.345Z [INFO] Service started successfully after configuration update
```

### Améliorations futures du pipeline

1. **Mise en place de tests automatisés plus complets**
   - Ajout de tests d'intégration et de performance
   - Génération de rapports de couverture de code

2. **Surveillance et observabilité**
   - Intégration avec Prometheus et Grafana pour la surveillance 
   - Configuration d'alertes automatiques

3. **Déploiement bleu-vert**
   - Mise en place d'un système de déploiement sans interruption de service
   - Capacité de rollback automatique en cas d'échec

4. **Sécurité renforcée**
   - Analyse de code statique avec SonarQube
   - Scan de vulnérabilités des dépendances
   - Gestion améliorée des secrets
