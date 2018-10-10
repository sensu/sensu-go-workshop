FROM alpine:latest
RUN apk add -U --no-cache curl
CMD curl -i -XPOST http://influxdb:8086/query --data-urlencode "q=CREATE DATABASE sensu"
