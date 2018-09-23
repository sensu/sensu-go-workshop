FROM debian:stretch
RUN apt-get update && apt-get install -y curl && \
  curl -s https://packagecloud.io/install/repositories/sensu/beta/script.deb.sh | bash - && \
  apt-get update && apt-get install -y sensu-agent && \
  apt-get autoremove -y curl && apt-get clean
