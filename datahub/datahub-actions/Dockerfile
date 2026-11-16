# syntax=docker/dockerfile:1
# DataHub Actions (v1.7.0.1) - CVE-free, public Chainguard images only
# Builder: wolfi-base (download source) | Runtime: python:latest
ARG BASE_IMAGE=cgr.dev/chainguard/wolfi-base:latest
ARG RUNTIME_IMAGE=cgr.dev/chainguard/python:latest
ARG DATAHUB_VERSION=1.7.0.1
ARG PYTHON_VERSION=3.11
ARG GITHUB_REPO_URL=https://github.com
ARG RELEASE_VERSION=${DATAHUB_VERSION}

FROM ${BASE_IMAGE} AS builder
RUN apk add --no-cache curl tar

ARG DATAHUB_ACTIONS_URL=${GITHUB_REPO_URL}/datahub-project/datahub-actions/archive/refs/tags/v${DATAHUB_VERSION}.tar.gz
RUN mkdir -p /datahub-actions-src && \
    curl -fSL -o /tmp/datahub-actions.tar.gz ${DATAHUB_ACTIONS_URL} && \
    tar -xzf /tmp/datahub-actions.tar.gz -C /datahub-actions-src --strip-components=1 && \
    rm -f /tmp/datahub-actions.tar.gz

FROM ${RUNTIME_IMAGE}

ARG DATAHUB_VERSION=1.7.0.1
ARG RELEASE_VERSION=${DATAHUB_VERSION}

ENV DATAHUB_HOME=/home/datahub
ENV DATAHUB_ACTIONS_VERSION=${DATAHUB_VERSION}
ENV DATAHUB_GMS_PROTOCOL=http
ENV DATAHUB_GMS_HOST=datahub-gms
ENV DATAHUB_GMS_PORT=8080
ENV DATAHUB_GMS_STARTUP_TIMEOUT_SEC=240
ENV DATAHUB_ACTIONS_SYSTEM_CONFIGS_PATH=/etc/datahub/actions/system/conf
ENV DATAHUB_ACTIONS_USER_CONFIGS_PATH=/etc/datahub/actions/conf
ENV DATAHUB_ACTIONS_MONITORING_ENABLED=false
ENV DATAHUB_ACTIONS_MONITORING_PORT=8000
ENV VIRTUAL_ENV=/home/datahub/.venv
ENV PATH="${VIRTUAL_ENV}/bin:$PATH"

WORKDIR /home/datahub

COPY --from=builder /datahub-actions-src /datahub-actions

RUN python -m venv /home/datahub/.venv && \
    pip install --no-cache-dir /datahub-actions[all]

EXPOSE 8080

ENTRYPOINT []
CMD ["datahub-actions", "actions"]
