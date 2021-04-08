# Lesson 7: Introduction to Agents & Entities

- [Overview](#overview)
- [Agent configuration](#agent-configuration)
- [Keepalives](#keepalives)
- [Subscriptions](#subscriptions)
- [Agent entities](#agent-entities)
- [Entity management](#entity-management)
- [Advanced topics](#advanced-topics)
  - [Proxy Entities](#proxy-entities)
  - [Entity Lifecycle Hooks](#entity-lifecycle-hooks)
  - [Agent Events API & event socket](#agent-events-api--event-socket)
  - [StatsD API](#statsd-api)
  - [Platform detection](#platform-detection)
  - [Command allow list](#command-allow-list)
- [EXERCISE: register a proxy entity](#exercise-register-a-proxy-entity)
- [EXERCISE: install and start your first agent](#exercise-install-and-start-your-first-agent)
- [EXERCISE: customize agent and entity configuration](#exercise-customize-agent-and-entity-configuration)
- [Learn more](#learn-more)
- [Next steps](#next-steps)
- [Troubleshooting](#troubleshooting)

## Overview

The Sensu Agent is a lightweight observability client that runs on your infrastructure.
Sensu Agents are represented in the Sensu API as [Sensu Entities](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-entities/entities/).
The primary function of the Sensu Agent is to generate events (observability data) for processing in the Sensu observability pipeline.

Sensu Entities are API resources that represent anything from a server, compute instance, container/pod, connected device (IoT gateways and devices), network device, application, or even a function.
Valid Sensu Entities must have an `entity_class`, the most common of which are "agent" and "proxy" – a generic entity class designation for any resource that is not actively under management by a Sensu Agent.

## Agent Configuration

The Sensu Agent is distributed as a single statically compiled binary (`sensu-agent`), typically installed via installer packages or Docker containers.
All Sensu configuration is loaded at `sensu-agent` start time, so the agent must be restarted to update the configuration.
The Sensu Agent can be configured via command flags (e.g. `sensu-agent start --backend-url`), a config file (see below for example), or environment variables (e.g. `SENSU_BACKEND_URL`).
If configuration values are set in multiple places, the `sensu-agent` will apply configuration in the following order:

1. Configuration flags (highest)
2. Environment variables
3. Configuration files
4. Default values, if any (lowest)

<details>
<summary><strong>Example <code>sensu-agent start --help</code> configuration flags:</strong></summary>

```
start the sensu agent

Usage:
  sensu-agent start [flags]

Flags:
      --agent-managed-entity                  manage this entity via the agent
      --allow-list string                     path to agent execution allow list configuration file
      --annotations stringToString            entity annotations map (default [])
      --api-host string                       address to bind the Sensu client HTTP API to (default "127.0.0.1")
      --api-port int                          port the Sensu client HTTP API listens on (default 3031)
      --assets-burst-limit int                asset fetch burst limit (default 100)
      --assets-rate-limit float               maximum number of assets fetched per second
      --backend-handshake-timeout int         number of seconds the agent should wait when negotiating a new WebSocket connection (default 15)
      --backend-heartbeat-interval int        interval at which the agent should send heartbeats to the backend (default 30)
      --backend-heartbeat-timeout int         number of seconds the agent should wait for a response to a hearbeat (default 45)
      --backend-url strings                   ws/wss URL of Sensu backend server (to specify multiple backends use this flag multiple times) (default [ws://127.0.0.1:8081])
      --cache-dir string                      path to store cached data (default "/var/cache/sensu/sensu-agent")
      --cert-file string                      TLS certificate in PEM format
  -c, --config-file string                    path to sensu-agent config file
      --deregister                            ephemeral agent
      --deregistration-handler string         deregistration handler that should process the entity deregistration event.
      --detect-cloud-provider                 enable cloud provider detection mechanisms
      --disable-assets                        disable check assets on this agent
      --disable-api                           disable the Agent HTTP API
      --disable-sockets                       disable the Agent TCP and UDP event sockets
      --discover-processes                    indicates whether process discovery should be enabled
      --events-burst-limit                    /events api burst limit
      --events-rate-limit                     maximum number of events transmitted to the backend through the /events api
  -h, --help                                  help for start
      --insecure-skip-tls-verify              skip ssl verification
      --keepalive-critical-timeout uint32     number of seconds until agent is considered dead by backend to create a critical event (default 0)
      --keepalive-handlers string             comma-delimited list of keepalive handlers for this entity. This flag can also be invoked multiple times
      --keepalive-interval uint32             number of seconds to send between keepalive events (default 20)
      --keepalive-warning-timeout uint32      number of seconds until agent is considered dead by backend to create a warning event (default 120)
      --key-file string                       TLS certificate key in PEM format
      --labels stringToString                 entity labels map (default [])
      --log-level string                      logging level [panic, fatal, error, warn, info, debug] (default "info")
      --name string                           agent name (defaults to hostname) (default "my-hostname")
      --namespace string                      agent namespace (default "default")
      --password string                       agent password (default "P@ssw0rd!")
      --redact string                         comma-delimited customized list of fields to redact
      --require-fips                          indicates whether fips support should be required in openssl
      --require-openssl                       indicates whether openssl should be required instead of go's built-in crypto
      --socket-host string                    address to bind the Sensu client socket to (default "127.0.0.1")
      --socket-port int                       port the Sensu client socket listens on (default 3030)
      --statsd-disable                        disables the statsd listener and metrics server
      --statsd-event-handlers strings         comma-delimited list of event handlers for statsd metrics
      --statsd-flush-interval int             number of seconds between statsd flush (default 10)
      --statsd-metrics-host string            address used for the statsd metrics server (default "127.0.0.1")
      --statsd-metrics-port int               port used for the statsd metrics server (default 8125)
      --subscriptions string                  comma-delimited list of agent subscriptions
      --trusted-ca-file string                tls certificate authority
      --user string                           agent user (default "agent")
```

</details>

All of the `sensu-agent` command flags (except `--config-file`) can be set via the Sensu Agent configuration file using the same flag name (sans the `--`).

<details>
<summary><strong>Example <code>agent.yml</code> file:</strong></summary>

```yaml
---
# Sensu agent configuration

##
# agent overview
##
#name: "hostname"
#namespace: "default"
#subscriptions:
#  - example
#labels:
#  example_key: "example value"
#annotations:
#  example/key: "example value"

##
# agent configuration
##
#backend-url:
#  - "ws://127.0.0.1:8081"
#cache-dir: "/var/cache/sensu/sensu-agent"
#config-file: "/etc/sensu/agent.yml"
#log-level: "warn" # available log levels: panic, fatal, error, warn, info, debug

##
# api configuration
##
#api-host: "127.0.0.1"
#api-port: 3031
#disable-api: false
#events-burst-limit: 10
#events-rate-limit: 10.0

##
# authentication configuration
##
#user: "agent"
#password: "P@ssw0rd!"

##
# monitoring configuration
##
#deregister: false
#deregistration-handler: "example_handler"
#keepalive-timeout: 120
#keepalive-interval: 20

##
# security configuration
##
#insecure-skip-tls-verify: false
#redact:
#  - password
#  - passwd
#  - pass
#  - api_key
#  - api_token
#  - access_key
#  - secret_key
#  - private_key
#  - secret
#trusted-ca-file: "/path/to/trusted-certificate-authorities.pem"

##
# socket configuration
##
#disable-sockets: false
#socket-host: "127.0.0.1"
#socket-port: 3030

##
# statsd configuration
##
#statsd-disable: false
#statsd-event-handlers:
#  - example_handler
#statsd-flush-interval: 10
#statsd-metrics-host: "127.0.0.1"
#statsd-metrics-port: 8125
```

</details>

Every `sensu-agent` configuration flag (e.g. `--backend-url=ws://127.0.0.1:8081`) also has a corresponding environment variable (e.g. `SENSU_BACKEND_URL="ws://127.0.0.1:8081"`).
All Sensu environment variable names are prefixed with `SENSU_`, followed by the corresponding flag in capitalized letters and underscores (`_`) instead of dashes (`-`).
For example, the environment variable for the flag `--api-host` is `SENSU_API_HOST`.

<details>
<summary><strong>Example configuration environment variables:</strong></summary>

```
export SENSU_BACKEND_URL="ws://sensu-backend-1:8081 ws://sensu-backend-2:8081 ws://sensu-backend-3:8081"
export SENSU_NAMESPACE="default"
export SENSU_SUBSCRIPTIONS="linux nginx postgres"
export SENSU_USER="agent"
export SENSU_PASSWORD="topsecret"
export SENSU_TRUSTED_CA_FILE="/path/to/ca.pem"
```

</details>

### Communication

Sensu Agents connect to Sensu Backends over a persistent [WebSocket](https://en.m.wikipedia.org/wiki/WebSocket) (`ws`) or encrypted WebSocket Secure (`wss`) connection.
For optimal network throughput, agents will attempt to negotiate the use of [Protobuf serialization](https://en.m.wikipedia.org/wiki/Protocol_Buffers) when communicating with a Sensu backend that supports it. This communication is via clear text by default.

### Authentication

Agent authentication is required connect to Sensu Backends.
The Sensu Agent supports [basic authentication](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-schedule/agent/#username-and-password-authentication) (username/password) or [mutual transport layer security (mTLS) certificate authentication](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-schedule/agent/#mtls-authentication).

## Keepalives

Sensu uses a heartbeat mechanism called "keepalives" to monitor Sensu Agent connectivity.
Under the covers, a `keepalive` is effectively just another Sensu Event that the Sensu Agent publishes once every `--keepalive-interval` configured seconds.
The `keepalive` event contains the current Sensu Agent configuration and entity properties.
If a Sensu Agent fails to report a `keepalive` event within the `--keepalive-warning-timeout` or `--keepalive-critical-timeout` configured thresholds, a warning or critical event is produced on behalf of the Agent.

Keepalive monitoring can be disabled using the `--deregister true` flag, which prompts the Sensu backend to remove Sensu Agent entities that have stopped generating `keepalive` events.

## Subscriptions

Sensu uses the [publish/subscribe model of communication](https://en.wikipedia.org/wiki/Publish–subscribe_pattern).
Sensu "subscriptions" are equivalent to topics in a traditional publish/subscribe message bus.
Sensu backends "publish" requests for observability data and agents who are subscribed to the corresponding topics receive the published request, perform the corresponding monitoring job, and sending the corresponding event data to the observability pipeline.

The publish/subscribe model is powerful in ephemeral or elastic infrastructures, where endpoint identifiers are unpredictable and break traditional host-based monitoring configuration.
Instead of configuring monitoring on a per-host basis, Sensu follows a service-based monitoring configuration model where monitors are configured per service topic (e.g. "postgres"), and agents deployed on hosts running the corresponding services simply subscribe to those same topics.

## Entity specification

Sensu Entities are structured like other Sensu API resources, with the same common top-level fields/objects (i.e. `type`, `api_version`, `metadata`, `spec`).
The Sensu Entity `spec` object contains the following fields:

<details>
<summary><strong>Sensu Entity <code>spec</code> properties:</strong></summary>

```json
{
  "entity_class": "agent",
  "system": {
    "hostname": "server-01",
    "os": "linux",
    "platform": "alpine",
    "platform_family": "alpine",
    "platform_version": "3.12.6",
    "network": {
      "interfaces": [
        {
          "name": "lo",
          "addresses": [
            "127.0.0.1/8"
          ]
        },
        {
          "name": "eth0",
          "mac": "02:42:ac:13:00:07",
          "addresses": [
            "172.19.0.7/16"
          ]
        }
      ]
    },
    "arch": "amd64",
    "libc_type": "musl",
    "vm_system": "docker",
    "vm_role": "guest",
    "cloud_provider": "EC2"
  },
  "subscriptions": [
    "system/linux",
    "workshop",
    "devel",
    "entity:server-01"
  ],
  "last_seen": 1617835646,
  "deregister": true,
  "deregistration": {},
  "user": "agent",
  "redact": [
    "password",
    "passwd",
    "pass",
    "api_key",
    "api_token",
    "access_key",
    "secret_key",
    "private_key",
    "secret"
  ],
  "sensu_agent_version": "6.2.7"
}
```

</details>

The only required entity `spec` property is `entity_class` – all other properties are optional.

> _NOTE: Sensu Entities that are not associated with a running Sensu Agent are generally referred to as "proxy entities" and will have an `entity_class` of "proxy".
> For more information about proxy entities and how they are managed by Sensu, please see [Lesson 13: Introduction to Proxy Entities & Proxy Checks](/lessons/operator/13/README.md#readme)._

## Agent Entities

If you look at your Sensu entity list you'll note that you already have at least one entity (including one named "i-424242").
Sensu automatically created this entity when we published our first event data to the pipeline, but it isn't associated with a running agent, so its agent class is set to "proxy".

```shell
$ sensuctl entity list
     ID      Class   OS   Subscriptions   Last Seen
 ────────── ─────── ──── ─────────────── ───────────
  i-424242   proxy                        N/A
```

## Entity management

There are two types of entity management in Sensu Go 6.x:

- **API-managed entities (cloud-native).**

  Certain entity properties can be modified in real-time via the API, CLI, or web app.
  Agent entities are API-managed by default in Sensu Go 6.x (API management was not available for agent entities in Sensu Go 5.x).

  [Learn more (reference docs)](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-entities/entities/#manage-agent-entities-via-the-backend)

- **Agent-managed entities (traditional).**

  All entity properties are managed via `sensu-agent` configuration (command flags, config file, or environment variables).
  Agent-managed entity updates are applied by modifying one or more configuration attributes and restarting the `sensu-agent` process.
  To enable agent management for an agent entity in Sensu Go 6.x, set the `--agent-managed-entity` flag.

  [Learn more (reference docs)](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-entities/entities/#manage-agent-entities-via-the-agent)

**NOTE:** All agent entities are _created_ using the `sensu-agent` configuration; i.e. the _initial_ configuration for API-managed entities is provided by the `sensu-agent`, but subsequent edits made to the `sensu-agent` (via config flags, config file, or environment variables) will be ignored unless the `--agent-managed-entity` flag is set.

## Advanced topics

### Proxy Entities

A "proxy entity" is any Sensu entity resource that is not actively under management by a Sensu Agent.
Proxy entities have an `entity_class` of "proxy" and can be used to represent any resource under management by Sensu, though proxy entities are generally used to represent resources where we can't run an agent (e.g.  certain IoT/connected devices, or network devices), or resources that may emit observability data directly to Sensu without the need for an agent (e.g. applications or serverless functions).

> _NOTE: For more information about proxy entities and how they are managed by Sensu, please see [Lesson 13: Introduction to Proxy Entities & Proxy Checks](/lessons/operator/13/README.md#readme)._

### Entity Lifecycle Hooks

==TODO: entity registration and deregistration handlers...==

### Events API & event socket

The Sensu Agent Events API provides an HTTP POST endpoint for publishing observabilty data to the Sensu Observability Pipeline.
While similar to the Sensu backend Events API, the Sensu Agent Events API differs in a few ways:

- Only accepts HTTP POST requests (i.e. it is a write-only API endpoint)
- Authentication is not supported (authentication is managed via the Sensu Agent)
- Accepts event payloads without an `entity` object (all events are automatically associated with the agent entity)

The agent places events created via the `/events POST` endpoint into a durable queue stored on disk.
In case of a loss of connection with the backend or agent shutdown, the agent preserves queued event data.
When the connection is reestablished, the agent sends the queued events to the backend.

To learn more about the Agent Events API, please visit the [Sensu Agent reference documentation](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-schedule/agent/#create-observability-events-using-the-agent-api).

### Dead mans switches

The Sensu Agent Events API makes it easy to implement dead mans switches with as little as one line of `bash` or Powershell (see below for examples).
The Sensu Event specification supports an `event.check.ttl` attribute which can be set to instruct the Sensu platform to expect subsequent event updates; if another event is not received within the configured TTL interval, Sensu generates a TTL event with a status like "Last check execution was 120 seconds ago" and processes the event using the configured handlers.

Dead mans switches are useful for monitoring jobs like nighly backup jobs (e.g. a bash script scheduled via a cron job).
A simple one-liner at the end of the backup script can be used to report on the backup status (e.g. `"Backup completed successfully. Backup data is available at <backup location URI>.`) with a ~25 hour TTL to account for long running backup jobs.
A failed backup job will result in a TTL event without the need for any if/then/else conditional logic in the script (i.e. no need to also send an event if the script fails) – the mere absence of an "OK" event is all that is needed.

#### Examples

**Bash**

```shell
curl -XPOST -H 'Content-Type: application/json' -d '{"check":{"metadata":{"name":"dead-mans-switch"},"output":"Alert if another event is not received in 30s","status":0,"ttl":30}}' 127.0.0.1:3031/events
```

**Powershell**

```powershell
Invoke-RestMethod -Method POST -ContentType "application/json" -Body '{"check":{"metadata":{"name":"dead-mans-switch"},"output":"Alert if another event is not received in 30s","status":0,"ttl":30}}' -Uri "${Env:SENSU_API_URL}/api/core/v2/namespaces/${Env:SENSU_NAMESPACE}/events"
```

### StatsD API

==TODO==

### Platform detection

==TODO==

### Command allow list

==TODO==

## EXERCISE: register a proxy entity

1. Create a proxy Entity using the Sensu Entities API.

   In Sensu, any entity that does not under active management by a Sensu Agent is considered a "proxy" entity.
   Let's create a proxy entity as a precursor to installing our first agent so we can better understand the association between the agent (a software component) and its entity (a Sensu API resource).

   **Mac and Linux users:**

   ```shell
   curl -i -X PUT -H "Authorization: Key ${SENSU_API_KEY}" \
        -H "Content-Type: application/json" \
        -d "{\"entity_class\": \"proxy\", \"metadata\":{\"name\":\"i-424242\",\"namespace\":\"${SENSU_NAMESPACE:-default}\"}}" \
        "${SENSU_API_URL:-http://127.0.0.1:8080}/api/core/v2/namespaces/${SENSU_NAMESPACE:-default}/entities/i-424242"
   ```

   **Windows users (Powershell):**

   ```powershell
   Invoke-RestMethod `
     -Method PUT `
     -Headers @{"Authorization" = "Key ${Env:SENSU_API_KEY}";} `
     -ContentType "application/json" `
     -Body "{`"entity_class`": `"proxy`", `"metadata`":{`"name`":`"i-424242`",`"namespace`":`"${Env:SENSU_NAMESPACE}`"}}" `
     -Uri "${Env:SENSU_API_URL}/api/core/v2/namespaces/${Env:SENSU_NAMESPACE}/entities/i-424242"
   ```

   Do you see a new entity in Sensu?
   The Sensu Entities API enables us to register endpoints for management by Sensu using external mechanisms (e.g. third-party integrations, discovery scripts, etc).
   Try deleting the entity (e.g. via `sensuctl entity delete i-424242` or using the Sensu web app), and recreating it with different properties.

**NEXT:** If you see the example proxy entity in Sensu, you're ready to move on to the next exercise.

## EXERCISE: install and start your first agent

The Sensu Agent is available for Docker, Ubuntu/Debian, RHEL/CentOS, Windows, MacOS, and FreeBSD.
This exercise will focus on a simplified install for Linux systems, but it will not go into as much detail as the official documentation.
The [official Sensu Go installation documentation](https://docs.sensu.io/sensu-go/latest/operations/deploy-sensu/install-sensu/#install-sensu-agents) provides detailed instructions for installing & operating Sensu Agents on a variety of systems.

1. Decide where to deploy your Sensu Agent.

   In general, Sensu Agents can be deployed almost anywhere you can imagine – from bare metal servers to cloud compute instances to containers and more.
   In fact, Sensu's publish/subscribe architecture makes it easy to traverse complex network topologies including VPNs, NATs, and even "air-gapped" environments as often found in the enterprise.
   As long as a Sensu agent can reach a Sensu backend websocket API – directly or via one or more proxies – everything should "just work".

   When the Sensu backend is installed in a centralized location (e.g. in close proximity to other IT management infrastructure), this will generally provide the most flexibility.
   Conversely, if you are running the workshop on your laptop (e.g. using `docker-compose`) then the best place to install an agent is likely also on your laptop.
   As such, for the purposes of the remaining exercises in this workshop, we recommend installing Sensu Agents as follows:

   - **Self guided users:** the Sensu Agent should be installed on your local workstation.
   - **Instructor-led workshop users:** the Sensu Agent may be installed on your local workstation (recommended), or on another system that can reach the shared `${SENSU_BACKEND_URL}`.

1. Verify environment variables.

   If you're installing the Sensu Agent on a system other than the workstation where you've been following along with the rest of this workshop you'll need to set a few environment variables.

   To verify if the required environment variables are already set, run the following command:

   **Linux and Mac users:**

   ```shell
   env | grep SENSU
   ```

   **Windows users (Powershell):**

   ```powershell
   Get-ChildItem env: | Out-String -Stream | Select-String -Pattern SENSU
   ```

   Do you see the expected values for `SENSU_BACKEND_URL` and `SENSU_NAMESPACE`?
   If so, you're ready to move on to the next step!

   If not, run the following commands to set the environment variables:

   **Mac and Linux users:**

   ```
   export SENSU_VERSION=${SENSU_VERSION:-"6.2.7"}
   export SENSU_BACKEND_URL=${SENSU_BACKEND_URL:-"ws://127.0.0.1:8081"}
   export SENSU_NAMESPACE=${SENSU_NAMESPACE:-"default"}
   export SENSU_USER=${SENSU_USER:-"sensu"}
   export SENSU_PASSWORD=${SENSU_PASSWORD:-"sensu"}
   ```

   **Windows users (Powershell):**

   ```powershell
   ${Env:SENSU_VERSION}="6.2.7"
   ${Env:SENSU_BUILD}="4449"
   ${Env:SENSU_BACKEND_URL}="ws://127.0.0.1:8081"
   ${Env:SENSU_NAMESPACE}="default"
   ${Env:SENSU_USER}="sensu"
   ${Env:SENSU_PASSWORD}="sensu"
   ```

   Instructor-led workshop users will need to replace the `SENSU_BACKEND_URL` IP address (or hostname), `SENSU_NAMESPACE`, `SENSU_USER`, and `SENSU_PASSWORZD` with the values provided by their instructor.

1. Download & install the latest Sensu Agent for MacOS, Windows, or Linux.

   **Mac users:**

   ```shell
   curl -LO https://s3-us-west-2.amazonaws.com/sensu.io/sensu-go/${SENSU_VERSION}/sensu-go_${SENSU_VERSION}_darwin_amd64.tar.gz
   tar -xzf sensu-go_${SENSU_VERSION}_darwin_amd64.tar.gz sensu-agent
   rm sensu-go_${SENSU_VERSION}_darwin_amd64.tar.gz
   sudo mkdir -p /usr/local/bin/
   sudo mv sensu-agent /usr/local/bin/sensu-agent
   ```

   **Windows users (Powershell):**

   ```powershell
   Invoke-WebRequest `
     -Uri "https://s3-us-west-2.amazonaws.com/sensu.io/sensu-go/${Env:SENSU_VERSION}/sensu-go-agent_${Env:SENSU_VERSION}.${Env:SENSU_BUILD}_en-US.x64.msi" `
     -OutFile "${Env:UserProfile}\sensu-go-agent_${Env:SENSU_VERSION}.${Env:SENSU_BUILD}_en-US.x64.msi"
   msiexec.exe /i "${Env:UserProfile}\sensu-go-agent_${Env:SENSU_VERSION}.${Env:SENSU_BUILD}_en-US.x64.msi" /qr
   rm "${Env:UserProfile}\sensu-go-agent_${Env:SENSU_VERSION}.${Env:SENSU_BUILD}_en-US.x64.msi"
   ${Env:Path} += ";C:\Program Files\Sensu\sensu-agent\bin"
   ```

   **Linux users:**

   ```shell
   curl -LO https://s3-us-west-2.amazonaws.com/sensu.io/sensu-go/${SENSU_VERSION}/sensu-go_${SENSU_VERSION}_${SENSU_PLATFORM}_${SENSU_ARCH}.tar.gz && \
   tar -xzf sensu-go_${SENSU_VERSION}_${SENSU_PLATFORM}_${SENSU_ARCH}.tar.gz -C /usr/bin/ && \
   rm sensu-go_${SENSU_VERSION}_${SENSU_PLATFORM}_${SENSU_ARCH}.tar.gz
   ```

1. Start the Sensu Agent.

   **Mac users:**

   ```shell
   sudo -E -u _sensu sensu-agent start \
   --name workshop \
   --backend-url ${SENSU_BACKEND_URL} \
   --namespace ${SENSU_NAMESPACE} \
   --subscriptions system/macos,workshop \
   --deregister true \
   --cache-dir /opt/sensu/sensu-agent/cache \
   --user ${SENSU_USER} \
   --password ${SENSU_PASSWORD}
   ```

   **Windows users (Powershell):**

   ```powershell
   sensu-agent start `
   --name workshop `
   --backend-url ${Env:SENSU_BACKEND_URL} `
   --namespace ${Env:SENSU_NAMESPACE} `
   --subscriptions system/windows,workshop `
   --deregister true `
   --user ${Env:SENSU_USER} `
   --password ${Env:SENSU_PASSWORD}
   ```

   **Linux users:**

   ```shell
   sudo -E -u sensu sensu-agent start \
   --name workshop \
   --backend-url ${SENSU_BACKEND_URL} \
   --namespace ${SENSU_NAMESPACE} \
   --subscriptions system/linux,workshop \
   --deregister true \
   --user ${SENSU_USER} \
   --password ${SENSU_PASSWORD}
   ```

   Verify that your agent is running and connected to the Sensu Backend by consulting `sensuctl` (e.g. `sensuctl entity list`) or the Sensu web app.

**NEXT:** If your Sensu Agent has successfully connected to your backend, you're ready to move on to the next exercise.

## EXERCISE: customize agent and entity configuration

Sensu Agents are represented in the Sensu API as Sensu Entities.
As a result, some Sensu Agent configuration parameters are used to manage the behavior of the agent (e.g. TLS certificates, authentication, subscriptions, etc), while others are used to configure the corresponding Sensu Entity (e.g. metadata properties like labels and annotations).

Let's stop our agent and modify its configuration:

1. Stop the Sensu Agent.

   If you started your agent in the previous exercise using the `sensu-agent start` command, you can stop the agent by pressing `Control-C` in your terminal.

1. Configure Sensu Agent.

   The Sensu Agent supports configuration via **command flags** (e.g. `--backend-url`), a **configuration file** (e.g. `/etc/sensu/agent.yml`), or **environment variables** (e.g. `SENSU_SUBSCRIPTIONS`).
   For training purposes we will use a mix of all three, however in practice you may find that just one method is best suited for your environment (e.g. on Kubernetes or other container-based environments it may be easiest to manage all configuration via environment variables).

   At minimum, the Sensu Agent requires a Sensu backend URL (a websocket API to connect to), and one or more subscriptions (observability topics the agent will subscribe to).
   We'll also add some agent metadata in the form of labels & annotations.

   Let's start by creating an `agent.yaml` configuration file in one of the following recommended locations:

   - **Mac users:** `/opt/sensu/agent.yaml`
   - **Windows users:** `${Env:UserProfile}\Sensu\agent.yaml`
   - **Linux users:** `/etc/sensu/agent.yaml`

   Now let's copy the following contents into the `agent.yaml` file:

   ```yaml
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

   Make sure to save the contents of the file before moving on to the next step.

1. Start/Restart the Sensu Agent.

   Let's start/restart the agent from the command line again, this time using a mix of environment variables and our configuration file to configure the agent.

   **Mac users:**

   ```shell
   SENSU_SUBSCRIPTIONS="system/macos workshop" \
   sudo -E -u _sensu sensu-agent start \
   --config-file /opt/sensu/agent.yaml \
   --cache-dir /opt/sensu/sensu-agent/cache \
   --user ${SENSU_USER} \
   --password ${SENSU_PASSWORD}
   ```

   **Windows users (Powershell):**

   ```powershell
   ${Env:SENSU_SUBSCRIPTIONS}="system/windows workshop" `
   sensu-agent start `
   --config-file "${Env:UserProfile}\Sensu\agent.yaml" `
   --user ${Env:SENSU_USER} `
   --password ${Env:SENSU_PASSWORD}
   ```

   **Linux users:**

   ```shell
   SENSU_SUBSCRIPTIONS="system/linux workshop" \
   sudo -E -u sensu sensu-agent start \
   --config-file "/etc/sensu/agent.yaml" \
   --user ${SENSU_USER} \
   --password ${SENSU_PASSWORD}
   ```

   Notice that we have moved the `--name`, `--backend-url`, and `--deregister` configuration settings into the `agent.yaml` config file, and we are now explicitly setting the `SENSU_SUBSCRIPTIONS` environment variable in place of `--subscriptions`... but how/where is `--namespace` being set?
   The Sensu Agent is reading the value of `SENSU_NAMESPACE` from the environment variable, without the need for explicitly setting the variable with the `sensu-agent start` command.

   In the previous exercise we provided all of the configuration via `sensu-agent start` command flags.
   In this exercise we've moved some configuration to a config file, and other configuration to environment variables.
   Understanding how to configure Sensu using all three methods – config flags, config file, and environment variables – is very useful in heterogeneus environments (e.g. mix of servers, compute instances, and containers) where a configuration method that is easier to manage in one context might not be as easy in another context.

## Learn more

## Next steps

[Share your feedback on Lesson 07](https://github.com/sensu/sensu-go-workshop/issues/new?template=lesson_feedback.md&labels=feedback&title=Lesson%2007%20Feedback)

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

### Unknown user `sensu` or `_sensu` when starting Sensu Agent

**Linux users:**

If you installed the Sensu Agent from a Linux binary archive (e.g. `.tar.gz` or `.zip` file) instead of using installer packages, you may encounter "unknown user" errors when running the `sensu-agent`.
The follow commands can be used on Linux systems to create the `sensu` group and user (these are the same commands used by the `.rpm` and `.deb` installer packages):

```shell
sudo groupadd -r sensu
sudo useradd -r -g sensu -d /opt/sensu -s /bin/false -c "Sensu Go" sensu
```

**MacOS users:**

MacOS installer packages are not yet available for Sensu Go, but Mac users are encouraged to run the `sensu-agent` using a MacOS service account (e.g. `_sensu`).
To create a `_sensu` service account for MacOS, please run the following commands:

```shell
sudo dscl . -create /Groups/_sensu gid 7678
sudo dscl . -create /Groups/_sensu RealName "Sensu Go service group"
sudo dscl . -create /Groups/_sensu passwd "*"
sudo dscl . -create /Users/_sensu
sudo dscl . -create /Users/_sensu uid 7678
sudo dscl . -create /Users/_sensu gid 7678
sudo dscl . -create /Users/_sensu NFSHomeDirectory /opt/sensu
sudo dscl . -create /Users/_sensu UserShell /bin/bash
sudo dscl . -create /Users/_sensu RealName "Sensu Go service account"
sudo dscl . -create /Users/_sensu passwd "*"
sudo mkdir -p /opt/sensu
sudo chown -R _sensu:_sensu /opt/sensu
```

To delete the `_sensu` service account and remove the service account home directory, run the following commands:

```shell
sudo dscl . -delete /Groups/_sensu
sudo dscl . -delete /Users/_sensu
sudo rm -rf /opt/sensu
```

If you would prefer not to install a service account on your workstation, you may run the `sensu-agent` as root (e.g. remove the `-u _sensu` from `sudo sensu-agent start`), or set the `--cache-dir` to a writable location (e.g. `--cache-dir .sensu`).

### Encountering "command not found" errors when running `sensu-agent` on MacOS

Fresh MacOS installations may need to add `/usr/local/bin` to the system `$PATH`.
To temporarily modify `$PATH` in your current shell, use the following command:

```shell
export PATH=/usr/local/bin:$PATH
```

For more information on managing system `$PATH`, please consult the `path_helper` utilty (via `man path_helper`).
