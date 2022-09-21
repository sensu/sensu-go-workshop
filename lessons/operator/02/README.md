# Lesson 2: Setup the Workshop Environment

- [Goals](#goals)
- [Prerequisites](#prerequisites)
- [The Workshop Environment](#the-workshop-environment)
- [How It All Works Together](#how-it-all-works-together)
- [EXERCISE 1: Install the Workshop](#exercise-1-install-the-workshop)
- [Discussion](#discussion)
- [Learn More](#learn-more)
- [Next Steps](#next-steps)

## Goals

In this lesson we will setup a local Sensu development environment for use during the workshop.
This lesson is intended for operators of Sensu or anyone who would like to explore Sensu from a technical perspective.

## Watch Lesson 2 on YouTube

[![Sensu Go Workshop Lesson 2 Video](img/SensuGoWorkshopYouTubeLesson1.png "Sensu Go Workshop Lesson 2 Video")](https://www.youtube.com/watch?v=X6RFqOhfMQ8)

## Prerequisites

This workshop was designed with common IT/DevOps/SRE tooling in mind, so we expect most users will already have everything they need installed.
All you need to get started is a laptop or workstation with a `git` client, [Docker](https://www.docker.com/), text editor, and a modern web browser.

Please review this list of prerequisites to make sure your system is ready to go:

1. **Workstation**

   Workshop users will need a 64-bit workstation running a recent version of **macOS, Windows, or Linux**.

1. **Docker**
   - Mac users should install [Docker CE Desktop for Mac](https://hub.docker.com/editions/community/docker-ce-desktop-mac).
   - Windows users should install [Docker CE Desktop for Windows](https://hub.docker.com/editions/community/docker-ce-desktop-windows).
   - Linux users should follow the [Docker Engine installation guide](https://docs.docker.com/engine/install/).

1. **Docker Compose (`docker-compose`)**

   To install `docker-compose`, please read the ["Install Docker Compose"](https://docs.docker.com/compose/install/) documentation.

1. **Git Client (`git`)**

   To install `git`, please read the [`git` downloads](https://git-scm.com/downloads) page.

1. **Supported Web Browser**

   The workshop expects that you have a modern web browser installed.
   Please verify that you have a recent version of one of these common browsers:
   - [Chrome](https://www.google.com/chrome/fast-and-secure/)
   - [Safari](https://support.apple.com/en-us/HT204416)
   - [Firefox](https://www.mozilla.org/en-US/firefox/new/)
   - [Microsoft Edge](https://www.microsoft.com/en-us/edge)

1. **Compatible Text Editor**

   This workshop involves creating and editing plain-text configuration files and monitoring code templates.
   We suggest using a text editor such as:
   - [Microsoft Visual Studio Code](https://visualstudio.microsoft.com)
   - [Atom](https://atom.io)
   - [Sublime Text](https://www.sublimetext.com)
   - [`vim`](https://www.vim.org/download.php)
   - [`emacs`](https://www.gnu.org/software/emacs/download.html)

   _NOTE: Windows users should avoid using `Notepad.exe` which can save edited files in incompatible encodings._

1. **Optional CLI Tools**

   The workshop includes examples using some optional CLI utilties:
   - `jq` ([website](https://stedolan.github.io/jq/), [downloads](https://stedolan.github.io/jq/download/))


## The Workshop Environment

To fully demonstrate Sensu's capabilities, it is necessary to have a multi-node environment.
This workshop includes a set of containerized components that represent a simplified Sensu-enabled monitoring environment.

![](img/architecture.png)

### The Docker Configuration

We are using `docker-compose` to automate setting up the local workshop environment.
The containers are configured by a variety of environment variables, defined in the `.env` file included in the [workshop repo](https://github.com/sensu/sensu-go-workshop).


The `docker-compose-default.yaml` defines the configuration of the following containers:

   - Sensu components:
     - `sensu-backend`: A [Sensu backend](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-schedule/backend/), [API](https://docs.sensu.io/sensu-go/latest/api/), and [dashboard](https://docs.sensu.io/sensu-go/latest/web-ui/)
     - `sensu-agent`: A Sensu [agent](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-schedule/agent/) node
   - A chat-ops environment, for alerting:
     - `mattermost`: [Mattermost](https://mattermost.com), a web-based chat app similar to Slack
   - A telemetry stack:
     - `influxdb`: [InfluxDB](https://www.influxdata.com/) for metrics storage
     - `grafana`: [Grafana](https://grafana.com/) for visualization
   - Some support utilites:
     - `vault`: A [HashiCorp Vault](https://www.vaultproject.io/) server, for secrets management
     - `configurator`: A simple configuration management tool built for this workshop

## How It All Works Together

The basic flow of information in this environment looks something like this:
- The _agent_ container simulates an application server, with the Sensu agent running on it.
- The agent observes the application and generates _events_, which are sent to the _backend_ container.
- The backend will make decisions about the _event_ based on the user defined configuration.

Depending on the configuration, and the details of the event, the backend may raise _alerts_ which are sent to _Mattermost_, or send _events_ containing _metrics_ to _InfluxDb_ to be recorded. The _Grafana_ dashboard visualizes the metrics stored in InfluxDB.

Access to these third-party services requires authentication.
Secrets are securely delivered through _HashiCorp Vault_ directly to the backend.

The _configurator_ runs only during the initial setup of the workshop, to wire everything together and apply the configuration.

## EXERCISE 1: Install the Workshop
### Scenario

You are new to Sensu and are using the Sensu Workshop.
You want to mimic a production Sensu environment, so that you can experiment with Sensu concepts and workflows.

### Solution

To accomplish this, we will setup a local sandbox environment using `docker-compose`.
Each component will be created within a container running on your local machine.
The installation and configuration is automated for you, so you can start using Sensu right away.

### Steps
> **BEFORE YOU START:** Make sure that you've looked over all the [prerequisites](#prerequisites), and that Docker is running.

1. **Clone the Workshop Repository.**

   ```shell
   git clone https://github.com/sensu/sensu-go-workshop.git
   cd sensu-go-workshop
   ```

1. **Docker Compose Initialization.**

   Create the workshop environment with the `docker-compose up` command.

   **Mac and Linux**:

   ```shell
   sudo docker-compose up -d
   ```

   **Windows**:
   ```shell
   docker-compose up -d
   ```

   > **NOTE:** On Linux/macOS `sudo` is required because Docker runs as root.
   > If you'd like to configure Docker to not need `sudo`, read the [Manage Docker as a non-root user](https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user) documentation.

   **Example Output:**

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

   > **NOTE:** The first time you run the `docker-compose up` command you will likely see output related to the pulling and building of the workshop container images.
   > This process shouldn't take more than 2-3 minutes, depending on your system.

1. **Verify Your Workshop Installation.**

   1. **Verify the Docker Containers are Running.**

      ```shell
      sudo docker-compose ps
      ```

      The output should indicate that all of the services are `Up (healthy)` or "completed" (`Exit 0`).

      **Example Output:**

      ```shell
                   Name                        Command                       State                                                         Ports
      --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      workshop_configurator_1    seed-workshop-resources          Exit 0
      workshop_grafana_1         /run.sh                          Up (healthy)            0.0.0.0:3001->3000/tcp
      workshop_influxdb_1        /entrypoint.sh influxd           Up (healthy)            0.0.0.0:8086->8086/tcp
      workshop_sensu-agent_1     sensu-agent start --log-le ...   Up (healthy)            2379/tcp, 2380/tcp, 3000/tcp, 0.0.0.0:49221->3031/tcp, 8080/tcp, 8081/tcp, 0.0.0.0:49220->8125/udp
      workshop_sensu-backend_1   sensu-backend start --log- ...   Up (healthy)            2379/tcp, 2380/tcp, 0.0.0.0:3000->3000/tcp, 0.0.0.0:8080->8080/tcp, 0.0.0.0:8081->8081/tcp
      workshop_sensuctl_1        wait-for-sensu-backend sen ...   Exit 0
      workshop_vault_1           docker-entrypoint.sh vault ...   Up (healthy)            0.0.0.0:8200->8200/tcp
      ```

      Every container should show a status of `Up (healthy)` or `Exit 0`.

      If any containers have the status `Up` or `Up (health: starting)`, wait a few seconds then retry the `sudo docker-compose ps` command.

      > **TROUBLESHOOTING:**
      >
      > If any containers have completed with the `Exit 1` or `Exit 2` state, it's possible that these were the result of an intermittent failure (e.g. if the `sensu-backend` container was slow to start). Re-running the `sudo docker-compose up -d` command will likely resolve the issue.

   1. **Check that the Sensu Web UI is Running**

      The Sensu Web UI should be available at [http://127.0.0.1:3000](http://127.0.0.1:3000).
      Login with the user `sensu` and password `sensu`.

   1. **Check that Mattermost is Running**

      The Mattermost app should be available at [http://127.0.0.1:5000](http://127.0.0.1:5000/).
      Login with the user `sensu` and password `sensu`.

1. **Configure Environment Variables.** <a name="configure-environment-variables"></a>

   The [workshop repository](https://github.com/sensu/sensu-go-workshop) includes platform-specific files that export some environment variables which we will use throughout the workshop.
   The exercises assume you are in a shell that has these variables configured.

   When you open a new shell environment, export the variables using one of the following commands:

   **Mac and Linux:**

   ```shell
   source .envrc
   ```

   **Windows (PowerShell):**

   ```powershell
   . .\.envrc.ps1
   ```

1. **Verify Your Environment.**

   The Sensu-specific environment variables are prefixed with `SENSU`. You can verify that you have the Sensu environment variables set up correctly by running one of these commands:

   **Mac and Linux:**

   ```shell
   env | grep SENSU
   ```

   **Windows (Powershell):**

   ```powershell
   Get-ChildItem env: | Out-String -Stream | Select-String -Pattern SENSU
   ```

   The output should include a value for `SENSU_VERSION` (i.e. a release version such as `6.2.7`).

   **Example Output:**

   ```shell
   SENSU_VERSION=6.2.7
   SENSU_BUILD=4449
   SENSU_BACKEND_HOST=127.0.0.1
   SENSU_NAMESPACE=default
   SENSU_USER=sensu
   SENSU_PASSWORD=sensu
   SENSU_BACKEND_URL=ws://127.0.0.1:8081
   SENSU_API_URL=http://127.0.0.1:8080
   ```


**NEXT:** If all the containers show as `Up (healthy)` or `Exit 0` state, and you can reach the [Sensu Web UI](http://127.0.0.1:3000) and [Mattermost](http://127.0.0.1:5000) apps, and your environment variables are all set, then you're ready to start the workshop!

## Discussion

In this lesson you installed a local sandbox environment, and verified that it was up and running.
You learned about the various components of a Sensu-enabled monitoring environment and how they work together.

In the following lessons, we will install the `sensuctl` command-line tool, and learn how to do some essential tasks via hands-on exercises using this environment.

### Troubleshooting Guide

Most users have no problems setting up and running the workshop, but sometimes issues do come up.
We've collected a short [Troubleshooting Guide](https://github.com/sensu/sensu-go-workshop/blob/latest/TROUBLESHOOTING.md) with answers to the most common issues.

If you can't find your answer there, please reach out by [filing a GitHub Issue](https://github.com/sensu/sensu-go-workshop/issues) or asking a question in the [Sensu Discourse Forum](https://discourse.sensu.io/).

#### Need to Stop the Workshop Environment and Resume Later?

No problem! The workshop can be stopped without losing your progress by running the following command:

**Mac and Linux Users:**

```
sudo docker-compose down
```

**Windows Users (PowerShell):**

```
docker-compose down
```

> _**NOTE:** Running `docker-compose down` with the `-v` flag instructs Docker to also remove the container volumes, which will reset the workshop's saved information. This is helpful if you want to start over completely._

When you're ready to start again, just run `docker-compose up -d` again.

#### Viewing Docker Processes and Logs

If you're running into problems, or just curious, you can view the running containers with `docker-compose ps`.
You can view the log output for any container with `docker-compose logs <container_name>`.

1. Check that Docker containers are running:

   **All Platforms:**
   ```shell
   docker-compose ps
   ```

1. View logs for `sensu-backend` container.

   **All Platforms:**
   ```shell
   docker-compose logs sensu-backend
   ```

#### Double Check Your Environment

It's common for trainees to do a few exercises in the workshop, pause, and then come back to it later.
If you do that, you might need to restart Docker or reload some exported environment variables into your shell.

If something's not working right, the first thing to check is that Docker and the workshop containers are running, and that you have the expected environment variables set.

2. Check environment variables:

   **Mac and Linux:**
   ```shell
   env | grep SENSU
   ```

   **Windows (PowerShell):**
   ```shell
   Get-ChildItem env: | Out-String -Stream | Select-String -Pattern SENSU
   ```

### The Workshop Repository

Feel free to have a look around the [`sensu-go-workshop` GitHub repository](https://github.com/sensu/sensu-go-workshop).
You can find the [Docker configuration files](https://github.com/sensu/sensu-go-workshop/blob/latest/docker-compose-default.yaml) used to setup this sandbox, all the [lessons in Markdown format](https://github.com/sensu/sensu-go-workshop/tree/latest/lessons/operator), and much more.

We are constantly evolving the workshop, so you may run across some interesting work-in-progress modules.
As usual, we welcome contributions of all kinds!

## Learn More

- [[Documentation] "Sensu Go Documentation" (sensu.io)](https://docs.sensu.io/sensu-go/latest/)
- [[Repository] "Sensu Go Workshop Repository" (github.com)](https://github.com/sensu/sensu-go-workshop)
- [[Discussion Forum] "Sensu Discourse Forum" (sensu.io)](https://discourse.sensu.io/)
- [[Documentation] "Workshop Troubleshooting Guide" (github.com)](https://github.com/sensu/sensu-go-workshop/blob/latest/TROUBLESHOOTING.md)
- [[Documentation] "Docker Compose" (docker.com)](https://docs.docker.com/compose/)
- [[Documentation] "HashiCorp Vault Documentation" (vaultproject.io)](https://www.vaultproject.io/docs)
- [[Documentation] "Mattermost Documentation" (docs.mattermost.com)](https://docs.mattermost.com)
- [[Documentation] "InfluxDB Documentation" (influxdata.com)](https://docs.influxdata.com/influxdb/v2.0/)

## Next Steps

[Share your feedback on Lesson 02](https://github.com/sensu/sensu-go-workshop/issues/new?template=lesson_feedback.md&labels=feedback%2Clesson-02&title=Lesson%2002%20Feedback)

[Lesson 3: Using the Sensu CLI](../03/README.md#readme)
