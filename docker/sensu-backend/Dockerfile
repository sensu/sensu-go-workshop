FROM debian:stretch
ADD sensu-influxdb-handler /usr/bin/sensu-influxdb-handler
RUN apt-get update && apt-get install -y curl && \
  curl -s https://packagecloud.io/install/repositories/sensu/beta/script.deb.sh | bash - && \
  apt-get update && apt-get install -y sensu-backend && \
  apt-get autoremove -y curl && apt-get clean && \
  chmod +x /usr/bin/sensu-influxdb-handler
