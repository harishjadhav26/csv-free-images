#!/usr/bin/env bash
#
# build-scan.sh - Build and CVE-scan CVE-free Docker images
#
# Usage:
#   ./build-scan.sh <service> [version]
#
# Services:
#   datahub-gms, datahub-mae-consumer, datahub-mce-consumer,
#   datahub-frontend-react, datahub-actions, datahub-upgrade,
#   mongodb, elasticsearch, cp-kafka, zookeeper, schema-registry
#   all       (builds every service)
#
# Examples:
#   ./build-scan.sh datahub-gms 1.7.0.1
#   ./build-scan.sh mongodb 7.0.28
#   ./build-scan.sh all
#
set -euo pipefail

REGISTRY="${REGISTRY:-cve-free}"
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRIVY_SEVERITY="${TRIVY_SEVERITY:-CRITICAL,HIGH}"

# ---------------------------------------------------------------------------
# Helper functions
# ---------------------------------------------------------------------------
log()  { printf '[INFO] %s\n' "$*"; }
err()  { printf '[ERROR] %s\n' "$*" >&2; }
warn() { printf '[WARN] %s\n' "$*"; }

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    err "Required command not found: $1"
    exit 1
  fi
}

check_chainguard_auth() {
  if ! docker manifest inspect cgr.dev/chainguard/java:21-jre >/dev/null 2>&1; then
    err "Cannot access cgr.dev/chainguard registry. Run: docker login cgr.dev"
    exit 1
  fi
}

scan_image() {
  local image="$1"
  log "Scanning ${image} for CVEs (severity: ${TRIVY_SEVERITY})..."
  if ! trivy image --exit-code 1 --severity "${TRIVY_SEVERITY}" "${image}"; then
    err "CVE scan FAILED for ${image}"
    return 1
  fi
  log "CVE scan PASSED for ${image}"
  return 0
}

# ---------------------------------------------------------------------------
# Build functions
# ---------------------------------------------------------------------------
build_datahub_gms() {
  local version="${1:-1.7.0.1}"
  local image="${REGISTRY}/datahub-gms:${version}"
  log "Building datahub-gms ${version} -> ${image}"
  docker build \
    --build-arg DATAHUB_VERSION="${version}" \
    -t "${image}" \
    "${BASE_DIR}/datahub/datahub-gms"
  scan_image "${image}"
}

build_datahub_mae_consumer() {
  local version="${1:-1.7.0.1}"
  local image="${REGISTRY}/datahub-mae-consumer:${version}"
  log "Building datahub-mae-consumer ${version} -> ${image}"
  docker build \
    --build-arg DATAHUB_VERSION="${version}" \
    -t "${image}" \
    "${BASE_DIR}/datahub/datahub-mae-consumer"
  scan_image "${image}"
}

build_datahub_mce_consumer() {
  local version="${1:-1.7.0.1}"
  local image="${REGISTRY}/datahub-mce-consumer:${version}"
  log "Building datahub-mce-consumer ${version} -> ${image}"
  docker build \
    --build-arg DATAHUB_VERSION="${version}" \
    -t "${image}" \
    "${BASE_DIR}/datahub/datahub-mce-consumer"
  scan_image "${image}"
}

build_datahub_frontend_react() {
  local version="${1:-1.7.0.1}"
  local image="${REGISTRY}/datahub-frontend-react:${version}"
  log "Building datahub-frontend-react ${version} -> ${image}"
  docker build \
    --build-arg DATAHUB_VERSION="${version}" \
    -t "${image}" \
    "${BASE_DIR}/datahub/datahub-frontend-react"
  scan_image "${image}"
}

build_datahub_actions() {
  local version="${1:-1.7.0.1}"
  local image="${REGISTRY}/datahub-actions:${version}"
  log "Building datahub-actions ${version} -> ${image}"
  docker build \
    --build-arg DATAHUB_VERSION="${version}" \
    --build-arg RELEASE_VERSION="${version}" \
    -t "${image}" \
    "${BASE_DIR}/datahub/datahub-actions"
  scan_image "${image}"
}

build_datahub_upgrade() {
  local version="${1:-1.7.0.1}"
  local image="${REGISTRY}/datahub-upgrade:${version}"
  log "Building datahub-upgrade ${version} -> ${image}"
  docker build \
    --build-arg DATAHUB_VERSION="${version}" \
    -t "${image}" \
    "${BASE_DIR}/datahub/datahub-upgrade"
  scan_image "${image}"
}

build_mongodb() {
  local version="${1:-7.0.28}"
  local image="${REGISTRY}/mongodb:${version}"
  log "Building mongodb ${version} -> ${image}"
  docker build \
    --build-arg MONGODB_VERSION="${version}" \
    -t "${image}" \
    "${BASE_DIR}/mongodb"
  scan_image "${image}"
}

