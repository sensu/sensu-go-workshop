# Sensu Go Workshop

## Overview 

This project is intended to provide a simple template for developing training 
modules for Sensu Go. The workshop outlined below is effectively module #1 – 
it's designed to introduce new Sensu users to the basic concepts of the 
[Observability Pipeline][0] and help them get started with Sensu Go. 

This workshop is also designed to be simple enough for self-guided training, 
while also providing a tool for trainers to host a workshop for multiple 
attendees. See [SETUP.md][1] for more details on getting started. 

## Observability Pipeline 

==COMING SOON==

## Workshop 

1. Configure `sensuctl`:

   ```
   $ sensuctl configure -n --url http://127.0.0.1:8080 \
     --username sensu \
     --password sensu \
     --namespace default
   ```

   Alternatively, you may configure `sensuctl` using the interactive mode:

   ```
   $ sensuctl configure

   ? Sensu Backend URL: (http://localhost:8080)
   ? Username: sensu
   ? Password: *****
   ? Organization: default
   ? Environment: default
   ? Preferred output format: tabular
   ```

   _NOTE: the default username and password for this workshop environment are 
   username: `sensu` and password: `sensu`._

2. Register some Sensu Go Assets from [Bonsai][5] (i.e. the "Docker Hub" for
   Sensu Go plugins):

   ```
   $ sensuctl asset add sensu/monitoring-plugins:2.2.0-2
   $ sensuctl asset add sensu/sensu-influxdb-handler
   ```

   [5]: https://bonsai.sensu.io

4. Configure a handler to process your monitoring data:

   ```
   $ sensuctl create -f manifests/handlers/influxdb.yaml
   ```

5. Configure a check to start collecting data:

   ```
   $ sensuctl create -f manifests/checks/example-http-service-check.yaml
   ```

## Helpful tips

### Local HTTP server for hosting Sensu Assets

This project provides a local HTTP server for hosting Sensu Assets. This will
allow you to test new assets by dropping them into the `./assets` directory. You
can view your assets from your browser by visiting http://localhost:8000/assets.
To view the HTTP server logs, simply use `docker logs` to follow the NGINX
container logs:

```
$ docker logs -f $(docker ps --format "{{.ID}}" --filter "name=sensu-asset-server")

172.28.0.1 - - [23/Aug/2018:22:15:30 +0000] "GET /assets/ HTTP/1.1" 200 955 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.106 Safari/537.36"
```

An example "helloworld-0.1.0.tar.gz" asset has been provided to demonstrate this
workflow. To register this example asset, and configure a check to use the
example asset, run the following commands:

```shell
$ sensuctl create -f manifests/assets/helloworld.yaml
$ sensuctl create -f manifests/checks/helloworld.yaml
```

For reference, this is what an asset definition looks like:

```yaml
---
type: Asset
api_version: core/v2
metadata:
  name: helloworld:0.1.0
spec:
  url: http://sensu-asset-server/assets/helloworld-0.1.0.tar.gz
  sha512: 8d18d3194b94330155b004d516d4164593e40030ac80813eb3e6ba14d5f2570ed59508148890a7b0d6200148c1c0cff7cd161a26ca624aa2c8f7fc31caa3556c
  filters:
  - "entity.system.os == 'linux'"
```

_NOTE: the "sensu-asset-server" host name used here will be automatically
resolved by Docker for communication between containers (specifically from the
sensu-agent container to the NGINX container). This same container is accessible
from your host OS at 127.0.0.1:8080, as Docker is "publishing" port 8080 of your
local workstation to the NGINX container port 80. See Docker's ["Container
Networking"][6] documentation for more information._

[6]: https://docs.docker.com/config/containers/container-networking/

### Interact with the Sensu API

The [Sensu Go API][api], like the rest of Sensu Go, provides full support for
role-based access controls (RBAC). This also means that an authentication token
is required to make API calls. As of version 5.13.0, the Sensu CLI provides a
helpful [`sensuctl env` command][7] for setting local environment variables,
including a `SENSU_ACCESS_TOKEN` which can be used to make API calls.

```
$ eval $(sensuctl env)
```

Example API requests:

- `GET /api/core/v2/namespaces/$SENSU_NAMESPACE/entities`
- `GET /api/core/v2/namespaces/$SENSU_NAMESPACE/assets`
- `GET /api/core/v2/namespaces/$SENSU_NAMESPACE/checks`
- `GET /api/core/v2/namespaces/$SENSU_NAMESPACE/handlers`

Example `POST /entities` for registering proxy entities in Sensu Go:

```
$ curl -XPOST -s -H "Authorization: $SENSU_ACCESS_TOKEN" -H "Content-Type: application/json" -d '{"id": "web-server-01", "class": "proxy", "environment": "default", "organization": "default", "extended_attributes": {"foo": "bar"}, "keepalive_timeout": 30}' http://localhost:8080/entities
```

[7]: https://docs.sensu.io/sensu-go/latest/sensuctl/reference/#environment-variables


[0]: #observability-pipeline 
[1]: /docs/SETUP.md