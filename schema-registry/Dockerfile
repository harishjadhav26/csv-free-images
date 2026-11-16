# syntax=docker/dockerfile:1
# Confluent Platform Schema Registry (7.6.0) - CVE-free, public Chainguard images only
# Builder: wolfi-base (download binary) | Runtime: jdk (Java 27 + bash)
ARG BASE_IMAGE=cgr.dev/chainguard/wolfi-base:latest
ARG RUNTIME_IMAGE=cgr.dev/chainguard/jdk:latest
ARG CP_VERSION=7.6.0

FROM ${BASE_IMAGE} AS builder
ARG CP_VERSION=7.6.0
RUN apk add --no-cache curl && \
    mkdir -p /etc/confluent && \
    curl -fSL -o /tmp/confluent.tar.gz "https://packages.confluent.io/archive/${CP_VERSION%.*}/confluent-${CP_VERSION}.tar.gz" && \
    tar -xzf /tmp/confluent.tar.gz -C /etc/confluent --strip-components=1 && \
    rm -f /tmp/confluent.tar.gz

FROM ${RUNTIME_IMAGE}
ARG CP_VERSION=7.6.0

ENV CP_VERSION=${CP_VERSION}
ENV SCHEMA_REGISTRY_HOME=/etc/confluent
ENV PATH=/etc/confluent/bin:${PATH}
ENV SCHEMA_REGISTRY_HOST_NAME=schema-registry
ENV SCHEMA_REGISTRY_LISTENERS=http://0.0.0.0:8081
ENV SCHEMA_REGISTRY_KAFKASTORE_BOOTSTRAP_SERVERS=kafka:9092
ENV SCHEMA_REGISTRY_KAFKASTORE_TOPIC=_schemas
ENV SCHEMA_REGISTRY_KAFKASTORE_REPLICATION_FACTOR=1
ENV SCHEMA_REGISTRY_DEBUG=false
ENV SCHEMA_REGISTRY_MAX_CONNECTIONS=100
ENV SCHEMA_REGISTRY_MIN_INSYNC_REPLICAS=1
ENV SCHEMA_REGISTRY_HEAP_OPTS="-Xms1g -Xmx1g"

WORKDIR /etc/confluent

COPY --from=builder /etc/confluent /etc/confluent

EXPOSE 8081

ENTRYPOINT ["schema-registry-start"]
CMD ["/etc/confluent/etc/schema-registry/schema-registry.properties"]