build_elasticsearch() {
  local version="${1:-8.15.0}"
  local image="${REGISTRY}/elasticsearch:${version}"
  log "Building elasticsearch ${version} -> ${image}"
  docker build \
    --build-arg ELASTICSEARCH_VERSION="${version}" \
    -t "${image}" \
    "${BASE_DIR}/elasticsearch"
  scan_image "${image}"
}

build_cp_kafka() {
  local version="${1:-7.6.0}"
  local image="${REGISTRY}/cp-kafka:${version}"
  log "Building cp-kafka ${version} -> ${image}"
  docker build \
    --build-arg CP_VERSION="${version}" \
    -t "${image}" \
    "${BASE_DIR}/cp-kafka"
  scan_image "${image}"
}

build_zookeeper() {
  local version="${1:-7.6.0}"
  local image="${REGISTRY}/zookeeper:${version}"
  log "Building zookeeper ${version} -> ${image}"
  docker build \
    --build-arg CP_VERSION="${version}" \
    -t "${image}" \
    "${BASE_DIR}/zookeeper"
  scan_image "${image}"
}

build_schema_registry() {
  local version="${1:-7.6.0}"
  local image="${REGISTRY}/schema-registry:${version}"
  log "Building schema-registry ${version} -> ${image}"
  docker build \
    --build-arg CP_VERSION="${version}" \
    -t "${image}" \
    "${BASE_DIR}/schema-registry"
  scan_image "${image}"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
usage() {
  cat <<EOF
Usage: $0 <service> [version]

Services:
  datahub-gms          DataHub GMS (default 1.7.0.1)
  datahub-mae-consumer DataHub MAE consumer (default 1.7.0.1)
  datahub-mce-consumer DataHub MCE consumer (default 1.7.0.1)
  datahub-frontend-react DataHub frontend-react (default 1.7.0.1)
  datahub-actions      DataHub actions (default 1.7.0.1)
  datahub-upgrade      DataHub upgrade (default 1.7.0.1)
  mongodb              MongoDB (default 7.0.28)
  elasticsearch        Elasticsearch (default 8.15.0)
  cp-kafka             Confluent Kafka (default 7.6.0)
  zookeeper            Confluent Platform Zookeeper (default 7.6.0)
  schema-registry      Confluent Schema Registry (default 7.6.0)
  all                  Build and scan every service

Environment variables:
  REGISTRY           Image registry prefix (default: cve-free)
  TRIVY_SEVERITY     Trivy severity filter (default: CRITICAL,HIGH)

Examples:
  $0 datahub-gms 1.7.0.1
  $0 mongodb 8.0.4
  $0 all
EOF
}

main() {
  require_cmd docker
  require_cmd trivy

  local service="${1:-}"
  local version="${2:-}"

  if [[ -z "${service}" ]]; then
    usage
    exit 1
  fi

  check_chainguard_auth

  case "${service}" in
    datahub-gms)
      build_datahub_gms "${version:-1.7.0.1}"
      ;;
    datahub-mae-consumer)
      build_datahub_mae_consumer "${version:-1.7.0.1}"
      ;;
    datahub-mce-consumer)
      build_datahub_mce_consumer "${version:-1.7.0.1}"
      ;;
    datahub-frontend-react)
      build_datahub_frontend_react "${version:-1.7.0.1}"
      ;;
    datahub-actions)
      build_datahub_actions "${version:-1.7.0.1}"
      ;;
    datahub-upgrade)
      build_datahub_upgrade "${version:-1.7.0.1}"
      ;;
    mongodb)
      build_mongodb "${version:-7.0.28}"
      ;;
    elasticsearch)
      build_elasticsearch "${version:-8.15.0}"
      ;;
    cp-kafka)
      build_cp_kafka "${version:-7.6.0}"
      ;;
    zookeeper)
      build_zookeeper "${version:-7.6.0}"
      ;;
    schema-registry)
      build_schema_registry "${version:-7.6.0}"
      ;;
    all)
      local failed=0
      build_datahub_gms "1.7.0.1" || failed=1
      build_datahub_mae_consumer "1.7.0.1" || failed=1
      build_datahub_mce_consumer "1.7.0.1" || failed=1
      build_datahub_frontend_react "1.7.0.1" || failed=1
      build_datahub_actions "1.7.0.1" || failed=1
      build_datahub_upgrade "1.7.0.1" || failed=1
      build_mongodb "7.0.28" || failed=1
      build_elasticsearch "8.15.0" || failed=1
      build_cp_kafka "7.6.0" || failed=1
      build_zookeeper "7.6.0" || failed=1
      build_schema_registry "7.6.0" || failed=1
      if [[ ${failed} -ne 0 ]]; then
        err "One or more build/scan steps failed"
        exit 1
      fi
      log "All images built and scanned successfully"
      ;;
    *)
      err "Unknown service: ${service}"
      usage
      exit 1
      ;;
  esac
}

main "$@"
