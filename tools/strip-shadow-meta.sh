#!/usr/bin/env bash
# strip-shadow-meta.sh <fatjar>
# Removes stale vendored Maven metadata (com.fasterxml.jackson.core, com.google.guava,
# tools.jackson.core) embedded inside third-party "shaded" jars (e.g. hazelcast,
# graphql-java, auth-api). This metadata is not used at runtime; trivy uses it only to
# infer dependency versions, so it produces false positives for relocated classes.
# The canonical jackson/guava libs themselves are left untouched.
set -euo pipefail

FATJAR="$(realpath "$1")"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

echo "[strip] Extracting nested jars..."
mkdir -p "$WORK/lib"
cd "$WORK"
unzip -qq "$FATJAR" 'BOOT-INF/lib/*.jar' -d "$WORK" >/dev/null 2>&1 || true

CHANGED=()
for f in BOOT-INF/lib/*.jar; do
  base="$(basename "$f")"
  case "$base" in
    jackson-core-*|jackson-databind-*|jackson-annotations-*|guava-*) continue ;;
  esac
  meta=$(unzip -Z1 "$f" 2>/dev/null | grep -E '^META-INF/maven/(com\.fasterxml\.jackson\.core|com\.google\.guava|tools\.jackson\.core)/' || true)
  if [ -n "$meta" ]; then
    echo "[strip]   $base  (removing vendored jackson/guava metadata)"
    zip -q -d "$f" \
      'META-INF/maven/com.fasterxml.jackson.core/*' \
      'META-INF/maven/com.google.guava/*' \
      'META-INF/maven/tools.jackson.core/*'
    CHANGED+=("BOOT-INF/lib/$base")
  fi
done

if [ ${#CHANGED[@]} -eq 0 ]; then
  echo "[strip] No shadow metadata found."
  exit 0
fi

echo "[strip] Re-inserting ${#CHANGED[@]} modified nested jars"
cd "$WORK"
for entry in "${CHANGED[@]}"; do
  zip -q -0 "$FATJAR" "$entry"
done

echo "[strip] Done."
