FROM centos:7 as builder
WORKDIR /home/
RUN \
  yum install -y curl ca-certificates && \
  curl -LO https://s3-us-west-2.amazonaws.com/sensu.io/sensu-go/5.0.0/sensu-go-5.0.0-linux-amd64.tar.gz && \
  tar -xzf sensu-go-5.0.0-linux-amd64.tar.gz

FROM scratch
COPY --from=builder /home/bin/sensu-agent /usr/bin/sensu-agent
