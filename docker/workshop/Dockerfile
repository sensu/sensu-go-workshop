# Fetch latest Sensu image (for build only)
FROM sensu/sensu:latest AS sensu

# Build configurator image
FROM alpine:latest 
COPY --from=sensu /usr/local/bin/sensuctl /usr/local/bin/
ENV PATH=$PATH:/usr/local/bin/scripts
RUN apk add curl jq gettext docker-cli docker-compose

WORKDIR /var/lib/sensu/workshop/
