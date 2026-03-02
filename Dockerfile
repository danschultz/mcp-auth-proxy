# Base image version can be overridden at build time:
#   docker build --build-arg BASE_IMAGE=ghcr.io/sigbit/mcp-auth-proxy:v1.2.3 .
ARG BASE_IMAGE=ghcr.io/sigbit/mcp-auth-proxy:latest
FROM ${BASE_IMAGE}

COPY entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
