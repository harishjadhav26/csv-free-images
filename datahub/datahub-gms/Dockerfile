# syntax=docker/dockerfile:1
# DataHub GMS (v1.7.0.1) - CVE-free, public Chainguard images only (no auth required)
# Builder: wolfi-base (download binaries) | Runtime: jre:latest (Java 27, distroless)
ARG APP_ENV=prod
ARG BASE_IMAGE=cgr.dev/chainguard/wolfi-base:latest
ARG RUNTIME_IMAGE=cgr.dev/chainguard/jre:latest
ARG DATAHUB_VERSION=1.7.0.1
ARG GITHUB_REPO_URL=https://github.com

FROM ${BASE_IMAGE} AS builder
RUN apk add --no-cache curl ca-certificates

ARG DATAHUB_GMS_URL=${GITHUB_REPO_URL}/datahub-project/datahub/releases/download/v${DATAHUB_VERSION}/datahub-gms-${DATAHUB_VERSION}.jar
RUN mkdir -p /datahub/datahub-gms/bin && \
    curl -fSL -o /datahub/datahub-gms/bin/war.war ${DATAHUB_GMS_URL}

FROM ${RUNTIME_IMAGE}

ARG DATAHUB_VERSION=1.7.0.1

ENV DATAHUB_HOME=/datahub/datahub-gms
ENV DATAHUB_VERSION=${DATAHUB_VERSION}
ENV SERVER_PORT=8080
ENV MANAGEMENT_SERVER_PORT=4319
ENV KAFKA_BOOTSTRAP_SERVER=kafka:9092
ENV KAFKA_CONSUMER_GROUP_ID=datahub-gms
ENV ELASTICSEARCH_HOST=elasticsearch
ENV ELASTICSEARCH_PORT=9200
ENV ELASTICSEARCH_PROTOCOL=http
ENV ELASTICSEARCH_ENABLED=true
ENV ELASTICSEARCH_USERNAME=""
ENV ELASTICSEARCH_PASSWORD=""
ENV ELASTICSEARCH_AUTH_HEADER="Accept: */*"
ENV ELASTICSEARCH_USE_SSL=false
ENV ENTITY_SERVICE_IMPL=ebean
ENV EBEAN_DATASOURCE_HOST=mysql
ENV EBEAN_DATASOURCE_PORT=3306
ENV GRAPH_SERVICE_IMPL=elasticsearch
ENV NEO4J_HOST=neo4j
ENV KAFKA_SCHEMAREGISTRY_URL=http://schema-registry:8081
ENV SKIP_KAFKA_CHECK=false
ENV SKIP_SCHEMA_REGISTRY_CHECK=false
ENV SKIP_NEO4J_CHECK=false
ENV SKIP_EBEAN_CHECK=false
ENV SKIP_CASSANDRA_CHECK=false
ENV ENABLE_OTEL=false
ENV ENABLE_PROMETHEUS=false
ENV JAVA_OPTS="-Xms1g -Xmx2g"
ENV JAVA_TOOL_OPTIONS=""
ENV DATAHUB_GMS_BASE_PATH="/"

WORKDIR /datahub/datahub-gms

COPY --from=builder /datahub/datahub-gms/bin/war.war /datahub/datahub-gms/bin/war.war

EXPOSE 8080 4319

ENTRYPOINT ["java", "-jar", "/datahub/datahub-gms/bin/war.war"]
