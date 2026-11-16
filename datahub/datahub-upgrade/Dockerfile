# syntax=docker/dockerfile:1
# DataHub Upgrade (v1.7.0.1) - CVE-free, public Chainguard images only
ARG BASE_IMAGE=cgr.dev/chainguard/wolfi-base:latest
ARG RUNTIME_IMAGE=cgr.dev/chainguard/jre:latest
ARG DATAHUB_VERSION=1.7.0.1
ARG GITHUB_REPO_URL=https://github.com

FROM ${BASE_IMAGE} AS builder
RUN apk add --no-cache curl unzip

ARG DATAHUB_UPGRADE_URL=${GITHUB_REPO_URL}/datahub-project/datahub/releases/download/v${DATAHUB_VERSION}/datahub-upgrade-${DATAHUB_VERSION}-bin.zip
RUN mkdir -p /datahub/datahub-upgrade && \
    curl -fSL -o /tmp/upgrade.zip ${DATAHUB_UPGRADE_URL} && \
    unzip -q /tmp/upgrade.zip -d /datahub/datahub-upgrade && \
    rm -f /tmp/upgrade.zip

FROM ${RUNTIME_IMAGE}

ARG DATAHUB_VERSION=1.7.0.1

ENV DATAHUB_HOME=/datahub/datahub-upgrade
ENV DATAHUB_VERSION=${DATAHUB_VERSION}
ENV SPRING_PROFILES_ACTIVE=upgrade
ENV SERVER_PORT=8080
ENV MANAGEMENT_SERVER_PORT=4319
ENV ELASTICSEARCH_HOST=elasticsearch
ENV ELASTICSEARCH_PORT=9200
ENV ELASTICSEARCH_PROTOCOL=http
ENV ELASTICSEARCH_USE_SSL=false
ENV ELASTICSEARCH_USERNAME=""
ENV ELASTICSEARCH_PASSWORD=""
ENV ELASTICSEARCH_AUTH_HEADER="Accept: */*"
ENV NEO4J_HOST=neo4j
ENV ENTITY_SERVICE_IMPL=ebean
ENV EBEAN_DATASOURCE_HOST=mysql
ENV GRAPH_SERVICE_IMPL=elasticsearch
ENV SKIP_ELASTICSEARCH_CHECK=false
ENV SKIP_EBEAN_CHECK=false
ENV SKIP_NEO4J_CHECK=false
ENV ENABLE_OTEL=false
ENV ENABLE_PROMETHEUS=false
ENV JAVA_OPTS=""
ENV JAVA_TOOL_OPTIONS=""

WORKDIR /datahub/datahub-upgrade

COPY --from=builder /datahub/datahub-upgrade /datahub/datahub-upgrade

EXPOSE 8080 4319

ENTRYPOINT ["java", "-Dstats=unsecure", "-Dloader.path=/datahub/datahub-upgrade/lib", "-jar", "/datahub/datahub-upgrade/bin/datahub-upgrade.jar"]
