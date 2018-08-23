# 2018 Sensu Summit Workshops

Hi! Something something example configuration files for playing with the Sensu
2.0 beta, new [Sensu Assets][], and a [prototype Ruby Runtime asset][sensu-ruby]
(!), something something.

[sensu-assets]: https://docs.sensu.io/sensu-core/2.0/reference/assets/
[sensu-ruby]:   https://github.com/calebhailey/sensu-ruby

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
   - A prototype Ruby Runtime packaged as a Sensu Asset (for running ruby
     plugins!)
   - A `helloworld.rb` Ruby script packaged as a Sensu Asset  
5. Some helper Bash scripts for working with your own assets and the Sensu 2.0
   API

## Prerequisites

You'll need a working Docker environment to run this demo. If you're using a
Mac, head on over to the [Docker CE for Mac][docker-ce-for-mac] page for more
instructions. Linux users can find installation instructions from the
[Docker CE installation guide][docker-ce].

[docker-ce-for-mac]: https://store.docker.com/editions/community/docker-ce-desktop-mac
[docker-ce]: https://docs.docker.com/install/

## Workshop

1. Bootstrap our Sensu 2.0 environment!

   ```
   $ docker-compose up -d
   Creating network "sensu-demo_monitoring" with driver "bridge"
   Creating sensu-demo_sensu-backend_1      ... done
   Creating sensu-demo_grafana_1            ... done
   Creating sensu-demo_sensu-asset-server_1 ... done
   Creating sensu-demo_influxdb_1           ... done
   Creating sensu-demo_sensu-agent_1        ... done
   Creating sensu-demo_influxdb-init_1      ... done
   ```

   _NOTE: you may see some `docker pull` and `docker build` output on your first
   run as Docker pulls down our base images and builds a few custom images._

   Once `docker-compose` is done standing up our systems we should be able to
   login to the Sensu 2.0 dashboard!

   ![Sensu 2.0 dashboard login screen](docs/images/login.png "Sensu 2.0 dashboard login screen")

2. Install and configure a local `sensuctl` (the new Sensu 2.0 CLI)

   Mac users:

   ```
   $ curl -LO https://storage.googleapis.com/sensu-binaries/$(curl -s https://storage.googleapis.com/sensu-binaries/latest.txt)/darwin/amd64/sensu-backend
   $ chmod +x sensu-backend
   $ mv sensu-backend /usr/local/bin/
   ```

   Linux and Windows users can find [`sensuctl` installation instructions here][sensuctl-install]

   Configure your `sensuctl`:

   $ sensuctl configure

   ```
   ? Sensu Backend URL: (http://localhost:8080)
   ? Username: admin
   ? Password: *********
   ? Organization: default
   ? Environment: default
   ? Preferred output format: none
   ```

   [sensuctl-install]: https://docs.sensu.io/sensu-core/2.0/getting-started/configuring-sensuctl/#installation

3. Register some Sensu 2.0 Assets

   ```
   $ sensuctl create -f config/assets/check_http_v0.1.json
   $ sensuctl create -f config/assets/sensu-ruby_v2.4.4.json
   $ sensuctl create -f config/assets/helloworld_v0.1.json
   ```

4. Configure a check

   ```
   $ sensuctl create -f config/checks/check_sensu_io.json
   $ sensuctl create -f config/checks/helloworld.json
   ```
