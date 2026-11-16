# syntax=docker/dockerfile:1
# Confluent Platform Kafka (7.6.0) - CVE-free, public Chainguard images only
# Builder: wolfi-base (download binary) | Runtime: jre:latest (Java 27)
ARG BASE_IMAGE=cgr.dev/chainguard/wolfi-base:latest
ARG RUNTIME_IMAGE=cgr.dev/chainguard/jre:latest
ARG CP_VERSION=7.6.0
ARG KAFKA_BASE_URL=https://packages.confluent.io/archive/${CP_VERSION}

FROM ${BASE_IMAGE} AS builder
RUN apk add --no-cache curl tar

ARG KAFKA_URL=${KAFKA_BASE_URL}/confluent-kafka-${CP_VERSION}.tar.gz
RUN mkdir -p /etc/confluent && \
    curl -fSL -o /tmp/kafka.tar.gz ${KAFKA_URL} && \
    tar -xzf /tmp/kafka.tar.gz -C /etc/confluent --strip-components=1 && \
    rm -f /tmp/kafka.tar.gz

FROM ${RUNTIME_IMAGE}

ARG CP_VERSION=7.6.0

ENV CP_VERSION=${CP_VERSION}
ENV KAFKA_HOME=/etc/confluent
ENV PATH=/etc/confluent/bin:${PATH}
ENV KAFKA_BROKER_ID=1
ENV KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181
ENV KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://kafka:9092
ENV KAFKA_LISTENERS=PLAINTEXT://0.0.0.0:9092
ENV KAFKA_LOG_DIRS=/var/lib/kafka/data
ENV KAFKA_NUM_PARTITIONS=1
ENV KAFKA_DEFAULT_REPLICATION_FACTOR=1
ENV KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1
ENV KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR=1
ENV KAFKA_TRANSACTION_STATE_LOG_MIN_ISR=1
ENV KAFKA_AUTO_CREATE_TOPICS_ENABLE=true
ENV KAFKA_DELETE_TOPIC_ENABLE=true
ENV KAFKA_JMX_PORT=9101
ENV KAFKA_HEAP_OPTS="-Xms1g -Xmx1g"
ENV KAFKA_PERFORMANCE_JVM_OPTS="-server -XX:+UseG1GC -XX:MaxGCPauseMillis=20"

WORKDIR /etc/confluent

COPY --from=builder /etc/confluent /etc/confluent

RUN mkdir -p /var/lib/kafka/data /var/log/kafka

EXPOSE 9092 9101

ENTRYPOINT ["kafka-server-start.sh"]
CMD ["/etc/kafka/server.properties"]
