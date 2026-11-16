# syntax=docker/dockerfile:1
# DataHub Frontend React (v1.7.0.1) - CVE-free, public Chainguard images only
ARG BASE_IMAGE=cgr.dev/chainguard/wolfi-base:latest
ARG RUNTIME_IMAGE=cgr.dev/chainguard/jre:latest
ARG DATAHUB_VERSION=1.7.0.1
ARG GITHUB_REPO_URL=https://github.com

FROM ${BASE_IMAGE} AS builder
RUN apk add --no-cache curl tar nodejs npm

ARG DATAHUB_FRONTEND_URL=${GITHUB_REPO_URL}/datahub-project/datahub-frontend-react/archive/refs/tags/v${DATAHUB_VERSION}.tar.gz
RUN mkdir -p /datahub-frontend && \
    curl -fSL -o /tmp/frontend.tar.gz ${DATAHUB_FRONTEND_URL} && \
    tar -xzf /tmp/frontend.tar.gz -C /datahub-frontend --strip-components=1 && \
    rm -f /tmp/frontend.tar.gz && \
    cd /datahub-frontend && npm ci --omit=dev && npm run build

FROM ${RUNTIME_IMAGE}

ARG DATAHUB_VERSION=1.7.0.1

ENV DATAHUB_HOME=/datahub-frontend
ENV DATAHUB_FRONTEND_VERSION=${DATAHUB_VERSION}
ENV SERVER_PORT=9002
ENV MANAGEMENT_SERVER_PORT=4319
ENV MFE_CONFIG_FILE_PATH=/datahub-frontend/conf/mfe.config.dev.yaml
ENV JAVA_MEMORY_OPTS="-Xms512m -Xmx1024m"
ENV ENABLE_OTEL=false
ENV ENABLE_PROMETHEUS=false
ENV JAVA_TOOL_OPTIONS=""

WORKDIR /datahub-frontend

COPY --from=builder /datahub-frontend /datahub-frontend

EXPOSE 9002

ENTRYPOINT ["java", "-jar", "/datahub-frontend/bin/datahub-frontend"]
