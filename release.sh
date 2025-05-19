#!/bin/bash

# Script de publication unifiée

# 1. Incrémenter la version en SemVer
echo "Incrémentation de la version SemVer..."
# Extraction de la version actuelle depuis pubspec.yaml
CURRENT_VERSION=$(grep 'version:' pubspec.yaml | awk '{print $2}')
# Incrémenter le patch (ex: 1.0.0 -> 1.0.1)
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"
NEW_PATCH=$((PATCH + 1))
NEW_VERSION="$MAJOR.$MINOR.$NEW_PATCH"
# Mettre à jour pubspec.yaml avec la nouvelle version
sed -i "s/version: $CURRENT_VERSION/version: $NEW_VERSION/" pubspec.yaml
git add pubspec.yaml

# 2. Générer un changelog propre avec les changements pertinents
echo "Génération du changelog..."
# Trouver le dernier tag
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
# Si aucun tag n'existe, on prend tous les commits depuis le début
if [ -z "$LATEST_TAG" ]; then
  COMMIT_RANGE="HEAD"
else
  COMMIT_RANGE="$LATEST_TAG..HEAD"
fi

# Créer ou mettre à jour le CHANGELOG.md
TEMP_CHANGELOG=$(mktemp)
echo "## [$NEW_VERSION] - $(date +%F)" > "$TEMP_CHANGELOG"
echo "" >> "$TEMP_CHANGELOG"

# Catégories pour les changements (basé sur Conventional Commits)
echo "### Added" >> "$TEMP_CHANGELOG"
git log "$COMMIT_RANGE" --pretty=format:"%s" | grep -E "^feat" | sed 's/^feat: \(.*\)/- \1/' >> "$TEMP_CHANGELOG" || echo "- Aucun ajout" >> "$TEMP_CHANGELOG"
echo "" >> "$TEMP_CHANGELOG"

echo "### Changed" >> "$TEMP_CHANGELOG"
git log "$COMMIT_RANGE" --pretty=format:"%s" | grep -E "^fix|^refactor" | sed 's/^\(fix\|refactor\): \(.*\)/- \1: \2/' >> "$TEMP_CHANGELOG" || echo "- Aucun changement" >> "$TEMP_CHANGELOG"
echo "" >> "$TEMP_CHANGELOG"

# Ajouter l'ancien contenu du CHANGELOG (s'il existe) après la nouvelle section
if [ -f CHANGELOG.md ]; then
  cat CHANGELOG.md >> "$TEMP_CHANGELOG"
fi

# Remplacer l'ancien CHANGELOG par le nouveau
mv "$TEMP_CHANGELOG" CHANGELOG.md
git add CHANGELOG.md

# 3. Créer un tag Git
echo "Création du tag Git pour la version v$NEW_VERSION..."
git tag -a "v$NEW_VERSION" -m "Release v$NEW_VERSION"

# 4. Pousser le tag et les commits
git checkout -b "release/v$NEW_VERSION"
echo "Poussage des commits et du tag..."
git commit -m "chore(release): v$NEW_VERSION"
git push -u origin "release/v$NEW_VERSION"

# 5. Créer une release publique (GitHub)
echo "Création de la release publique..."
gh release create "v$NEW_VERSION" --title "Release v$NEW_VERSION" --notes-file CHANGELOG.md

echo "Publication terminée avec succès !"