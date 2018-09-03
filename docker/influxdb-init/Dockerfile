FROM alpine:latest
RUN apk add -U --no-cache curl
CMD curl -XPOST http://localhost:8086 --data-urlencode "q=CREATE DATABASE sensu"
