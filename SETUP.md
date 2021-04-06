# Sensu Go Workshop

- [Setup](#setup)
  - [Self-guided workshop setup](#self-guided-workshop-setup)
  - [Instructor-led workshop setup (for trainees)](#instructor-led-workshop-setup-for-trainees)
  - [Instructor-led workshop setup (for instructors)](#instructor-led-workshop-setup-for-instructors)
- [References](#references)
  - [Workshop contents](#workshop-contents)
  - [Prerequisites](#prerequisites)
  - [Customization](#customization)
  - [Maintenance & Troubleshooting](#maintenance-troubleshooting)

## Setup

### Self-guided workshop setup

1. **Clone this repository.**

   ```shell
   git clone https://github.com/sensu/sensu-go-workshop.git
   cd sensu-go-workshop/
   ```

   _NOTE: if you are following instructions in a non-default branch of the workshop you may also need to change branches using a command like `git checkout <branch-name>`._

2. **Docker Compose initialization.**

   Deploy the workshop environment with the `docker-compose up` command!

   ```
   sudo docker-compose up -d
   ```

   The output should look like this:

   ```shell
   Creating network "workshop_default" with the default driver
   Creating volume "workshop_sensuctl_data" with local driver
   Creating volume "workshop_sensu_data" with local driver
   Creating volume "workshop_timescaledb_data" with local driver
   Creating volume "workshop_grafana_data" with local driver
   Creating volume "workshop_artifactory_data" with local driver
   Creating workshop_vault_1         ... done
   Creating workshop_grafana_1       ... done
   Creating workshop_sensuctl_1      ... done
   Creating workshop_sensu-backend_1 ... done
   Creating workshop_artifactory_1   ... done
   Creating workshop_timescaledb_1   ... done
   Creating workshop_sensu-agent_1   ... done
   Creating workshop_configurator_1  ... done
   ```

   > **PROTIP:** To prefetch and/or prebuild the workshop container images (e.g. for offline use), please run the following commands:
   >
   > ```shell
   > sudo docker-compose pull && sudo docker-compose build
   > ```

   > _NOTE: the first time you run the `docker-compose up` command you will likely see output related to the pulling and building of the workshop container images, this process shouldn't take more than 2-3 minutes, depending on your system._

3. **Verify your workshop installation.**

   ```shell
   sudo docker-compose ps
   ```

   The output should indicate that all of the services are `Up (healthy)` or "completed" (`Exit 0`).

   ```shell
   Creating network "workshop_default" with the default driver
   Creating volume "workshop_sensuctl_data" with local driver
   Creating volume "workshop_sensu_data" with local driver
   Creating volume "workshop_timescaledb_data" with local driver
   Creating volume "workshop_grafana_data" with local driver
   Creating volume "workshop_artifactory_data" with local driver
   Creating workshop_vault_1         ... done
   Creating workshop_grafana_1       ... done
   Creating workshop_sensuctl_1      ... done
   Creating workshop_sensu-backend_1 ... done
   Creating workshop_artifactory_1   ... done
   Creating workshop_timescaledb_1   ... done
   Creating workshop_sensu-agent_1   ... done
   Creating workshop_configurator_1  ... done
   ```

   > _NOTE: every container should show a status of `Up (healthy)` or `Exit 0`; if any containers have the status `Up` or `Up (health: starting)`, please wait a few seconds and retry the `sudo docker-compose ps` command.
   > If any containers have completed with the `Exit 1` or `Exit 2` state, it's possible that these were the result of an intermittent failure (e.g. if the sensu-backend container was slow to start) and re-running the `sudo docker-compose up -d` command will resolve the issue._

**NEXT:** if all of the containers show a `Up (healthy)` or `Exit 0` state, then you're ready to start the workshop!

### Instructor-led workshop setup (for trainees)

1. **Clone the `sensu/sensu-go-workshop` GitHub repository.**

   ```shell
   git clone https://github.com/sensu/sensu-go-workshop.git
   cd sensu-go-workshop/
   ```

   _NOTE: if you are following instructions in a non-default branch of the workshop you may also need to change branches using a command like `git checkout <branch-name>`._

1. **Modify the contents of the `.envrc` or `.envrc.ps1` file.**

   Modify the contents of `.envrc` using the details provided by your instructor.
   At minimum you will need to edit the `SENSU_BACKEND_HOST`, `SENSU_NAMESPACE`, `SENSU_USER`, and `SENSU_PASSWORD` property.
   Unless otherwise instructed, your `SENSU_NAMESPACE` should be the same as the workshop username provded by your instructor.

   **Mac and Linux users (`.envrc`):**

   ```shell
   export SENSU_VERSION=6.2.7
   export SENSU_BUILD=4449
   export SENSU_PLATFORM=linux
   export SENSU_ARCH=amd64
   export SENSU_BACKEND_HOST=127.0.0.1
   export SENSU_NAMESPACE=default
   export SENSU_USER=sensu
   export SENSU_PASSWORD=sensu
   export SENSU_BACKEND_URL=ws://${SENSU_BACKEND_HOST}:8081
   export SENSU_API_URL=http://${SENSU_BACKEND_HOST}:8080
   # export SENSU_API_KEY=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
   ```

   **Windows users (`.envrc.ps1`):**

   ```powershell
   ${Env:SENSU_VERSION}="6.2.7"
   ${Env:SENSU_BUILD}="4449"
   ${Env:SENSU_PLATFORM}="linux"
   ${Env:SENSU_ARCH}="amd64"
   ${Env:SENSU_BACKEND_HOST}="127.0.0.1"
   ${Env:SENSU_NAMESPACE}="default"
   ${Env:SENSU_USER}="sensu"
   ${Env:SENSU_PASSWORD}="sensu"
   ${Env:SENSU_BACKEND_URL}="ws://${Env:SENSU_BACKEND_HOST}:8081"
   ${Env:SENSU_API_URL}="http://${Env:SENSU_BACKEND_HOST}:8080"
   # ${Env:SENSU_API_KEY}="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
   ```

   _NOTE: don't worry about setting `SENSU_API_KEY` for now - we'll cover that in [Lesson 3](/lessons/operator/03/README.md#readme)._

1. **Configure environment variables.**

   **Mac and Linux users:**

   ```shell
   source .envrc
   env | grep SENSU
   ```

   **Windows users (Powershell):**

   ```powershell
   . .\.envrc.ps1
   Get-ChildItem env: | Out-String -Stream | Select-String -Pattern SENSU
   ```

   > _NOTE: self-guided users should see the username `sensu`.
   > Instructor-led workshop users should see the username assigned to them by the instructor.
   > If you don't see a username printed out after the `echo $SENSU_WORKSHOP_USERNAME` command, please check with your instructor._

**NEXT:** if you see the expected values output after you run the `env | grep SENSU` command, you're ready for your workshop!

### Instructor-led workshop setup (for instructors)

1. **Clone the `sensu/sensu-go-workshop` GitHub repository.**

   ```shell
   git clone https://github.com/sensu/sensu-go-workshop.git
   cd sensu-go-workshop/
   ```

   _NOTE: if you are following instructions in a non-default branch of the workshop you may also need to change branches using a command like `git checkout <branch-name>`._

1. **Customize the Docker Compose environment file (`.env`), as needed.**

   All of the workshop configuration variables have been consolidated into a single configuration file for your convenience.
   These configuration variables make it easy to use a specific version of Sensu Go (see: `SENSU_BACKEND_VERSION`, `SENSU_AGENT_VERSION`, and `SENSU_CLI_VERSION`), or change default passwords, and more.

   Please review [Customization](#customization) for more information.

   > **PROTIP:** if you are preparing a workshop environment for an instructor-led workshop, we recommend changing the Sensu admin username (`SENSU_CLUSTER_ADMIN_USERNAME`) and admin password (`SENSU_CLUSTER_ADMIN_PASSWORD`), as this will help workshop trainees avoid inadvertently accessing the admin account.

   > _NOTE: complete this step **BEFORE** you run any `docker-compose` commands._

1. **Configure workshop user accounts.**

   This workshop contains various templates and scripts for configuring workshop trainee user accounts (dedicated namespaces and RBAC profiles for each trainee).
   To automatically generate these profiles, edit the `users/users.json` file **BEFORE** you run any `docker-compose` commands.
   Two example users are pre-configured, as follows:

   ```json
   [
     {"username": "user@company.com","password": "workshop"},
     {"username": "trainee","password": "workshop"}
   ]
   ```

   Modify this file so that there is one row per user. The `users.json` file supports defining `username` and `password` values (in plain text), or a `password_hash` (bcrypt-encrypted password hashes).
   If a `password_hash` _and_ `password` value are provided for the same user, the `password` will be ignored.
   The Sensu CLI provides a built-in utility for generating valid `password_hash` values, via [the `sensuctl user password-hash` command][9].

1. **Docker Compose initialization.**

   ```shell
   sudo docker-compose up -d
   ```

   The output should look like this:

   ```shell
   Creating network "workshop_default" with the default driver
   Creating volume "workshop_sensuctl_data" with local driver
   Creating volume "workshop_sensu_data" with local driver
   Creating volume "workshop_timescaledb_data" with local driver
   Creating volume "workshop_grafana_data" with local driver
   Creating volume "workshop_artifactory_data" with local driver
   Creating workshop_vault_1         ... done
   Creating workshop_grafana_1       ... done
   Creating workshop_sensuctl_1      ... done
   Creating workshop_sensu-backend_1 ... done
   Creating workshop_artifactory_1   ... done
   Creating workshop_timescaledb_1   ... done
   Creating workshop_sensu-agent_1   ... done
   Creating workshop_configurator_1  ... done
   ```

   > **PROTIP:** To prefetch and/or prebuild the workshop container images (e.g. for offline use), please run the following commands:
   >
   > ```shell
   > sudo docker-compose pull && sudo docker-compose build
   > ```

   > _NOTE: the first time you run the `docker-compose up` command you will likely see output related to the pulling and building of the workshop container images, this process shouldn't take more than 2-3 minutes, depending on your system._

1. **Verify your workshop installation.**

   ```shell
   sudo docker-compose ps
   ```

   The output should look like this:

   ```shell
             Name                        Command                  State                             Ports
   -----------------------------------------------------------------------------------------------------------------------------
   workshop_configurator_1    generate_user_rbac               Exit 0
   workshop_grafana_1         /run.sh                          Up (healthy)   0.0.0.0:3001->3000/tcp
   workshop_sensu-agent_1     sensu-agent start --log-le ...   Up (healthy)   0.0.0.0:32830->3031/tcp, 0.0.0.0:32821->8125/udp
   workshop_sensu-backend_1   sensu-backend start --log- ...   Up (healthy)   0.0.0.0:3000->3000/tcp, 0.0.0.0:8080->8080/tcp
   workshop_sensuctl_1        wait-for-sensu-backend sen ...   Exit 0
   workshop_timescaledb_1     docker-entrypoint.sh postgres    Up (healthy)   0.0.0.0:5432->5432/tcp
   ```

   > _NOTE: every container should show a status of `Up (healthy)` or `Exit 0`; if any containers have the status `Up` or `Up (health: starting)`, please wait a few seconds and re-run the `sudo docker-compose ps` command.
   > Otherwise, if any containers have reached the `Exit 1` or `Exit 2` state, it's possible that these were the result of an intermittent failure (e.g. if the sensu-backend container was slow to start) and re-running the `sudo docker-compose up -d` command will resolve the issue._

1. **Create workshop trainee user accounts.**

   Use the workshop configurator Docker container to execute the user account creation script, as follows:

   ```shell
   sudo docker-compose run --rm configurator create_user_accounts
   ```

   The script should output a message like:

   ```shell
   Successfully created the following workshop user accounts:

      Name
    ─────────
     default
     example
     lizy
   ```

   > _NOTE: if you add additional users to `users/users.json` after you execute this script you'll need to repeat this step._

1. **Configure secrets.**

   This workshop environment includes a Hashicorp Vault server running in ["dev server mode"](https://www.vaultproject.io/docs/concepts/dev-server).
   To configure Vault secrets that trainees will need access to during the workshop (e.g. Pagerduty API Token and Slack Webhook URL), please modify the files in `/config/vault/secrets`.
   Additional secrets may be added to Vault by adding JSON files in `/config/vault/secrets`, but corresponding Sensu Secrets will need to be configured in order to make these secrets available in Sensu.
   Additional/custom Sensu Secret resources may be added in the following step.

1. **Seed workshop trainee namespaces with some example resources.**

   Use the workshop configurator Docker container to execute the user namespace seeding script, as follows:

   ```shell
   sudo docker-compose run --rm configurator seed_workshop_resources
   ```

   > **PROTIP:** to customize the workshop, add valid sensu resource definitions to `/config/sensu/seeds` and re-run the `seed_workshop_resources` command.

   The script will ouput several messages

**NEXT:** if you're seeing seeded resources in your trainee namespaces, you're ready to start the workshop!

## References

### Workshop contents

1. A Docker Compose environment file (`.env`) for customizing the workshop environment

2. A `docker-compose.yaml` for provisioning a simple Sensu Go workshop environment, including:

   - A Sensu Go backend, API, and dashboard (`sensu-backend`)
   - A Sensu Go agent (`sensu-agent`)
   - A telemetry stack, including:
     - TimescaleDB for storage
     - Grafana for visualization
   - A Vault server, for secrets management

   Coming soon:

   - Deployment templates for [AWS Fargate][fargate]
   - Deployment templates for [Heroku][heroku]
   - Alternate reference architectures (e.g. Elasticsearch or Splunk for metric storage instead of Timescale)

3. Configuration files for TimescaleDB and Grafana

4. Dockerfiles templates for building custom Sensu Docker images

5. Sensu resource templates for configuring an example pipeline

### Prerequisites

1. **Docker + Docker Compose**

   You'll need a working Docker environment with Docker Compose to run this workshop.
   MacOS users will need [Docker CE Desktop for Mac][1], Windows users will need [Docker CE Desktop for Windows][2].
   Linux users can find installation instructions from the [Docker CE installation guide][3].

   _NOTE: in a workshop hosted by an instructor with a shared Sensu deployment, only the instructor needs a Docker host.
   Self-guided trainees can deploy the workshop environment on their workstations, though they may find it advantageous to deploy._

### Customization

Please note the following configuration parameters:

- `WORKSHOP_VERSION=0.2.0`

  Informational use only (not used in the workshop).

- `COMPOSE_PROJECT_NAME`

  The Docker resource prefix for all resources managed by Docker Compose.

- `COMPOSE_FILE`

  The Docker Compose template to use; defaults to `docker-compose-default.yaml`.
  Change this value to deploy an alternate workshop environment (e.g. using a different reference architecture).

- `SENSU_BACKEND_VERSION`

  The Sensu backend version to use.
  This should be kept in sync with `SENSU_AGENT_VERSION` and `SENSU_CLI_VERSION`.

- `SENSU_BACKEND_CLUSTER_ADMIN_USERNAME`

  The Sensu Go cluster admin username.
  _NOTE: if you're a long-time Sensu Go user you may recall that the default cluster admin username was `admin`; since version 5.16.0 the default cluster admin user has been removed and must now be provided via a new [`sensu-backend init` command][4]._

- `SENSU_BACKEND_CLUSTER_ADMIN_PASSWORD`

  The Sensu Go cluster admin password.
  _NOTE: if you're a long-time Sensu Go user you may recall that the default cluster admin password was `P@ssw0rd!`; since version 5.16.0 the default cluster admin password has been removed and must now be provided via the [`sensu-backend init` command][4]._

- `SENSU_INTERNAL_ENVIRONMENT`

  Used to tag Sensu usage metrics as belonging to a workshop environment.
  Leaving this set to `SENSU_INTERNAL_ENVIRONMENT=workshop` helps us (Team Sensu) improve the product and workshop/training materials by letting us evaluate workshop usage metrics separate from the otherwise anonymous usage metrics collected by Tessen.
  Please see the [Tessen reference documentation](https://docs.sensu.io/sensu-go/latest/operations/monitor-sensu/tessen/) for more information.

- `SENSU_WORKSHOP_ENV_SECRET` (secret)

  An example environment variable.
  Used for a workshop lesson on secrets management, especially useful in intructor-led workshops.
  Trainees will be encouraged to discover the value of this secret by completing an exercise (i.e. a "treasure hunt" style exercise).

- `SENSU_TIMESCALEDB_DSN` (secret)

  The TimescaleDB Postgres database Data Source Name (DSN).
  This variable is used for configuring a Sensu Secret with the `env` provider.
  Modifying this value may break certain exercises, so proceed with caution when making changes.

- `SENSU_INFLUXDB_ADDR` (secret)

  The Docker internal DNS for the InfluxDB server (only used when `COMPOSE_FILE=docker-compose-influxdb.yaml`).
  This variable is used for configuring a Sensu Secret with the `env` provider.
  Modifying this value may break certain exercises, so proceed with caution when making changes.

- `SENSU_INFLUXDB_DB` (secret)

  The InfluxDB database name (only used when `COMPOSE_FILE=docker-compose-influxdb.yaml`).
  This variable is used for configuring a Sensu Secret with the `env` provider.
  Modifying this value may break certain exercises, so proceed with caution when making changes.

- `SENSU_INFLUXDB_USER` (secret)

  The InfluxDB admin username (only used when `COMPOSE_FILE=docker-compose-influxdb.yaml`).
  This variable is used for configuring a Sensu Secret with the `env` provider.
  Modifying this value may break certain exercises, so proceed with caution when making changes.

- `SENSU_INFLUXDB_PASSWORD` (secret)

  The InfluxDB admin password (only used when `COMPOSE_FILE=docker-compose-influxdb.yaml`).
  This variable is used for configuring a Sensu Secret with the `env` provider.
  Modifying this value may break certain exercises, so proceed with caution when making changes.

- `SENSU_AGENT_VERSION`

  The Sensu Agent (`sensu-agent`) version to use.
  This should be kept in sync with `SENSU_BACKEND_VERSION`.

- `SENSU_BACKEND_URL`

  The Docker internal DNS for the Sensu Backend websocket API (default: `ws://sensu-backend:8081`).
  This variable is used for configuring Sensu Agents in the workshop environment.
  Modifying this value may break certain exercises, so proceed with caution when making changes.

- `SENSU_SUBSCRIPTIONS`

  The default subscriptions used by Sensu Agents running in the Docker Compose environment (default: `linux,workshop,devel`).
  This variable is used for configuring Sensu Agents in the workshop environment.
  Modifying this value may break certain exercises, so proceed with caution when making changes.

- `SENSU_NAMESPACE`

  The Sensu namespace used by Sensu Agents running in the Docker Compose environment (default: `default`).
  This variable is used for configuring Sensu Agents in the workshop environment.
  Modifying this value may break certain exercises, so proceed with caution when making changes.

  This variable can be overriden when spawning additional agents; e.g.:

  ```
  sudo docker-compose run --rm -e "SENSU_NAMESPACE=us-west-1" sensu-agent
  ```

- `SENSU_API_HOST`

  The default Sensu Agent API hostname.
  This variable is used for configuring Sensu Agents in the workshop environment.
  Modifying this value may break certain exercises, so proceed with caution when making changes.

- `SENSU_API_PORT`

  The default Sensu Agent API port.
  This variable is used for configuring Sensu Agents in the workshop environment.
  Modifying this value may break certain exercises, so proceed with caution when making changes.

- `SENSU_STATSD_METRICS_HOST`

  The default Sensu Agent StatsD API hostname.
  This variable is used for configuring Sensu Agents in the workshop environment.
  Modifying this value may break certain exercises, so proceed with caution when making changes.

- `SENSU_STATSD_METRICS_PORT`

  The default Sensu Agent StatsD API port.
  This variable is used for configuring Sensu Agents in the workshop environment.
  Modifying this value may break certain exercises, so proceed with caution when making changes.

- `SENSU_CLI_VERSION`

  The Sensu CLI (`sensuctl`) version to use.
  This should be kept in sync with `SENSU_BACKEND_VERSION`.

- `SENSU_BACKEND_URL`

  The Docker internal DNS for the Sensu Backend HTTP API.
  This variable is used for configuring `sensuctl` in the workshop environment, and for automating some of the workshop provisioning.
  Modifying this value may break workshop setup and certain exercises, so proceed with caution when making changes.

- `SENSU_USERNAME`

  The Sensu cluster admin username.
  The value should usually match `SENSU_CLUSTER_ADMIN_USERNAME`.
  This variable is used for configuring `sensuctl` in the workshop environment, and for automating some of the workshop provisioning.
  Modifying this value may break workshop setup and certain exercises, so proceed with caution when making changes.

- `SENSU_PASSWORD`

  The Sensu cluster admin password.
  The value should usually match `SENSU_CLUSTER_ADMIN_PASSWORD`.
  This variable is used for configuring `sensuctl` in the workshop environment, and for automating some of the workshop provisioning.
  Modifying this value may break workshop setup and certain exercises, so proceed with caution when making changes.

- `SENSU_CONFIG_DIR`

  The `sensuctl` configuration directory to use.
  This environment variable is not yet supported by `sensuctl`, but may be in a future release.
  In the interim, setting this variable is useful in the context of custom `sensuctl` wrapper scripts (see `/scripts/sensuctl`) or for passing on the command line (e.g. `sensuctl --config-dir $SENSU_CONFIG_DIR`).

- `GRAFANA_VERSION`

  The Grafana Docker image version to use in the workshop (default: `7.0.0`).

- `GF_AUTH_BASIC_ENABLED`

  Enables Grafana basic auth.
  See the [Grafana User Authentication documentation](https://grafana.com/docs/grafana/latest/auth/overview/#basic-authentication) for more information.

- `GF_SECURITY_ADMIN_USER`

  The default admin username.
  See the [Grafana Configuration documentation](https://grafana.com/docs/grafana/latest/administration/configuration/) for more information.

- `GF_SECURITY_ADMIN_PASSWORD`

  The default admin password.
  See the [Grafana Configuration documentation](https://grafana.com/docs/grafana/latest/administration/configuration/) for more information.

- `PROM_PROMETHEUS_VERSION`

  The Prometheus Docker image version to use in the workshop environment (default: `v2.20.0`).
  Only used when `COMPOSE_FILE=docker-compose-prometheus.yaml`.

- `PROM_PUSHGATEWAY_VERSION`

  The Prometheus Pushgateway Docker image version to use in the workshop environment (default: `v1.2.0`).
  Only used when `COMPOSE_FILE=docker-compose-prometheus.yaml`.

- `TIMESCALEDB_VERSION`

  The TimescaleDB Docker image version to use in the workshop environment (default: `1.7.2-pg12`).

- `POSTGRES_PASSWORD`

  The TimescaleDB Postgres database password (for the default `postgres` user).

- `POSTGRES_DB`

  The TimescaleDB Postgres database to connect to.
  If omitted, the default database will be `postgres`.
  If a database name is provided for a database that does not exist, it will be created.

- `INFLUXDB_VERSION`

  ==TODO==

- `INFLUXDB_VERSION`

  ==TODO==

- `INFLUXDB_DB`

  ==TODO==

- `INFLUXDB_ADMIN_USER`

  ==TODO==

- `INFLUXDB_ADMIN_PASSWORD`

  ==TODO==

- `VAULT_VERSION`

  ==TODO==

- `VAULT_DEV_ROOT_TOKEN_ID`

  ==TODO==

- `VAULT_TOKEN`

  ==TODO==

- `VAULT_DEV_LISTEN_ADDRESS`

  ==TODO==

- `VAULT_ADDR`

  ==TODO==

- `VAULT_SECRET_PATH_PREFIX`

  ==TODO==

- `ARTIFACTORY_VERSION`

  ==TODO==

- `JFROG_HOME`

  ==TODO==

- `ETCD_VERSION`

  ==TODO==

- `ETCD_HOST`

  ==TODO==

- `SENSU_ETCD_CLIENT_URLS`

  ==TODO==

- `POSTGRES_VERSION`

  ==TODO==

- `NGINX_VERSION`

  ==TODO==

## Maintenance & Troubleshooting

### Adding Sensu RBAC resources

This workshop includes some example Role Based Access Control (RBAC) resources that may be useful for instructors who wish to prepare a shared (multi-tenant) workshop environment for multiple trainees.
These resources include namespaces, roles & cluster roles, role-bindings & cluster-role-bindings, and "basic auth" user accounts.
To learn more about RBAC in Sensu Go, please visit the [RBAC reference documentation][7].

In organizations where an SSO provider is available, we recommend configuring Sensu for single sign-on (supports LDAP, Active Directory, OAuth, and OIDC).
To learn more about SSO for Sensu Go, please visit the [authentication provider documentation][8].

### Scale one of the workshop services

1. **Add more Sensu Agent containers.**

   ```shell
   sudo docker-compose up -d --scale sensu-agent=3
   ```

   The output should look like this:

   ```shell
   workshop_sensu-backend_1 is up-to-date
   workshop_vault_1 is up-to-date
   Starting workshop_sensuctl_1 ...
   workshop_timescaledb_1 is up-to-date
   workshop_grafana_1 is up-to-date
   Starting workshop_sensuctl_1     ... done
   Starting workshop_sensu-agent_1  ... done
   Starting workshop_configurator_1 ... done
   Creating workshop_sensu-agent_2  ... done
   Creating workshop_sensu-agent_3  ... done
   ```

### Reset the workshop environment

1. **Stop all containers, remove all networks and volumes.**

   ```shell
   sudo docker-compose down -v
   ```

   The output should look like this:

   ```shell
   Stopping workshop_sensu-agent_1   ... done
   Stopping workshop_sensu-backend_1 ... done
   Stopping workshop_timescaledb_1   ... done
   Stopping workshop_artifactory_1   ... done
   Stopping workshop_grafana_1       ... done
   Stopping workshop_vault_1         ... done
   Removing workshop_configurator_1  ... done
   Removing workshop_sensu-agent_1   ... done
   Removing workshop_sensu-backend_1 ... done
   Removing workshop_timescaledb_1   ... done
   Removing workshop_artifactory_1   ... done
   Removing workshop_grafana_1       ... done
   Removing workshop_vault_1         ... done
   Removing workshop_sensuctl_1      ... done
   Removing network workshop_default
   Removing volume workshop_sensuctl_data
   Removing volume workshop_sensu_data
   Removing volume workshop_timescaledb_data
   Removing volume workshop_grafana_data
   Removing volume workshop_artifactory_data
   ```

### Inspect the contents of a Docker Volume

1. **Inspect the Docker `volume` resource.**

   ```shell
   sudo docker volume inspect workshop_timescaledb_data
   ```

   The output should look like this:

   ```json
   [
     {
       "CreatedAt": "2020-07-22T10:24:59-07:00",
       "Driver": "local",
       "Labels": {
         "com.docker.compose.project": "workshop",
         "com.docker.compose.version": "1.25.5",
         "com.docker.compose.volume": "timescaledb_data"
       },
       "Mountpoint": "/var/lib/docker/volumes/workshop_timescaledb_data/_data",
       "Name": "workshop_timescaledb_data",
       "Options": null,
       "Scope": "local"
     }
   ]
   ```

   The "Mountpoint" field indicates the subdirectory where you can find the contents of the volume.

   If you have `jq` installed, the following commands may be useful:

   ```shell
   sudo docker volume inspect workshop_timescaledb_data | jq -r .[].Mountpoint
   "/var/lib/docker/volumes/workshop_timescaledb_data/_data"
   ```

   For example, to list the contents of a volume:

   ```shell
   sudo ls $(sudo docker volume inspect workshop_timescaledb_data | jq -r .[].Mountpoint)
   ```


[1]: https://hub.docker.com/editions/community/docker-ce-desktop-mac
[2]: https://hub.docker.com/editions/community/docker-ce-desktop-windows
[3]: https://docs.docker.com/install/
[4]: https://docs.sensu.io/sensu-go/latest/reference/backend/#initialization
[5]: https://docs.sensu.io/sensu-go/latest/installation/install-sensu/#install-sensuctl
[6]: https://docs.sensu.io/sensu-go/latest/
[7]: https://docs.sensu.io/sensu-go/latest/reference/rbac/
[8]: https://docs.sensu.io/sensu-go/latest/operations/control-access/auth/
[9]: https://docs.sensu.io/sensu-go/latest/sensuctl/#generate-a-password-hash

[fargate]: https://www.docker.com/blog/from-docker-straight-to-aws/
[heroku]: https://devcenter.heroku.com/categories/deploying-with-docker
