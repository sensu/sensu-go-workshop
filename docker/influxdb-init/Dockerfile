FROM alpine:latest
RUN apk add curl
CMD curl -XPOST http://localhost:8086 --data-urlencode "q=CREATE DATABASE sensu"
