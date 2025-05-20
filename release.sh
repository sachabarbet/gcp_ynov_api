#!/bin/bash

# Unified publication script for Maven-based Spring Boot project

set -e

# 1. Increment the version using Maven Versions Plugin
echo "Incrementing the patch version..."
cd api
mvn build-helper:parse-version versions:set \
  -DnewVersion=\${parsedVersion.majorVersion}.\${parsedVersion.minorVersion}.\${parsedVersion.nextIncrementalVersion} \
  versions:commit

# Retrieve the new version
NEW_VERSION=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)
echo "New version: $NEW_VERSION"
cd ..
# 2. Generate a changelog based on Conventional Commits
echo "Generating changelog..."

# Determine the latest Git tag
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

# Define the commit range
if [ -z "$LATEST_TAG" ]; then
  COMMIT_RANGE="HEAD"
else
  COMMIT_RANGE="$LATEST_TAG..HEAD"
fi

# Create a temporary changelog file
TEMP_CHANGELOG=$(mktemp)
echo "## [$NEW_VERSION] - $(date +%F)" > "$TEMP_CHANGELOG"
echo "" >> "$TEMP_CHANGELOG"

# Added features
echo "### Added" >> "$TEMP_CHANGELOG"
git log "$COMMIT_RANGE" --pretty=format:"%s" | grep -E "^feat" | sed 's/^feat: \(.*\)/- \1/' >> "$TEMP_CHANGELOG" || echo "- None" >> "$TEMP_CHANGELOG"
echo "" >> "$TEMP_CHANGELOG"

# Bug fixes and refactors
echo "### Changed" >> "$TEMP_CHANGELOG"
git log "$COMMIT_RANGE" --pretty=format:"%s" | grep -E "^fix|^refactor" | sed 's/^\(fix\|refactor\): \(.*\)/- \1: \2/' >> "$TEMP_CHANGELOG" || echo "- None" >> "$TEMP_CHANGELOG"
echo "" >> "$TEMP_CHANGELOG"

# Append existing changelog if it exists
if [ -f CHANGELOG.md ]; then
  cat CHANGELOG.md >> "$TEMP_CHANGELOG"
fi

# Replace the old changelog with the new one
mv "$TEMP_CHANGELOG" CHANGELOG.md
git add CHANGELOG.md

# 3. Commit changes and create a Git tag
echo "Committing changes and creating Git tag..."
git commit -am "chore(release): v$NEW_VERSION"
git tag -a "v$NEW_VERSION" -m "Release v$NEW_VERSION"

# 4. Push changes and tags to the remote repository
echo "Pushing changes to the remote repository..."
git push origin HEAD
git push origin "v$NEW_VERSION"

# 5. Create a GitHub release
echo "Creating GitHub release..."
gh release create "v$NEW_VERSION" --title "Release v$NEW_VERSION" --notes-file CHANGELOG.md

echo "Release process completed successfully!"
