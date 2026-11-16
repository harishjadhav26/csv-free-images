# syntax=docker/dockerfile:1
# DataHub MCE Consumer (v1.7.0.1) - CVE-free, public Chainguard images only
ARG BASE_IMAGE=cgr.dev/chainguard/wolfi-base:latest
ARG RUNTIME_IMAGE=cgr.dev/chainguard/jre:latest
ARG DATAHUB_VERSION=1.7.0.1
ARG DATAHUB_MAJ_VERSION=1.7.0
ARG GITHUB_REPO_URL=https://github.com

FROM ${BASE_IMAGE} AS builder
RUN apk add --no-cache curl unzip

ARG DATAHUB_MCE_URL=${GITHUB_REPO_URL}/datahub-project/datahub/releases/download/v${DATAHUB_VERSION}/datahub-mce-consumer-${DATAHUB_MAJ_VERSION}-bin.zip
RUN mkdir -p /datahub/datahub-mce-consumer && \
    curl -fSL -o /tmp/mce-consumer.zip ${DATAHUB_MCE_URL} && \
    unzip -q /tmp/mce-consumer.zip -d /datahub/datahub-mce-consumer && \
    rm -f /tmp/mce-consumer.zip

FROM ${RUNTIME_IMAGE}

ARG DATAHUB_VERSION=1.7.0.1

ENV DATAHUB_HOME=/datahub/datahub-mce-consumer
ENV DATAHUB_VERSION=${DATAHUB_VERSION}
ENV SERVER_PORT=9090
ENV MANAGEMENT_SERVER_PORT=4319
ENV KAFKA_BOOTSTRAP_SERVER=kafka:9092
ENV KAFKA_CONSUMER_GROUP_ID=datahub-mce-consumer
ENV ELASTICSEARCH_HOST=elasticsearch
ENV ELASTICSEARCH_PORT=9200
ENV ELASTICSEARCH_PROTOCOL=http
ENV ELASTICSEARCH_ENABLED=true
ENV ELASTICSEARCH_USERNAME=""
ENV ELASTICSEARCH_PASSWORD=""
ENV ELASTICSEARCH_AUTH_HEADER="Accept: */*"
ENV ELASTICSEARCH_USE_SSL=false
ENV KAFKA_SCHEMAREGISTRY_URL=http://schema-registry:8081
ENV SKIP_KAFKA_CHECK=false
ENV SKIP_SCHEMA_REGISTRY_CHECK=false
ENV ENABLE_OTEL=false
ENV ENABLE_PROMETHEUS=false
ENV JAVA_OPTS="-Xms512m -Xmx1g"
ENV JAVA_TOOL_OPTIONS=""

WORKDIR /datahub/datahub-mce-consumer

COPY --from=builder /datahub/datahub-mce-consumer /datahub/datahub-mce-consumer

EXPOSE 9090 4319

ENTRYPOINT ["java", "-jar", "/datahub/datahub-mce-consumer/bin/mce-consumer-job.jar"]
