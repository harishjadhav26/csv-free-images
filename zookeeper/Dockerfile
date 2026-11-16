# syntax=docker/dockerfile:1
# Confluent Platform Zookeeper (7.6.0) - CVE-free, public Chainguard images only
# Uses CP zookeeper (not Apache) for consistency with CP Kafka and Schema Registry
# Builder: wolfi-base (download binary) | Runtime: jre:latest (Java 27)
ARG BASE_IMAGE=cgr.dev/chainguard/wolfi-base:latest
ARG RUNTIME_IMAGE=cgr.dev/chainguard/jre:latest
ARG CP_VERSION=7.6.0
ARG ZOOKEEPER_BASE_URL=https://packages.confluent.io/archive/${CP_VERSION}

FROM ${BASE_IMAGE} AS builder
RUN apk add --no-cache curl tar

ARG ZOOKEEPER_URL=${ZOOKEEPER_BASE_URL}/confluent-zookeeper-${CP_VERSION}.tar.gz
RUN mkdir -p /etc/confluent && \
    curl -fSL -o /tmp/zookeeper.tar.gz ${ZOOKEEPER_URL} && \
    tar -xzf /tmp/zookeeper.tar.gz -C /etc/confluent --strip-components=1 && \
    rm -f /tmp/zookeeper.tar.gz

FROM ${RUNTIME_IMAGE}

ARG CP_VERSION=7.6.0

ENV CP_VERSION=${CP_VERSION}
ENV ZOOKEEPER_HOME=/etc/confluent
ENV PATH=/etc/confluent/bin:${PATH}
ENV ZOOKEEPER_CLIENT_PORT=2181
ENV ZOOKEEPER_TICK_TIME=2000
ENV ZOOKEEPER_INIT_LIMIT=10
ENV ZOOKEEPER_SYNC_LIMIT=5
ENV ZOOKEEPER_AUTOPURGE_PURGE_INTERVAL=1
ENV ZOOKEEPER_AUTOPURGE_SNAP_RETAIN_COUNT=3
ENV ZOOKEEPER_DATA_DIR=/var/lib/zookeeper/data
ENV ZOOKEEPER_DATA_LOG_DIR=/var/lib/zookeeper/log
ENV ZOOKEEPER_SERVER_ID=1
ENV ZOOKEEPER_SERVERS=zookeeper:2888:3888

WORKDIR /etc/confluent

COPY --from=builder /etc/confluent /etc/confluent

RUN mkdir -p /var/lib/zookeeper/data /var/lib/zookeeper/log /var/log/zookeeper

VOLUME ["/var/lib/zookeeper/data", "/var/lib/zookeeper/log"]

EXPOSE 2181 2888 3888

ENTRYPOINT ["zookeeper-server-start.sh"]
CMD ["/etc/kafka/zookeeper.properties"]
