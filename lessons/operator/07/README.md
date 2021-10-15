# Lesson 7: Introduction to Agents

- [Goals](#goals)
- [The Sensu Agent](#the-sensu-agent)
  - [Authentication and Communication](#authentication-and-communication)
  - [EXERCISE 1: Install the Sensu Agent](#exercise-1-install-the-sensu-agent)
    - [Scenario](#scenario)
    - [Solution](#solution)
    - [Steps](#steps)
- [Configuring the Agent](#configuring-the-agent)
  - [Configuration Priority](#configuration-priority)
  - [Configuration Names and Formats](#configuration-names-and-formats)
  - [EXERCISE 2: Customize Agent Configuration](#exercise-2-customize-agent-configuration)
    - [Scenario](#scenario-1)
    - [Solution](#solution-1)
    - [Steps](#steps-1)
- [Discussion](#discussion)
  - [Multiple Configuration Methods](#multiple-configuration-methods)
  - [Keepalives](#keepalives)
- [Learn More](#learn-more)
- [Next Steps](#next-steps)

## Goals

In this lesson we will install and configure the Sensu agent, and discuss how events and other status are communicated to the backend.
This lesson is intended for operators of Sensu, and assumes you have [set up a local workshop environment][setup_workshop].

## The Sensu Agent

An agent is a lightweight observability client that runs on your infrastructure.
The agent generates the events which are processed by the observability pipeline.

The agent is a statically-compiled binary (`sensu-agent`), typically installed via package management or Docker containers.
Packages are available for Docker, Ubuntu/Debian, RHEL/CentOS, Windows, MacOS, and FreeBSD.

### Authentication and Communication

Authentication is required for an agent to connect to the backend.
The agent supports [basic authentication](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-schedule/agent/#username-and-password-authentication) (username/password) or [mTLS authentication](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-schedule/agent/#mtls-authentication).

Agents connect to the backend over a persistent [WebSocket](https://en.m.wikipedia.org/wiki/WebSocket) (`ws`) or encrypted WebSocket Secure (`wss`) connection.
For optimal network throughput, agents will attempt to negotiate the use of [Protobuf serialization](https://en.m.wikipedia.org/wiki/Protocol_Buffers) when communicating with a backend that supports it. Communication is via clear text by default.

### EXERCISE 1: Install the Sensu Agent

#### Scenario

You have a server, container, connected device, or service that you want to manage with Sensu.

#### Solution

Install a Sensu Agent. 
The agent runs as a separate process that observes your system.
It can run directly on the system you are observing, or anywhere on the network.
Once it is installed, you can update its configuration and behavior dynamically without the need to redeploy.

#### Steps

> **BEFORE YOU START:**
> 
> Make sure you have the following environment variables set:
>
> - `SENSU_VERSION`
> - `SENSU_BUILD`
> - `SENSU_BACKEND_URL`
> - `SENSU_NAMESPACE`
> - `SENSU_USER`
> - `SENSU_PASSWORD`
> 
> If any are missing, review the environment setup from [Lesson 3: Using the Sensu CLI](../03/README.md#readme).

1. **Download & Install the Agent**

   This exercise will focus on a simplified install for running the agent on your local workstation.
   For more details, the [Sensu Go installation documentation](https://docs.sensu.io/sensu-go/latest/operations/deploy-sensu/install-sensu/#install-sensu-agents) provides comprehensive instructions for installing & operating the agent.

   1. **Download the Installation Package**

      The agent binary is available for download from Sensu's repository on Amazon S3.

      **MacOS**

      ```shell
      curl -LO https://s3-us-west-2.amazonaws.com/sensu.io/sensu-go/${SENSU_VERSION}/sensu-go_${SENSU_VERSION}_darwin_amd64.tar.gz
      ```

      **Windows (PowerShell)**

      ```powershell
      Invoke-WebRequest `
       -Uri "https://s3-us-west-2.amazonaws.com/sensu.io/sensu-go/${Env:SENSU_VERSION}/sensu-go-agent_${Env:SENSU_VERSION}.${Env:SENSU_BUILD}_en-US.x64.msi" `
       -OutFile "${Env:UserProfile}\sensu-go-agent_${Env:SENSU_VERSION}.${Env:SENSU_BUILD}_en-US.x64.msi"
      ```

      **Linux**

      ```shell
      curl -LO https://s3-us-west-2.amazonaws.com/sensu.io/sensu-go/${SENSU_VERSION}/sensu-go_${SENSU_VERSION}_linux_amd64.tar.gz 
      ```

   2. **Install the Package and Cleanup**
  
      Installation involves extracting and copying the `sensu-agent` executable to an approriate location on the system.
      Afterwards, we will delete the installation package.

      **MacOS**

      ```shell
      tar -xzf sensu-go_${SENSU_VERSION}_darwin_amd64.tar.gz sensu-agent
      rm sensu-go_${SENSU_VERSION}_darwin_amd64.tar.gz
      sudo mkdir -p /usr/local/bin/
      sudo mv sensu-agent /usr/local/bin/sensu-agent
      ```

      **Windows (PowerShell)**

      ```powershell
      msiexec.exe /i "${Env:UserProfile}\sensu-go-agent_${Env:SENSU_VERSION}.${Env:SENSU_BUILD}_en-US.x64.msi" /qr
      rm "${Env:UserProfile}\sensu-go-agent_${Env:SENSU_VERSION}.${Env:SENSU_BUILD}_en-US.x64.msi"
      ${Env:Path} += ";C:\Program Files\Sensu\sensu-agent\bin"
      ```

      **Linux**

      ```shell
      sudo -E tar -xzf sensu-go_${SENSU_VERSION}_linux_amd64.tar.gz -C /usr/bin/
      rm sensu-go_${SENSU_VERSION}_linux_amd64.tar.gz
      ```

2. **Start the Agent.**

    > _**NOTE:**_ Mac and Linux users are encouraged to run the `sensu-agent` with a service account (e.g. a user named `sensu` or `_sensu`).
    > To create this service account, please read ["Create a Sensu Service Account"](/TROUBLESHOOTING.md#create-a-sensu-user-account-service-account).

   **MacOS**

   ```shell
   TMPDIR=/opt/sensu/tmp \
   sudo -E sensu-agent start \
   --name workshop \
   --backend-url ${SENSU_BACKEND_URL} \
   --namespace ${SENSU_NAMESPACE} \
   --subscriptions system/macos,workshop \
   --deregister true \
   --cache-dir /opt/sensu/sensu-agent/cache \
   --user ${SENSU_USER} \
   --password ${SENSU_PASSWORD}
   ```

   **Windows (PowerShell)**

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

   **Linux**

   ```shell
   sudo -E sensu-agent start \
   --name workshop \
   --backend-url ${SENSU_BACKEND_URL} \
   --namespace ${SENSU_NAMESPACE} \
   --subscriptions system/linux,workshop \
   --deregister true \
   --user ${SENSU_USER} \
   --password ${SENSU_PASSWORD}
   ```
   
1. ** Verify that your agent is running.** 

   Verify that your agent is running and connected to the backend:

   ```shell
   sensuctl entity list
   ```

   You should see your machine in the entity list.

**NEXT:** If `sensu-agent` has successfully connected to your backend, you're ready to move on to the next exercise.

## Configuring the Agent

Some agent configuration parameters are used to manage the behavior of the agent, such as TLS certificates, authentication, and subscriptions.
Others are used to configure aspects of the *entity* representation, such as labels and annotations.

For a full list of available configuration values, use the `--help` option:

```shell
sensu-agent start --help
```

### Configuration Priority

The agent can be configured via command-line options, YAML config file, or environment variables.
If a configuration value is set in multiple places, it will be overrided with the following priority:

1. **Command-line Option** (highest)
2. **Environment Variable**
3. **Configuration File**
4. **Default Value** (lowest)

In the next exercise, we will stop our agent and modify its configuration.

### EXERCISE 2: Customize Agent Configuration

#### Scenario

You want to change the behavior or metadata for an agent.

#### Solution

Stop the agent, modify the configuration, then restart the agent.

#### Steps

1. **Stop the Agent.**

   If you started your agent in the previous exercise using the `sensu-agent start` command, you can stop the agent by pressing `Control-C` in your terminal.

   > _**NOTE:**_ Agent configuration is loaded at start time, so the agent must be restarted to update the configuration.

1. **Configure Agent Using YAML.**

   At minimum, the agent requires a backend Websocket URL, and one or more subscriptions.
   We'll also add some agent metadata in the form of labels & annotations.

   Let's start by creating an `agent.yaml` file in one of the following recommended locations:

   - **MacOS:** `/opt/sensu/agent.yaml`
   - **Windows:** `${Env:UserProfile}\Sensu\agent.yaml`
   - **Linux:** `/etc/sensu/agent.yaml`

   Next, copy the following contents into the `agent.yaml` file:

   ```yaml
   ---
   backend_url: ws://127.0.0.1:8080
   name: workshop
   labels:
     foo: bar
     environment: training
   annotations:
     sensu.io/plugins/rockerchat/config/alias: sensu-trainee

   deregister: true
   ```

   Make sure to save the contents of the file before moving on to the next step.

2. **Restart the Agent.**

   Let's start the agent from the command line, this time using a mix of environment variables and our configuration file.

   **MacOS:**

   ```shell
   TMPDIR=/opt/sensu/tmp \
   SENSU_SUBSCRIPTIONS="system/macos workshop" \
   sudo -E sensu-agent start \
   --config-file /opt/sensu/agent.yaml \
   --cache-dir /opt/sensu/sensu-agent/cache \
   --user ${SENSU_USER} \
   --password ${SENSU_PASSWORD}
   ```

   **Windows (PowerShell):**

   ```powershell
   ${Env:SENSU_SUBSCRIPTIONS}="system/windows workshop" `
   sensu-agent start `
   --config-file "${Env:UserProfile}\Sensu\agent.yaml" `
   --user ${Env:SENSU_USER} `
   --password ${Env:SENSU_PASSWORD}
   ```

   **Linux:**

   ```shell
   SENSU_SUBSCRIPTIONS="system/linux workshop" \
   sudo -E -u sensu sensu-agent start \
   --config-file "/etc/sensu/agent.yaml" \
   --user ${SENSU_USER} \
   --password ${SENSU_PASSWORD}
   ```

   Notice that we moved the `--name`, `--backend-url`, and `--deregister` configuration options into `agent.yaml`, and we set the `SENSU_SUBSCRIPTIONS` environment variable in place of `--subscriptions`... but how/where is `--namespace` being set?
   The agent is automatically reading the value of `SENSU_NAMESPACE` from the environment variable.

## Discussion

In this lesson we explored installing and configuring the agent, and you learned how it communicates and authenticates to the backend.

### Multiple Configuration Methods

In the first exercise we passed all of the configuration via `sensu-agent start` command-line options. In the second exercise we moved some configuration to a config file, and other configuration to environment variables.

The ability to configure the agent using multiple methods is very useful in complex environments that may have a mix of servers, compute instances, and containers. However, in practice you may find that just one method is best suited for your environment.

For example, on Kubernetes or other container-based environments it may be easiest to manage all configuration via environment variables.

### Configuration Names and Formats

All of the agent configuration options use consistent naming regardless of the way they are set, differing only in format.

For example, setting the namespace, backend url, and log level in all three formats is as follows:

- **Command-Line Option:**

  Pass the configuration option and the value using the format `--<option_name>=<value>`.
  
  - If the name of the configuration option has multiple words, separated the words with a dash (`-`).
  - For options that can have a list of values, separate the values with commas and no spaces. 
  
  **Example:** Using Command-line Options for Configuration

  ```shell
  sensu-agent start --namespace=default --backend-url=ws://backend-1:8081,ws://backend-2:8081 --log-level=warn
  ```
  
- **YAML Config File:**

  Every configuration option has a corresponding YAML property. 
  
  - If the name of the configuration option has multiple words, separated the words with a dash (`-`).
  - For options that can have a list of values, use the YAML list format.

  **Example (`agent.yaml`):** Using a YAML Config File for Configuration

  ```yaml
  namespace: "default"
  backend-url:
    - "ws://backend-1:8081"
    - "ws://backend-2:8081"
  log-level: "warn"
  ```
  
  To use the config file, pass the name of the config file via the `--config-file` option.  
  
  ```shell
  sensu-agent start --config-file=agent.yaml
  ```

- **Environment Variable:**

  Every configuration option also has a corresponding environment variable.
  - All Sensu environment variable names are prefixed with `SENSU_`, followed by the corresponding option name in capitalized letters.
  - Option values should be enclosed in quotes.
  - If the name of the configuration option has multiple words, separated the words with an underscore (`_`).
  - For options that can have a list of values, separate the values with a space (` `).

  **Example:** Using Environment Variables for Configuration

  ```shell
  SENSU_NAMESPACE="default" SENSU_BACKEND_URL="ws://backend-1:8081 ws://backend-2:8081" SENSU_LOG_LEVEL="warn" sensu-agent start
  ```

### Keepalives

Sensu uses a heartbeat mechanism called "keepalives" to monitor agent connectivity.
Under the hood, a `keepalive` is just another event that the agent publishes once every `--keepalive-interval` configured seconds.
The `keepalive` event contains the agent configuration and entity properties.
If an agent fails to report a `keepalive` event within the `--keepalive-warning-timeout` or `--keepalive-critical-timeout` configured thresholds, a warning or critical event is produced on behalf of the agent.

Keepalive monitoring can be disabled using the `--deregister true` flag, which prompts the backend to remove agent entities that have stopped generating `keepalive` events.

[setup_workshop]: ../02/README.md#readme

## Learn More

- [[Documentation] "Sensu Agent Reference" (docs.sensu.io)](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-schedule/agent/)
- [[Documentation] "Sensu Entity Reference" (docs.sensu.io)](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-entities/entities/)
- [[Documentation] "Sensu Architecture" (docs.sensu.io)](https://docs.sensu.io/sensu-go/latest/operations/deploy-sensu/deployment-architecture/)
- [[Documentation] "Install Sensu Agents" (docs.sensu.io)](https://docs.sensu.io/sensu-go/latest/operations/deploy-sensu/install-sensu/#install-sensu-agents)
- [[Documentation] "Configure Sensu Agent mTLS Authentication" (docs.sensu.io)](https://docs.sensu.io/sensu-go/latest/operations/deploy-sensu/secure-sensu/#configure-sensu-agent-mtls-authentication)
- [[Documentation] "Sensu Subscriptions Reference" (docs.sensu.io)](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-schedule/subscriptions/)

## Next Steps

[Share your feedback on Lesson 07](https://github.com/sensu/sensu-go-workshop/issues/new?template=lesson_feedback.md&labels=feedback%2Clesson-07&title=Lesson%2007%20Feedback)

[Lesson 8: Introduction to Checks](../08/README.md#readme)
