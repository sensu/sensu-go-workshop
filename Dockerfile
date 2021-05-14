ARG SENSU_CLI_VERSION
ARG VAULT_VERSION

# Use multi-stage Dockerfile to fetch desired sensuctl version
FROM sensu/sensu:${SENSU_CLI_VERSION} AS sensu
RUN sensuctl version

# Use multi-stage Dockerfile to fetch desired vault version
FROM vault:${VAULT_VERSION} AS vault
RUN vault version

# Build the workshop workstation image
#
# Includes the following CLI tools:
#
# - sensuctl
# - sensu-backend (for "sensu-backend init")
# - vault
# - curl
# - jq
# - envsubst
# - docker
# - docker-compose
# - workshop /scripts utilities
FROM alpine:latest AS workshop
COPY --from=sensu /usr/local/bin/sensuctl /usr/local/bin/
COPY --from=sensu /opt/sensu/bin/sensu-backend /usr/local/bin/
COPY --from=vault /bin/vault /usr/local/bin/vault
ENV PATH=$PATH:/usr/local/bin/scripts
RUN apk add curl jq gettext docker-cli docker-compose

WORKDIR /workshop/
