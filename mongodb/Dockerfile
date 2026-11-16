# syntax=docker/dockerfile:1
# MongoDB (7.x / 8.x / 9.x) - CVE-free, public Chainguard image
# Uses cgr.dev/chainguard/mongodb (distroless, no shell in runtime)
ARG MONGODB_VERSION=latest

FROM cgr.dev/chainguard/mongodb:${MONGODB_VERSION}

ENV MONGODB_VERSION=${MONGODB_VERSION}
ENV PATH=/mongodb/bin:${PATH}
ENV HOME=/data/db

VOLUME ["/data/db"]

EXPOSE 27017

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD ["mongosh", "--quiet", "--eval", "db.runCommand({ping:1})"] || exit 1

ENTRYPOINT ["mongod"]
CMD ["--dbpath", "/data/db", "--bind_ip", "0.0.0.0"]
