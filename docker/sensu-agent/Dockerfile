FROM debian:stretch
ADD sensu-agent /usr/bin/sensu-agent
RUN \
  chmod +x /usr/bin/sensu-agent && \
  apt-get update && apt-get install -y ca-certificates
