# Sensu Go Demo

Something something Docker Compose environment for trying Sensu Go something
something.

## Workshop contents

1. A `docker-compose.yaml` for provisioning a simple Sensu Go demo environment,
   including:
   - A Sensu Go backend, API, and dashboard (`sensu-backend`)
   - A Sensu Go agent (`sensu-agent`)
   - An HTTP file server for hosting [Sensu Assets][sensu-assets]
   - InfluxDB
   - Grafana
2. Configuration files for NGINX, InfluxDB, and Grafana
3. Sensu resource configuration templates (e.g. asset and check definitions)

[sensu-assets]: https://docs.sensu.io/sensu-core/2.0/reference/assets/
[sensu-plugins-http]: https://github.com/sensu-plugins/sensu-plugins-http
[sensu-ruby]:   https://github.com/calebhailey/sensu-ruby

## Prerequisites

You'll need a working Docker environment with Docker Compose to run this demo.
If you're using a Mac, head on over to the [Docker CE for
Mac][docker-ce-for-mac] page for more instructions. Linux users can find
installation instructions from the [Docker CE installation guide][docker-ce].

[docker-ce-for-mac]: https://store.docker.com/editions/community/docker-ce-desktop-mac
[docker-ce]: https://docs.docker.com/install/

## Workshop

1. Bootstrap our Sensu Go environment!

   ```
   $ docker-compose up -d
   Creating network "sensu-go-demo_default" with the default driver
   Creating volume "sensu-go-demo_sensu-backend-data" with local driver
   Creating volume "sensu-go-demo_influxdb-data" with local driver
   Creating sensu-go-demo_sensu-backend_1 ... done
   Creating sensu-go-demo_sensu-agent_1        ... done
   Creating sensu-go-demo_sensu-asset-server_1 ... done
   Creating sensu-go-demo_influxdb_1           ... done
   Creating sensu-go-demo_grafana_1            ... done
   ```

   _NOTE: you may see some `docker pull` and `docker build` output on your first
   run as Docker pulls down our base images and builds a few custom images._

   Once `docker-compose` is done standing up our systems we should be able to
   login to the Sensu Go dashboard!

   ![Sensu Go dashboard login screen](docs/images/login.png "Sensu Go dashboard login screen")

   _NOTE: you may login to the dashboard using the default username and password
   for a fresh Sensu Go installation; username: `admin` and password:
   `P@ssw0rd!`._

2. Install and configure a local `sensuctl` (the new Sensu Go CLI)

   Mac users:

   ```
   $ curl -LO https://storage.googleapis.com/sensu-binaries/$(curl -s https://storage.googleapis.com/sensu-binaries/latest.txt)/darwin/amd64/sensuctl
   $ chmod +x sensuctl
   $ mv sensuctl /usr/local/bin/
   ```

   Linux and Windows users can find [`sensuctl` installation instructions
   here][sensuctl-install].

   Configure your `sensuctl`:

   ```
   $ sensuctl configure

   ? Sensu Backend URL: (http://localhost:8080)
   ? Username: admin
   ? Password: *********
   ? Organization: default
   ? Environment: default
   ? Preferred output format: tabular
   ```

   _NOTE: the default username and password for a fresh Sensu Go installation
   are username: `admin` and password: `P@ssw0rd!`._

   [sensuctl-install]: https://docs.sensu.io/sensu-core/2.0/getting-started/configuring-sensuctl/#installation

3. Register some Sensu Go Assets

   ```
   $ sensuctl create -f manifests/assets/sensu-assets-monitoring-plugins.yaml
   $ sensuctl create -f manifests/assets/sensu-influxdb-handler.yaml
   ```

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

### Interact with the Sensu API

The Sensu Go API, like the rest of Sensu Go, provides full support for role
based access controls (RBAC). This also means that authentication is required
to make API calls.

The `GET /auth` endpoint can be used to get an authentication token for the
Sensu Go HTTP API.

```
$ export SENSU_USER=admin
$ export SENSU_PASS=P@ssw0rd!
$ export SENSU_TOKEN=`curl -XGET -u "$SENSU_USER:$SENSU_PASS" -s http://localhost:8080/auth | jq -r ".access_token"`
```

I've also provided a simple bash script that can do this for you (as your token)
will expire from time to time and need to be refreshed. Simply run
`source sensu-backend-token.sh` to set a `$SENSU_TOKEN` environment variable
that can be used make API requests.

```
$ source scripts/sensu-environment.sh
$ curl -XGET -s -H "Content-Type: application/json" -H "Authorization: $SENSU_TOKEN"  http://localhost:8080/api/core/v2/namespaces/default/entities | jq .
```

Example API requests:

- `GET /api/core/v2/namespaces/$SENSU_NAMESPACE/entities`
- `GET /api/core/v2/namespaces/$SENSU_NAMESPACE/assets`
- `GET /api/core/v2/namespaces/$SENSU_NAMESPACE/checks`
- `GET /api/core/v2/namespaces/$SENSU_NAMESPACE/handlers`

Example `POST /entities` for registering proxy entities in Sensu Go:

```
$ curl -XPOST -s -H "Authorization: $SENSU_TOKEN" -H "Content-Type: application/json" -d '{"id": "web-server-01", "class": "proxy", "environment": "default", "organization": "default", "extended_attributes": {"foo": "bar"}, "keepalive_timeout": 30}' http://localhost:8080/entities | jq .
```
