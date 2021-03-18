# Lesson 7: Introduction to Agents & Entities

- [Overview](#overview)
- [Agent configuration](#agent-configuration)
- [Keepalives](#keepalives)
- [Subscriptions](#subscriptions)
- [Agent entities](#agent-entities)
- [Entity management](#entity-management)
- [Advanced topics](#advanced-topics)
  - [Proxy Entities](#proxy-entities)
  - [Events API & event socket](#events-api--event-socket)
  - [StatsD API](#statsd-api)
  - [Platform detection](#platform-detection)
  - [Command allow list](#command-allow-list)
- [EXERCISE: register a proxy entity](#exercise-register-a-proxy-entity)
- [EXERCISE: install and start your first agent](#exercise-install-and-start-your-first-agent)
- [EXERCISE: customize agent and entity configuration](#exercise-customize-agent-and-entity-configuration)
- [Learn more](#learn-more)

## Overview

==TODO: Sensu Agents are observability agents/daemons... Entities are API resources that represent an agent, or other resource (e.g. server, compute instance, container/pod, network device, API endpoint, application/service, or function).==

## Agent Configuration

## Keepalives

## Subscriptions

## Agent Entities

In Sensu, every event must be associated with an [Entity][1-3].
An Entity represents **anything** that needs to be monitored, such as a physical or virtual "server", cloud compute instance, container (or "pod" of containers), application, function, IoT device, or network switch (or pretty much anything else you can imagine).

If you look at your Sensu entity list you'll note that you already have at least one entity (including one named "server-01").
Sensu automatically created this entity when we published our first event data to the pipeline.

> _NOTE: to find the Sensu entity list, run the `sensuctl entity list` or `sensuctl entity info server-01` command(s), or select the "Entities" view in the sidebar of the Sensu web app.
> Self-guided trainees should find this view at: http://127.0.0.1:3000/c/~/n/default/entities._

> **PROTIP:** the default output format of the `sensuctl` CLI is a "tabular" style output, intended for display in your terminal.
> For machine-parsable output, try using the `--output` flag.
> The available output formats are `tabular` (default), `yaml`, `json`, and `wrapped-json`.
> Give it a try with the entity list or entity info commands; for example:
>
> ```shell
> $ sensuctl entity list --format json
> ```

==TODO: overview of entity metadata and system facts.
Mention the existence of non-agent entities, to be covered in lesson 12.==

## Entity Management

==TODO: agent-managed entities (traditional), and backend-managed entities (cloud-native).==

## Advanced topics

### Proxy Entities

==TODO: refer to lesson 12 for more information.==

### Deregistration

### Events API & event socket

==TODO: example use case, a check which produces multiple events...==

### StatsD API

### Platform detection

### Command allow list

## EXERCISE: register a proxy entity

1. Create a proxy Entity using the Sensu Entities API.

   In Sensu, any entity that does not under active management by a Sensu Agent is considered a "proxy" entity.
   Let's create a proxy entity as a precursor to installing our first agent so we can better understand the association between the agent (a software component) and its entity (a Sensu API resource).

   ```shell
   curl -i -X PUT -H "Authorization: Key ${SENSU_API_KEY}" \
        -H "Content-Type: application/json" \
        -d "{\"entity_class\": \"proxy\", \"metadata\":{\"name\":\"i-424242\",\"namespace\":\"${SENSU_NAMESPACE:-default}\"}}" \
        "${SENSU_API_URL:-http://127.0.0.1:8080}/api/core/v2/namespaces/${SENSU_NAMESPACE:-default}/entities/i-424242"
   ```

   Alternatively, here's an easier to read version of the same command, with the addition of some entity metadata (labels).

   ```shell
   curl -i -X PUT -H "Authorization: Key ${SENSU_API_KEY}" \
       -H "Content-Type: application/json" \
       -d "{
            \"metadata\": {
              \"name\": \"i-424242\",
              \"namespace\": \"${SENSU_NAMESPACE:-default}\",
              \"labels\": {
                \"region\": \"us-west-1\",
                \"environment\": \"workshop\"
              }
            },
            \"entity_class\": \"proxy\"
          }" \
       "${SENSU_API_URL:-http://127.0.0.1:8080}/api/core/v2/namespaces/${SENSU_NAMESPACE:-default}/entities/i-424242"
   ```

   Do you see a new entity in Sensu?
   The Sensu Entities API enables us to register endpoints for management by Sensu using external mechanisms (e.g. third-party integrations, discovery scripts, etc).
   Try deleting the entity (e.g. via `sensuctl entity delete i-424242` or using the Sensu web app), and recreating it with different properties.

**NEXT:** If you see the example proxy entity in Sensu, you're ready to move on to the next exercise.

## EXERCISE: install and start your first agent

The Sensu Agent is available for Docker, Ubuntu/Debian, RHEL/CentOS, Windows, MacOS, and FreeBSD.
This exercise will focus on a simplified install for Linux systems, but it will not go into as much detail as the official documentation.
The [official Sensu Go installation documentation](https://docs.sensu.io/sensu-go/latest/operations/deploy-sensu/install-sensu/#install-sensu-agents) provides detailed instructions for installing & operating Sensu Agents on a variety of systems.

1. Download & install the latest Sensu Agent Linux or MacOS binary archive.

   **For RHEL/CentOS systems:**

   ```shell
   curl -LO https://sensu.io/yum-install.sh | sudo bash
   sudo yum install -y sensu-go-agent
   ```

   **For Ubuntu/Debian systems:**

   ```shell
   curl -LO https://sensu.io/apt-install.sh | sudo bash
   sudo apt-get install -y sensu-go-agent
   ```

1. Start the Sensu Agent.

   ```shell
   sudo -E -u sensu sensu-agent start \
   --name workshop \
   --backend-url ${SENSU_BACKEND_URL} \
   --subscriptions linux,workshop \
   --deregister true
   ```

   _NOTE: for help configuring `${SENSU_BACKEND_URL}` please consult [SETUP.md](/docs/SETUP.md)._

   Verify that your agent is running and connected to the Sensu Backend by consulting `sensuctl` (e.g. `sensuctl entity list`) or the Sensu web app.

**NEXT:** If your Sensu Agent has successfully connected to your backend, you're ready to move on to the next exercise.

## EXERCISE: customize agent and entity configuration

Sensu Agents are represented in the Sensu API as Sensu Entities.
As a result, some Sensu Agent configuration parameters are used to manage the behavior of the agent (e.g. TLS certificates, authentication, subscriptions, etc), while others are used to configure the corresponding Sensu Entity (e.g. metadata properties like labels and annotations).

Let's stop our agent and modify its configuration:

1. Stop the Sensu Agent.

   If you started your agent in the previous exercise using the `sensu-agent start` command, you can stop the agent by pressing `Control-C` in your terminal.

   If you started your agent in the previous exercise using systemd, you can stop the agent by running the `sudo systemctl stop sensu-agent` command.

1. Configure Sensu Agent.

   The Sensu Agent supports configuration via **command flags** (e.g. `--backend-url`), a **configuration file** (e.g. `/etc/sensu/agent.yml`), or **environment variables** (e.g. `SENSU_SUBSCRIPTIONS`).
   For training purposes we will use a mix of all three, however in practice you may find that just one method is best suited for your environment (e.g. on Kubernetes or other container-based environments it may be easiest to manage all configuration via environment variables).

   At minimum, the Sensu Agent requires a Sensu backend URL (a websocket API to connect to), and one or more subscriptions (observability topics the agent will subscribe to).
   We'll also add some agent metadata in the form of labels & annotations.

   Let's start by adding the following contents to `/etc/sensu/agent.yaml`:

   ```
   ---
   backend_url: ws://127.0.0.1:8080
   name: workshop
   labels:
     foo: bar
     environment: training
   annotations:
     sensu.io/plugins/slack/config/username: sensu-trainee
   deregister: true
   ```

   > _PROTIP: every `sensu-agent` configuration flag (e.g. `--backend-url ws://127.0.0.1:8081`) has a corresponding field in the agent config file (e.g. `backend-url: [ws://127.0.0.1:8081]`) as well as a corresponding environment variable (e.g. `SENSU_BACKEND_URL="ws://127.0.0.1:8081"`).
   Please visit the [Sensu Agent reference documentation](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-schedule/agent/#configuration-via-environment-variables) to learn more about configuration via environment variables._

1. Start/Restart the Sensu Agent.

   For the purposes of our workshop there are two ways to run the Sensu Agent – using a process manager like systemd, or directly from the command line (with no process management).

   Let's start/restart the agent from the command line again, this time using a mix of environment variables and our configuration file to configure the agent:

   ```shell
   SENSU_NAMESPACE=default \
   SENSU_SUBSCRIPTIONS="linux workshop" \
   sudo -E -u sensu sensu-agent start \
   --config-file /etc/sensu/agent.yaml
   ```

   To start the agent using systemd, run the following command:

   ```shell
   sudo systemctl start sensu-agent
   ```

   _PROTIP: when managing the Sensu Agent process using systemd, additional environment variables may be set in `/etc/default/sensu-agent`._

## Learn more

## Next steps

[Lesson 8: Introduction to Checks](../08/README.md#readme)

-----

## Troubleshooting

### How to access Sensu Agent logs when starting the agent via systemd

```shell
sudo journalctl -fu sensu-agent
```

### Help installing a Sensu Agent

If you are having trouble installing a Sensu Agent on your workstation or another lab system, you can ask your instructor for assistance, or run an agent in the workshop environment.

```
sudo docker-compose run --no-deps --rm -d \
-e SENSU_API_URL=${SENSU_API_URL} \
-e SENSU_NAMESPACE=${SENSU_NAMESPACE} \
-e SENSU_LABELS='{"app": "workshop", "environment": "training"}' \
sensu-agent
```

### The sensu-agent reports various "permission denied" errors

If you have run the `sensu-agent` as the `root` user, or other user with elevated privileges, and then attempt to start the `sensu-agent` process via systemd or other service management, you may encounter various "permission denied" errors.
The officially supported Sensu Agent installation packages (e.g. `.rpm` and `.deb` packages) will install and run all Sensu services as the `sensu` user (i.e. not `root`).
To ensure that the `sensu` users owns all of the files needed to run the Sensu Agent, run the following commands:

```shell
sudo chown -R sensu:sensu /etc/sensu
sudo chown -R sensu:sensu /var/lib/sensu
sudo chown -R sensu:sensu /var/cache/sensu
```

This should resolve any outstanding permissions errors.

### Unknown user `sensu` when starting Sensu Agent

If you installed the Sensu Agent from a Linux binary archive (e.g. `.tar.gz` or `.zip` file) instead of using installer packages, you may encounter "unknown user" errors when running the `sensu-agent`.
The follow commands can be used on Linux systems to create the `sensu` group and user (these are the same commands used by the `.rpm` and `.deb` installer packages):

```shell
sudo groupadd -r sensu
sudo useradd -r -g sensu -d /opt/sensu -s /bin/false -c "Sensu Go" sensu
```
