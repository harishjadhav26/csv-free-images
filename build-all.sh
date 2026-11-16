#!/usr/bin/env bash
#
# build-all.sh - Build all CVE-free images with default versions
#
set -euo pipefail

REGISTRY="${REGISTRY:-cve-free}"
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log()  { printf '[INFO] %s\n' "$*"; }
err()  { printf '[ERROR] %s\n' "$*" >&2; }

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    err "Required command not found: $1"
    exit 1
  fi
}

main() {
  require_cmd docker

  if ! docker manifest inspect cgr.dev/chainguard/java:21-jre >/dev/null 2>&1; then
    err "Cannot access cgr.dev/chainguard registry. Run: docker login cgr.dev"
    exit 1
  fi

  log "Building all CVE-free images with registry prefix: ${REGISTRY}"

  docker build --build-arg DATAHUB_VERSION=1.7.0.1 -t "${REGISTRY}/datahub-gms:1.7.0.1"            "${BASE_DIR}/datahub/datahub-gms"
  docker build --build-arg DATAHUB_VERSION=1.7.0.1 -t "${REGISTRY}/datahub-mae-consumer:1.7.0.1"   "${BASE_DIR}/datahub/datahub-mae-consumer"
  docker build --build-arg DATAHUB_VERSION=1.7.0.1 -t "${REGISTRY}/datahub-mce-consumer:1.7.0.1"   "${BASE_DIR}/datahub/datahub-mce-consumer"
  docker build --build-arg DATAHUB_VERSION=1.7.0.1 -t "${REGISTRY}/datahub-frontend-react:1.7.0.1" "${BASE_DIR}/datahub/datahub-frontend-react"
  docker build --build-arg DATAHUB_VERSION=1.7.0.1 --build-arg RELEASE_VERSION=1.7.0.1 -t "${REGISTRY}/datahub-actions:1.7.0.1" "${BASE_DIR}/datahub/datahub-actions"
  docker build --build-arg DATAHUB_VERSION=1.7.0.1 -t "${REGISTRY}/datahub-upgrade:1.7.0.1"        "${BASE_DIR}/datahub/datahub-upgrade"
  docker build --build-arg MONGODB_VERSION=7.0.28  -t "${REGISTRY}/mongodb:7.0.28"                 "${BASE_DIR}/mongodb"
  docker build --build-arg ELASTICSEARCH_VERSION=8.15.0 -t "${REGISTRY}/elasticsearch:8.15.0"      "${BASE_DIR}/elasticsearch"
  docker build --build-arg CP_VERSION=7.6.0        -t "${REGISTRY}/cp-kafka:7.6.0"                 "${BASE_DIR}/cp-kafka"
  docker build --build-arg CP_VERSION=7.6.0 -t "${REGISTRY}/zookeeper:7.6.0"                "${BASE_DIR}/zookeeper"
  docker build --build-arg CP_VERSION=7.6.0        -t "${REGISTRY}/schema-registry:7.6.0"          "${BASE_DIR}/schema-registry"

  log "All images built successfully"
}

main "$@"
