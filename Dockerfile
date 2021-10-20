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
FROM golang:1.17-alpine as mattermost
LABEL stage=builder
RUN apk add git
RUN git clone https://github.com/mattermost/mmctl.git
RUN cd mmctl && CGO_ENABLED=0 go build -ldflags '-s -w -extldflags "-static"'

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
# - workshop /scripts utilities
FROM alpine:latest AS workshop
COPY --from=sensu /usr/local/bin/sensuctl /usr/local/bin/
COPY --from=sensu /opt/sensu/bin/sensu-backend /usr/local/bin/
COPY --from=vault /bin/vault /usr/local/bin/vault
COPY --from=mattermost /go/mmctl/mmctl /usr/local/bin/mmctl
ENV PATH=$PATH:/usr/local/bin/scripts
RUN apk add curl jq gettext docker-cli docker-compose

WORKDIR /workshop/
