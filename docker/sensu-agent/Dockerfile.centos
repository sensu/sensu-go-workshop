FROM centos:7 as builder
WORKDIR /home/
RUN \
  yum install -y curl ca-certificates && \
  curl -LO https://s3-us-west-2.amazonaws.com/sensu.io/sensu-go/5.0.0/sensu-go-5.0.0-linux-amd64.tar.gz && \
  tar -xzf sensu-go-5.0.0-linux-amd64.tar.gz && \
  mkdir -p /tmp/sensu/sensu-asset/

FROM scratch
COPY --from=builder /etc/pki/ca-trust/ /etc/pki/ca-trust/
COPY --from=builder /etc/pki/java/cacerts /etc/pki/java/cacerts
COPY --from=builder /etc/pki/tls/ /etc/pki/tls/
COPY --from=builder /etc/ssl/certs /etc/ssl/certs
COPY --from=builder /usr/bin/ca-legacy /usr/bin/ca-legacy
COPY --from=builder /usr/bin/update-ca-trust /usr/bin/update-ca-trust
COPY --from=builder /usr/share/pki/ /usr/share/pki/
COPY --from=builder /home/bin/sensu-agent /usr/bin/sensu-agent
COPY --from=builder /tmp/sensu/sensu-asset/ /tmp/sensu/sensu-asset/
