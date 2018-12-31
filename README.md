# Sensu Go Demo

Something something Docker Compose environment for trying Sensu Go something
something.

## Workshop contents

1. A `docker-compose.yaml` for provisioning a copmlete Sensu 2.0 test
   environment, including:
   - A Sensu 2.0 backend, API, and dashboard (`sensu-backend`)
   - A Sensu 2.0 agent (`sensu-agent`)
   - An HTTP file server for hosting [Sensu Assets][sensu-assets]
   - InfluxDB
   - Grafana
2. Configuration files for NGINX, InfluxDB, and Grafana
3. Sensu resource configuration templates (e.g. asset and check definitions)
4. Example Sensu Assets
   - The Nagios `check_http` C Plugin packaged as a Sensu Asset
   - A prototype [Ruby Runtime][sensu-ruby] packaged as a Sensu Asset (for
     running ruby plugins!)
   - The [sensu-plugins-http][sensu-plugins-http] plugin gem packaged as a Sensu
     Asset.
5. Some helper Bash scripts for working with your own assets and the Sensu 2.0
   API

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

1. Bootstrap our Sensu 2.0 environment!

   ```
   $ docker-compose up -d
   Creating network "sensu-demo_monitoring" with driver "bridge"
   Creating sensu-demo_sensu-asset-server_1_ea8078731137 ... done
   Creating sensu-demo_influxdb_1_e355beba89f5           ... done
   Creating sensu-demo_sensu-backend_1_47d6bfc38825      ... done
   Creating sensu-demo_grafana_1_a17197fa7683            ... done
   Creating sensu-demo_influxdb-init_1_d341615a9ea4      ... done
   Creating sensu-demo_sensu-agent_1_b42bbbf94935        ... done
   ```

   _NOTE: you may see some `docker pull` and `docker build` output on your first
   run as Docker pulls down our base images and builds a few custom images._

   Once `docker-compose` is done standing up our systems we should be able to
   login to the Sensu 2.0 dashboard!

   ![Sensu 2.0 dashboard login screen](docs/images/login.png "Sensu 2.0 dashboard login screen")

   _NOTE: you may login to the dashboard using the default username and password
   for a fresh Sensu 2.0 installation; username: `admin` and password:
   `P@ssw0rd!`._

2. Install and configure a local `sensuctl` (the new Sensu 2.0 CLI)

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
   ? Preferred output format: none
   ```

   _NOTE: the default username and password for a fresh Sensu 2.0 installation
   are username: `admin` and password: `P@ssw0rd!`._

   [sensuctl-install]: https://docs.sensu.io/sensu-core/2.0/getting-started/configuring-sensuctl/#installation

3. Register some Sensu 2.0 Assets

   ```
   $ sensuctl create -f manifests/assets/check_http_v0.1.json
   $ sensuctl create -f manifests/assets/sensu-ruby_v2.4.4.json
   $ sensuctl create -f manifests/assets/helloworld_v0.1.json
   ```

4. Configure a check

   ```
   $ sensuctl create -f manifests/checks/check_sensu_io.json
   $ sensuctl create -f manifests/checks/helloworld.json
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

The Sensu 2.0 API, like the rest of Sensu 2.0, provides full support for role
based access controls (RBAC). This also means that authentication is required
to make API calls.

The `GET /auth` endpoint can be used to get an authentication token for the
Sensu 2.0 HTTP API.

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

Example `POST /entities` for registering proxy entities in Sensu 2.0:

```
$ curl -XPOST -s -H "Authorization: $SENSU_TOKEN" -H "Content-Type: application/json" -d '{"id": "web-server-01", "class": "proxy", "environment": "default", "organization": "default", "extended_attributes": {"foo": "bar"}, "keepalive_timeout": 30}' http://localhost:8080/entities | jq .
```
