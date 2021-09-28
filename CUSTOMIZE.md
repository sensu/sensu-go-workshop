# Customizing the Workshop

- [Workshop Settings](#workshop-settings)
- [Sensu Backend Settings](#sensu-backend-settings)
- [Sensu Agent Settings](#sensu-agent-settings)
- [Sensu CLI Settings](#sensu-cli-settings)
- [Vault Settings](#vault-settings)
- [Etcd Settings](#etcd-settings)
- [Postgres Settings](#postgres-settings)
- [Nginx Settings](#nginx-settings)
- [Grafana Settings](#grafana-settings)
- [InfluxDB Settings](#influxdb-settings)
- [TimescaleDB Settings](#timescaledb-settings)
- [Prometheus Settings](#prometheus-settings)

## Workshop Settings

Please note the following `.env` file configuration parameters for the Workshop:

- `WORKSHOP_SENSU_VERSION`

  The Sensu version used in the workshop.

- `WORKSHOP_SENSU_BUILD`

  The Sensu build number used in the workshop.

- `WORKSHOP_HOSTNAME`

  The hostname of the workshop environment.

- `WORKSHOP_PASSWORD`

  The default password used in the workshop.

- `COMPOSE_PROJECT_NAME`

  The Docker resource prefix for all resources managed by Docker Compose.

- `COMPOSE_FILE`

  The Docker Compose template to use; defaults to `docker-compose-default.yaml`.
  Change this value to deploy an alternate workshop environment (e.g. using a different reference architecture).

## Sensu Backend Settings

Please note the following `.env` file configuration parameters for the Sensu backend:

- `SENSU_BACKEND_VERSION`

  The Sensu backend version to use.
  This should be kept in sync with `SENSU_AGENT_VERSION` and `SENSU_CLI_VERSION`.

- `SENSU_BACKEND_CLUSTER_ADMIN_USERNAME`

  The Sensu Go cluster admin username.
  _NOTE: if you're a long-time Sensu Go user you may recall that the default cluster admin username was `admin`; since version 5.16.0 the default cluster admin user has been removed and must now be provided via a new [`sensu-backend init` command](https://docs.sensu.io/sensu-go/latest/reference/backend/#initialization)._

- `SENSU_BACKEND_CLUSTER_ADMIN_PASSWORD`

  The Sensu Go cluster admin password.
  _NOTE: if you're a long-time Sensu Go user you may recall that the default cluster admin password was `P@ssw0rd!`; since version 5.16.0 the default cluster admin password has been removed and must now be provided via the [`sensu-backend init` command](https://docs.sensu.io/sensu-go/latest/reference/backend/#initialization)._

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

## Sensu Agent Settings

Please note the following `.env` file configuration parameters for the Sensu Agent:

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

## Sensu CLI Settings

Please note the following `.env` file configuration parameters for `sensuctl`:

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

## Vault Settings

Please note the following `.env` file configuration parameters for Hashicorp Vault:

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

## Etcd Settings

Please note the following `.env` file configuration parameters for Etcd:

- `ETCD_VERSION`

  ==TODO==

- `ETCD_HOST`

  ==TODO==

- `SENSU_ETCD_CLIENT_URLS`

  ==TODO==

## Postgres Settings

Please note the following `.env` file configuration parameters for Postgres (only used when `COMPOSE_PROJECT_NAME=docker-compose-cluster.yaml`):

- `POSTGRES_VERSION`

  ==TODO==

- `POSTGRES_USER`

  ==TODO==

- `POSTGRES_PASSWORD`

  ==TODO==

- `POSTGRES_DB`

  ==TODO==

## Nginx Settings

Please note the following `.env` file configuration parameters for Nginx (used for hosting Sensu Assets, and an example service to monitor):

- `NGINX_VERSION`

  ==TODO==

## Grafana Settings

Please note the following `.env` file configuration parameters for Grafana (not used when `COMPOSE_FILE=docker-compose-default.yaml` or `COMPOSE_FILE=docker-compose-cluster.yaml`):

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

## InfluxDB Settings

Please note the following `.env` file configuration parameters for InfluxDB (only used when `COMPOSE_FILE=docker-compose-influxdb.yaml`):

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

## Prometheus Settings

Please note the following `.env` file configuration parameters for Prometheus (only used when `COMPOSE_FILE=docker-compose-prometheus.yaml`):

- `PROM_PROMETHEUS_VERSION`

  The Prometheus Docker image version to use in the workshop environment (default: `v2.20.0`).
  Only used when `COMPOSE_FILE=docker-compose-prometheus.yaml`.

- `PROM_PUSHGATEWAY_VERSION`

  The Prometheus Pushgateway Docker image version to use in the workshop environment (default: `v1.2.0`).
  Only used when `COMPOSE_FILE=docker-compose-prometheus.yaml`.

## TimescaleDB Settings

Please note the following `.env` file configuration parameters for TimescaleDB (only used when `COMPOSE_FILE=docker-compose-timescaledb.yaml`):

- `TIMESCALEDB_VERSION`

  The TimescaleDB Docker image version to use in the workshop environment (default: `1.7.2-pg12`).

- `POSTGRES_PASSWORD`

  The TimescaleDB Postgres database password (for the default `postgres` user).

- `POSTGRES_DB`

  The TimescaleDB Postgres database to connect to.
  If omitted, the default database will be `postgres`.
  If a database name is provided for a database that does not exist, it will be created.

