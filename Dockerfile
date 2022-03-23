ARG WORKSHOP_DOCKER_IMAGE
ARG WORKSHOP_DOCKER_TAG
ARG SENSU_CLI_VERSION
ARG VAULT_VERSION
ARG MATTERMOST_VERSION

# Use multi-stage Dockerfile to fetch desired sensuctl version
FROM ${WORKSHOP_DOCKER_IMAGE}:${WORKSHOP_DOCKER_TAG} as sensu
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
RUN apk add curl jq gettext docker-cli docker-compose
RUN curl -L https://raw.githubusercontent.com/eficode/wait-for/v2.1.3/wait-for -o /usr/bin/wait-for && chmod +x /usr/bin/wait-for
RUN mkdir /lib64
COPY --from=sensu /usr/local/bin/sensuctl /usr/local/bin/
COPY --from=sensu /opt/sensu/bin/sensu-backend /usr/local/bin/
COPY --from=vault /bin/vault /usr/local/bin/vault
COPY --from=mattermost /mattermost/bin/mmctl /usr/local/bin/mmctl
COPY --from=mattermost /lib64/* /lib64/
ENV PATH=$PATH:/usr/local/bin/scripts

WORKDIR /workshop/
