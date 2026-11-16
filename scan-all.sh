#!/usr/bin/env bash
#
# scan-all.sh - CVE scan all built images
#
set -euo pipefail

REGISTRY="${REGISTRY:-cve-free}"
TRIVY_SEVERITY="${TRIVY_SEVERITY:-CRITICAL,HIGH}"
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log()  { printf '[INFO] %s\n' "$*"; }
err()  { printf '[ERROR] %s\n' "$*" >&2; }

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    err "Required command not found: $1"
    exit 1
  fi
}

scan_image() {
  local image="$1"
  log "Scanning ${image} (severity: ${TRIVY_SEVERITY})..."
  if ! trivy image --exit-code 1 --severity "${TRIVY_SEVERITY}" "${image}"; then
    err "CVE scan FAILED for ${image}"
    return 1
  fi
  log "CVE scan PASSED for ${image}"
  return 0
}

main() {
  require_cmd trivy

  local failed=0
  local images=(
    "${REGISTRY}/datahub-gms:1.7.0.1"
    "${REGISTRY}/datahub-mae-consumer:1.7.0.1"
    "${REGISTRY}/datahub-mce-consumer:1.7.0.1"
    "${REGISTRY}/datahub-frontend-react:1.7.0.1"
    "${REGISTRY}/datahub-actions:1.7.0.1"
    "${REGISTRY}/datahub-upgrade:1.7.0.1"
    "${REGISTRY}/mongodb:7.0.28"
    "${REGISTRY}/elasticsearch:8.15.0"
    "${REGISTRY}/cp-kafka:7.6.0"
    "${REGISTRY}/zookeeper:7.6.0"
    "${REGISTRY}/schema-registry:7.6.0"
  )

  for image in "${images[@]}"; do
    if ! docker image inspect "${image}" >/dev/null 2>&1; then
      warn "Image not found locally, skipping: ${image}"
      continue
    fi
    scan_image "${image}" || failed=1
  done

  if [[ ${failed} -ne 0 ]]; then
    err "One or more CVE scans failed"
    exit 1
  fi
  log "All CVE scans passed"
}

main "$@"
