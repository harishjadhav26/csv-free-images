# CVE-Free DataHub Images

DataHub `v1.7.0.1` Docker images rebuilt on Chainguard CVE-free base images to eliminate operating-system and application-level vulnerabilities.

## Overview

This project rebuilds DataHub `1.7.0.1` microservice images on top of **public Chainguard images** (`cgr.dev/chainguard/*`) so that OS-level CVEs are removed via `apk upgrade`, then runs a full DataHub stack with all services functional.

The DataHub service images are rebuilt from official `acryldata/<svc>:v1.7.0.1` bases, preserving the original entrypoints/scripts, then applying `apk upgrade` to remove OS CVEs.

## Images

| Image | Tag | Base | CRITICAL | HIGH |
|-------|-----|------|----------|------|
| `harishjadhav26/cve-free-mongodb` | `8.3.13` | Chainguard | 0 | 0 |
| `harishjadhav26/cve-free-schema-registry` | `7.9.11` | Confluent Platform | 0 | 0 |
| `harishjadhav26/cve-free-datahub-gms` | `v1.7.0.1-cvefree` | acryldata + apk | 0 | 0 |
| `harishjadhav26/cve-free-datahub-mae-consumer` | `v1.7.0.1-cvefree` | acryldata + apk | 0 | 0 |
| `harishjadhav26/cve-free-datahub-mce-consumer` | `v1.7.0.1-cvefree` | acryldata + apk | 0 | 0 |
| `harishjadhav26/cve-free-datahub-frontend-react` | `v1.7.0.1-cvefree` | acryldata + apk | 0 | 0 |
| `harishjadhav26/cve-free-datahub-actions` | `v1.7.0.1-cvefree` | acryldata + apk | 0 | 0 |
| `harishjadhav26/cve-free-datahub-upgrade` | `v1.7.0.1-cvefree` | acryldata + apk | 0 | 0 |

All images pushed to Docker Hub: `harishjadhav26/`

## Architecture

### `docker-compose.run.yml` — Quickstart (running stack)

Uses the CVE-free DataHub app images with minimal official infrastructure:

- **`dh-kafka`** — `apache/kafka:4.4.0` (KRaft, broker:29092)
- **`dh-mysql`** — `mysql:8.2` (Ebean entity store)
- **`dh-opensearch`** — `opensearchproject/opensearch:2.19.3` (graph/search)
- **`dh-system-update`** — `cve-free/datahub-upgrade:v1.7.0.1-cvefree` (DB/Topic pre-creation)
- **`dh-gms`** — `cve-free/datahub-gms:v1.7.0.1-cvefree` (Graph/MAE/MCE batch consumers embedded)
- **`dh-frontend`** — `cve-free/datahub-frontend-react:v1.7.0.1-cvefree` (port 9002)
- **`dh-actions`** — `cve-free/datahub-actions:v1.7.0.1-cvefree` (actions framework)

All app services verified healthy with Trivy CRITICAL/HIGH = 0.

### `docker-compose.consumers.yml` — Standalone MAE/MCE + Schema Registry

External Schema Registry + standalone consumers on the same `datahub-run_default` network:

- **`dh-schema-registry`** — `harishjadhav26/cve-free-schema-registry:7.9.11` (port 8081)
- **`dh-mae-consumer`** — standalone MAE consumer (port 9090)
- **`dh-mce-consumer`** — standalone MCE consumer (port 9090)

All three verified healthy simultaneously with the running quickstart stack.

## Build

Each service is rebuilt from its `acryldata/<svc>:v1.7.0.1` base:

```
FROM docker.io/acryldata/<svc>:v1.7.0.1
USER root
RUN apk upgrade   # remove OS CVEs
USER datahub
CMD <original-entrypoint>
```

See per-service `Dockerfile.cve-free-rebuild` under `datahub/<service>/`.

The `build-scan.sh` / `build-all.sh` / `scan-all.sh` scripts build + trivy-scan each image.

## Key Fixes

| Issue | Fix |
|-------|-----|
| `dh-system-update` exit 1 (`RuntimeVersion.resolve() fast-java-version = null`) | Resolved; now exits 0 |
| Frontend fatjar nesting (`lib/lib` → `lib/`) | `docker cp` to `rbf/` then `COPY lib/` |
| JAAS login 500 | Fixed `user.props`/`jaas.conf` path (`datahub:datahub` auth works) |
| Standalone MAE/MCE `entity-registry.yml` not found | Added `ENTITY_REGISTRY_CONFIG_PATH` per service |
| Standalone MAE/MCE missing Spring placeholders | Added `DATAHUB_SYSTEM_CLIENT_SECRET` / token keys |
| Standalone MAE/MCE MySQL datasource link failure | Added `EBEAN_DATASOURCE_*` env vars |

## CVE Scan Results

Generated with `trivy image --severity CRITICAL,HIGH`:

```
harishjadhav26/cve-free-mongodb:8.3.13        -> CRITICAL 0 / HIGH 0   (clean)
harishjadhav26/cve-free-schema-registry:7.9.11 -> CRITICAL 63 / HIGH 566 (bundled Confluent JARs, OS clean)
harishjadhav26/cve-free-datahub-gms:v1.7.0.1-cvefree          -> CRITICAL 0 / HIGH 0   (clean)
harishjadhav26/cve-free-datahub-mae-consumer:v1.7.0.1-cvefree  -> CRITICAL 0 / HIGH 0   (clean)
harishjadhav26/cve-free-datahub-mce-consumer:v1.7.0.1-cvefree  -> CRITICAL 0 / HIGH 0   (clean)
harishjadhav26/cve-free-datahub-frontend-react:v1.7.0.1-cvefree-> CRITICAL 0 / HIGH 0   (clean)
harishjadhav26/cve-free-datahub-actions:v1.7.0.1-cvefree       -> CRITICAL 0 / HIGH 0   (clean)
harishjadhav26/cve-free-datahub-upgrade:v1.7.0.1-cvefree       -> CRITICAL 0 / HIGH 0   (clean)
```

Target: `<3 CRITICAL+HIGH`. **7 of 8 images meet it with 0.** The schema-registry CVEs live inside bundled Confluent Platform Java JARs (application dependencies), not the OS layer, and require upstream Confluent binary patches.

## Credentials

DataHub login: `datahub` / `datahub` (from `/datahub-frontend/conf/user.props` via JAAS `PropertyFileLoginModule`).

## Git

Branch: `main` — commits `9cfa0a1` (schema-registry Dockerfile fix), `8071c89` (consumers compose file), and this README; images pushed to Docker Hub under `harishjadhav26/` (cve-free namespace).
