#!/bin/bash
set -euo pipefail

# validate-artifact.sh — Asserts banned files/directories are absent from release zip.
# Usage: ./validate-artifact.sh <path-to-artifact.zip>

ARTIFACT_INPUT="${1:?Usage: validate-artifact.sh <artifact-path>}"

# download-artifact@v4 extracts to a directory; also support .zip files.
if [ -d "$ARTIFACT_INPUT" ]; then
  echo "Artifact is a directory (download-artifact@v4 style): $ARTIFACT_INPUT"
  LIST_CMD="find"
elif [ -f "$ARTIFACT_INPUT" ]; then
  echo "Artifact is a zip file: $ARTIFACT_INPUT"
  LIST_CMD="zip"
else
  echo "::error::Artifact not found (neither file nor directory): $ARTIFACT_INPUT"
  exit 1
fi

# Banned patterns: exact name at any depth or directory start.
BANNED_PATTERNS=(
    '(^|/)\.env$'
    '(^|/)\.git/'
    '(^|/)node_modules/'
    '(^|/)__pycache__/'
    '(^|/)\.pytest_cache/'
    '(^|/)\.DS_Store$'
    '(^|/)venv/'
    '(^|/)build/'
)

FAILED=0
for pattern in "${BANNED_PATTERNS[@]}"; do
  if [ "$LIST_CMD" = "find" ]; then
    match=$(find "$ARTIFACT_INPUT" -print | sed "s|^${ARTIFACT_INPUT}/||" | grep -E "$pattern" || true)
  else
    match=$(unzip -l "$ARTIFACT_INPUT" | awk '{print $4}' | grep -E "$pattern" || true)
  fi

  if [ -n "$match" ]; then
    echo "::error::Banned file/directory found in artifact matching pattern: $pattern"
    FAILED=1
  else
    echo "PASS: No match for pattern: $pattern"
  fi
done

if [ "$FAILED" -ne 0 ]; then
  echo "::error::Artifact validation FAILED. Banned files detected."
  exit 1
fi

echo "Artifact validation PASSED. No banned files detected."
