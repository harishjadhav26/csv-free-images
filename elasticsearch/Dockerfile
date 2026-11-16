# syntax=docker/dockerfile:1
# Elasticsearch (8.x) - CVE-free, public Chainguard images only
# Builder: wolfi-base (download binary) | Runtime: jre:latest (Java 27)
ARG BASE_IMAGE=cgr.dev/chainguard/wolfi-base:latest
ARG RUNTIME_IMAGE=cgr.dev/chainguard/jre:latest
ARG ELASTICSEARCH_VERSION=8.15.0
ARG ELASTICSEARCH_BASE_URL=https://artifacts.elastic.co/downloads/elasticsearch

FROM ${BASE_IMAGE} AS builder
RUN apk add --no-cache curl tar

ARG ELASTICSEARCH_URL=${ELASTICSEARCH_BASE_URL}/elasticsearch-${ELASTICSEARCH_VERSION}-linux-x86_64.tar.gz
RUN mkdir -p /tmp/elasticsearch && \
    curl -fSL -o /tmp/elasticsearch.tar.gz ${ELASTICSEARCH_URL} && \
    tar -xzf /tmp/elasticsearch.tar.gz -C /tmp/elasticsearch --strip-components=1 && \
    rm -f /tmp/elasticsearch.tar.gz

FROM ${RUNTIME_IMAGE}

ARG ELASTICSEARCH_VERSION=8.15.0

ENV ELASTICSEARCH_HOME=/elasticsearch
ENV ELASTICSEARCH_VERSION=${ELASTICSEARCH_VERSION}
ENV PATH=/elasticsearch/bin:${PATH}
ENV ES_JAVA_OPTS="-Xms1g -Xmx1g"
ENV cluster.name=cve-free-es
ENV discovery.type=single-node
ENV http.port=9200
ENV transport.port=9300
ENV path.data=/data/elasticsearch
ENV path.logs=/var/log/elasticsearch

WORKDIR /elasticsearch

COPY --from=builder /tmp/elasticsearch /elasticsearch

RUN mkdir -p /data/elasticsearch /var/log/elasticsearch

VOLUME ["/data/elasticsearch"]

EXPOSE 9200 9300

ENTRYPOINT ["elasticsearch"]
CMD ["-E", "cluster.name=cve-free-es", "-E", "discovery.type=single-node"]
