# Use multi-stage Dockerfile to fetch desired sensuctl version
ARG SENSU_CLI_VERSION
FROM sensu/sensu:${SENSU_CLI_VERSION} AS sensu
ARG SENSU_CLI_VERSION
RUN sensuctl version

# Build the workshop workstation image
FROM alpine:latest 
COPY --from=sensu /usr/local/bin/sensuctl /usr/local/bin/
COPY --from=sensu /opt/sensu/bin/sensu-backend /usr/local/bin/
ENV PATH=$PATH:/usr/local/bin/scripts
RUN apk add curl jq gettext docker-cli docker-compose

WORKDIR /var/lib/sensu/workshop/
