ARG SENSU_CLI_VERSION
ARG VAULT_VERSION
ARG MATTERMOST_VERSION

# Use multi-stage Dockerfile to fetch desired sensuctl version
FROM sensu/sensu:${SENSU_CLI_VERSION} AS sensu
LABEL stage=builder
RUN sensuctl version

# Use multi-stage Dockerfile to fetch desired vault version
FROM vault:${VAULT_VERSION} AS vault
LABEL stage=builder
RUN vault version

# Use multi-stage Dockerfile to fetch desired mmctl version
FROM mattermost/mattermost-team-edition:${MATTERMOST_VERSION} as mattermost
LABEL stage=builder
RUN /mattermost/bin/mmctl version

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
# - mmctl
#
FROM alpine:latest AS workshop
RUN apk add curl jq gettext docker-cli docker-compose && mkdir /lib64
COPY --from=sensu /usr/local/bin/sensuctl /usr/local/bin/
COPY --from=sensu /opt/sensu/bin/sensu-backend /usr/local/bin/
COPY --from=vault /bin/vault /usr/local/bin/vault
COPY --from=mattermost /mattermost/bin/mmctl /usr/local/bin/mmctl
COPY --from=mattermost /lib64/* /lib64/
ENV PATH=$PATH:/usr/local/bin/scripts

WORKDIR /workshop/
