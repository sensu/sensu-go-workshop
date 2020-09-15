# Sensu Go Workshop 

- [Setup](#setup)
  - [Self-guided workshop setup](#self-guided-workshop-setup)
  - [Instructor-led workshop setup](#instructor-led-workshop-setup)
- [References](#references)
  - [Workshop contents](#workshop-contents)
  - [Prerequisites](#prerequisites)
  - [Customization](#customization)
  - [Maintenance & Troubleshooting](#maintenance-troubleshooting)

## Setup

### Self-guided workshop setup

1. **Clone this repository.**

   ```
   $ git clone git@github.com:sensu/sensu-go-workshop.git
   $ cd sensu-go-workshop/
   ```
2. **Docker Compose initialization.** 

   ```
   $ sudo docker-compose up -d
   Creating network "workshop_default" with the default driver
   Creating volume "workshop_sensuctl_data" with local driver
   Creating volume "workshop_sensu_data" with local driver
   Creating volume "workshop_timescaledb_data" with local driver
   Creating volume "workshop_grafana_data" with local driver
   Creating workshop_grafana_1       ... done
   Creating workshop_sensu-agent_1   ... done
   Creating workshop_timescaledb_1   ... done
   Creating workshop_sensuctl_1      ... done
   Creating workshop_sensu-backend_1 ... done
   Creating workshop_configurator_1  ... done
   ```   

   > _NOTE: the first time you run the `docker-compose up` command you will 
   > likely see output related to the pulling and building of the workshop 
   > container images, this process shouldn't take more than 2-3 minutes, 
   > depending on your system._

   > **PROTIP:** To prefetch and/or prebuild the workshop container images 
   > (e.g. for offline use), please run the following commands: 
   > ```
   > $ sudo docker-compose pull && sudo docker-compose build
   > ```

3. **Verify your workshop installation.**

   ```
   $ sudo docker-compose ps 
             Name                        Command                  State                             Ports                       
   -----------------------------------------------------------------------------------------------------------------------------
   workshop_configurator_1    generate_user_rbac               Exit 0
   workshop_grafana_1         /run.sh                          Up (healthy)   0.0.0.0:3001->3000/tcp
   workshop_sensu-agent_1     sensu-agent start --log-le ...   Up (healthy)   0.0.0.0:32830->3031/tcp, 0.0.0.0:32821->8125/udp
   workshop_sensu-backend_1   sensu-backend start --log- ...   Up (healthy)   0.0.0.0:3000->3000/tcp, 0.0.0.0:8080->8080/tcp
   workshop_sensuctl_1        wait-for-sensu-backend sen ...   Exit 0
   workshop_timescaledb_1     docker-entrypoint.sh postgres    Up (healthy)   0.0.0.0:5432->5432/tcp
  ```

  > **NEXT:** if all of the containers show a `Up (healthy)` or `Exit 0` state,
  > then you're ready to start the workshop! 
 
  > _NOTE: every container should show a status of `Up (healthy)` or `Exit 0`; if 
  > any containers have the status `Up` or `Up (health: starting)`, please wait 
  > a few seconds and re-run the `sudo docker-compose ps` command. Otherise, if 
  > any containers have reached the `Exit 1` or `Exit 2` state, it's possible 
  > that these were the result of an intermittent failure (e.g. if the 
  > sensu-backend container was slow to start) and re-running the `sudo 
  > docker-compose up -d` command will resolve the issue._  

### Instructor-led workshop setup

1. **Clone this repository.**

   ```
   $ git clone git@github.com:sensu/sensu-go-workshop.git
   $ cd sensu-go-workshop/
   ```
2. **Customize the Docker Compose environment file (`.env`), as needed.**

   All of the workshop configuration variables have been consolidated into a 
   single configuration file for your convenience. These configuration 
   variables make it easy to use a specific version of Sensu Go (see: 
   `SENSU_BACKEND_VERSION`, `SENSU_AGENT_VERSION`, and `SENSU_CLI_VERSION`), or
   change default passwords, and more. 
   
   Please review [Customization](#customization) for more information.
   
   > **PROTIP:** if you are preparing a workshop environment for an 
   > instructor-led workshop, we recommend changing the Sensu admin username 
   > (`SENSU_CLUSTER_ADMIN_USERNAME`) and admin password 
   > (`SENSU_CLUSTER_ADMIN_PASSWORD`). This will help workshop trainees from 
   > inadvertently access the admin account. 

   > _NOTE: complete this step **BEFORE** you run any `docker-compose` 
   > commands._

3. **Configure workshop user accounts.** 

  This workshop contains various templates and scripts for configuring workshop 
  trainee user accounts (dedicated namespaces and RBAC profiles for each 
  trainee). To automatically generate these profiles, edit the `users/users.json` 
  file **BEFORE** you run any `docker-compose` commands. Two example users 
  are pre-configured, as follows: 

  ```json
  [
    {"username": "example","password": "workshop"},
    {"username": "lizy@sensu.io","password": "workshop"}
  ]
  ``` 

  Modify this file so that there is one row per user. The `users.json` file 
  supports defining `username` and `password` values (in plain text), or a
  `password_hash` (bcrypt-encrypted password hashes). If a `password_hash` 
  _and_ `password` value are provided for the same user, the `password` will 
  be ignored. The Sensu CLI provides a built-in utility for generating valid 
  `password_hash` values, via [the `sensuctl user password-hash` command][9].

4. **Docker Compose initialization.** 

   ```
   $ sudo docker-compose up -d
   Creating network "workshop_default" with the default driver
   Creating volume "workshop_sensuctl_data" with local driver
   Creating volume "workshop_sensu_data" with local driver
   Creating volume "workshop_timescaledb_data" with local driver
   Creating volume "workshop_grafana_data" with local driver
   Creating workshop_grafana_1       ... done
   Creating workshop_sensu-agent_1   ... done
   Creating workshop_timescaledb_1   ... done
   Creating workshop_sensuctl_1      ... done
   Creating workshop_sensu-backend_1 ... done
   Creating workshop_configurator_1  ... done
   ```   

   > _NOTE: the first time you run the `docker-compose up` command you will 
   > likely see output related to the pulling and building of the workshop 
   > container images, this process shouldn't take more than 2-3 minutes, 
   > depending on your system._

   > **PROTIP:** To prefetch and/or prebuild the workshop container images 
   > (e.g. for offline use), please run the following commands: 
   > ```
   > $ sudo docker-compose pull && sudo docker-compose build
   > ```

3. **Verify your workshop installation.**

   ```
   $ sudo docker-compose ps 
             Name                        Command                  State                             Ports                       
   -----------------------------------------------------------------------------------------------------------------------------
   workshop_configurator_1    generate_user_rbac               Exit 0
   workshop_grafana_1         /run.sh                          Up (healthy)   0.0.0.0:3001->3000/tcp
   workshop_sensu-agent_1     sensu-agent start --log-le ...   Up (healthy)   0.0.0.0:32830->3031/tcp, 0.0.0.0:32821->8125/udp
   workshop_sensu-backend_1   sensu-backend start --log- ...   Up (healthy)   0.0.0.0:3000->3000/tcp, 0.0.0.0:8080->8080/tcp
   workshop_sensuctl_1        wait-for-sensu-backend sen ...   Exit 0
   workshop_timescaledb_1     docker-entrypoint.sh postgres    Up (healthy)   0.0.0.0:5432->5432/tcp
  ```

  > **NEXT:** if all of the containers show a `Up (healthy)` or `Exit 0` state,
  > then you're ready to start the workshop! 
 
  > _NOTE: every container should show a status of `Up (healthy)` or `Exit 0`; if 
  > any containers have the status `Up` or `Up (health: starting)`, please wait 
  > a few seconds and re-run the `sudo docker-compose ps` command. Otherise, if 
  > any containers have reached the `Exit 1` or `Exit 2` state, it's possible 
  > that these were the result of an intermittent failure (e.g. if the 
  > sensu-backend container was slow to start) and re-running the `sudo 
  > docker-compose up -d` command will resolve the issue._  

5. **Create workshop trainee user accounts.**

   Use the workshop configurator Docker container to execute the user account 
   creation script, as follows: 
      
   ```
   $ sudo docker-compose run --rm configurator create_user_accounts 
   Successfully created the following workshop user accounts:
   
      Name    
    ───────── 
     default  
     example  
     lizy    
   ```

   > **NEXT:** you're ready to start the workshop! 

   > _NOTE: if you add additional users to `users/users.json` after you execute
   > this script you'll need to repeat this step._

## References 

### Workshop contents

1. A Docker Compose environment file for customizing the workshop environment

2. A `docker-compose.yaml` for provisioning a simple Sensu Go workshop 
   environment, including:
   
   - A Sensu Go backend, API, and dashboard (`sensu-backend`)
   - A Sensu Go agent (`sensu-agent`)
   - A telemetry stack, including: 
     - TimescaleDB for storage
     - Grafana for visualization
   
   Coming soon: 
   
   - Deployment templates for [AWS Fargate][fargate]
   - Deployment templates for [Heroku][heroku]
   - Alternate reference architectures (e.g. Elasticsearch or Splunk for 
     metric storage instead of Timescale)   

3. Configuration files for TimescaleDB and Grafana 

4. Dockerfiles templates for building custom Sensu Docker images

5. Sensu resource templates for configuring an example pipeline

### Prerequisites

1. **Docker + Docker Compose**

   You'll need a working Docker environment with Docker Compose to run this 
   demo. MacOS users will need [Docker CE Desktop for Mac][1], Windows users 
   will need [Docker CE Desktop for Windows][2]. Linux users can find 
   installation instructions from the [Docker CE installation guide][3].
   
   _NOTE: in a workshop hosted by an instructor with a shared Sensu deployment,
   only the instructor needs a Docker host. Self-guided trainees can deploy the
   workshop environment on their workstations, though they may find it 
   advantageous to deploy._ 


### Customization 

Please note the following configuration parameters: 
   
- `COMPOSE_PROJECT_NAME`  
  
  The Docker resource prefix for all resources managed by Docker Compose.

- `COMPOSE_FILE`  

  The Docker Compose template to use; defaults to `docker-compose-default.yaml`. 
     
- `SENSU_BACKEND_VERSION`  
   
  The Sensu backend version to use. This should be kept in sync with 
  `SENSU_AGENT_VERSION` and `SENSU_CLI_VERSION`. 
     
- `SENSU_BACKEND_CLUSTER_ADMIN_USERNAME`  
  
  The Sensu Go cluster admin username. _NOTE: if you're a long-time Sensu Go
  user you may recall that the default cluster admin username was `admin`; 
  since version 5.16.0 the default cluster admin user has been removed and 
  must now be provided via a new [`sensu-backend init` command][4]._
     
- `SENSU_BACKEND_CLUSTER_ADMIN_PASSWORD`  
  
  The Sensu Go cluster admin password. _NOTE: if you're a long-time Sensu Go
  user you may recall that the default cluster admin password was 
  `P@ssw0rd!`; since version 5.16.0 the default cluster admin password has 
  been removed and must now be provided via the [`sensu-backend init` 
  command][4]._
     
- `SENSU_TIMESCALEDB_DSN`  
  
  The TimescaleDB Postgres database Data Source Name (DSN). 
     
- `SENSU_CLI_VERSION`  
  
  The Sensu CLI (`sensuctl`) version to use. This should be kept in sync 
  with `SENSU_BACKEND_VERSION` and `SENSU_AGENT_VERSION`. 

- `SENSU_CONFIG_DIR`  
  
  The `sensuctl` configuration directory to use. This environment variable
  is not yet supported by `sensuctl`, but may be in a future release. In the
  interim, setting this variable is useful in the context of custom 
  `sensuctl` wrapper scripts (see `/scripts/sensuctl`) or for passing on the
  command line (e.g. `sensuctl --config-dir $SENSU_CONFIG_DIR`). 
     
- `SENSU_AGENT_VERSION`  
  
  The Sensu Agent version to use. This should be kept in sync with 
  `SENSU_BACKEND_VERSION` and `SENSU_CLI_VERSION`. 

- `SENSU_BACKEND_URL`  
  
  The Sensu Backend DNS used by Sensu Agents running in the Docker Compose 
  environment (default: `ws://sensu-backend:8081`). This should not need to 
  be changed unless you're modifying the Docker Compose template. 

- `SENSU_NAMESPACE`  
  
  The Sensu namespace used by Sensu Agents running in the Docker Compose 
  environment (default: `default`). This variable can be overriden when 
  spawning additional agents; e.g.: 
     
  ```
  $ sudo docker-compose run --rm -e "SENSU_NAMESPACE=us-west-1" sensu-agent
  ```

- `SENSU_SUBSCRIPTIONS`  
  
  The default subscriptions used by Sensu Agents running in the Docker Compose 
  environment (default: `linux,workshop,devel`). 
     
- `PROM_PROMETHEUS_VERSION`  
   
  The Prometheus Docker image version to use in the workshop environment 
  (default: `v2.20.0`). 
   
- `PROM_PUSHGATEWAY_VERSION`
   
  The Prometheus Pushgateway Docker image version to use in the workshop 
  environment (default: `v1.2.0`). 
   
- `TIMESCALEDB_VERSION`  
  
  The TimescaleDB Docker image version to use in the workshop environment 
  (default: `1.7.2-pg12`). 

- `POSTGRES_PASSWORD`  
  
  The TimescaleDB Postgres database password (for the default `postgres` 
  user). 
   
- `POSTGRES_DB`  
  
  The TimescaleDB Postgres database to connect to. If omitted, the default 
  database will be `postgres`. If provided and no such database exists, it 
  will be created. 
     
- `GRAFANA_VERSION`  
   
  The Grafana Docker image version to use in the workshop (default: `7.0.0`).

## Maintenance & Troubleshooting 

### Adding Sensu RBAC resources 

This workshop includes some example Role Based Access Control (RBAC) resources 
that may be useful for instructors who wish to prepare a shared (multi-tenant) 
workshop environment for multiple trainees. These resources include namespaces,
roles & cluster roles, role-bindings & cluster-role-bindings, and "basic auth" 
user accounts. To learn more about RBAC in Sensu Go, please visit the 
[RBAC reference documentation][7].

In organizations where an SSO provider is available, we recommend configuring 
Sensu for single sign-on (supports LDAP, Active Directory, OAuth, and OIDC). To
learn more about SSO for Sensu Go, please visit the [authentication provider 
documentation][8]. 

### Scale one of the workshop services 

1. **Add more Sensu Agent containers.**

   ```
   $ sudo docker-compose up -d --scale sensu-agent=3
   workshop_sensu-backend_1 is up-to-date
   Starting workshop_sensu-agent_1 ... done
   Creating workshop_sensu-agent_2 ... done
   Creating workshop_sensu-agent_3 ... done
   workshop_timescaledb-server_1 is up-to-date
   workshop_grafana-server_1 is up-to-date
   ```

### Reset the workshop environment 

1. **Stop all containers, remove all networks and volumes.**

   ```
   $ sudo docker-compose down -v
   Stopping workshop_grafana-server_1 ... done
   Stopping workshop_sensu-agent_1    ... done
   Stopping workshop_sensu-backend_1  ... done
   Removing workshop_grafana-server_1     ... done
   Removing workshop_timescaledb-server_1 ... done
   Removing workshop_sensu-agent_1        ... done
   Removing workshop_sensu-backend_1      ... done
   Removing network workshop_default
   Removing volume workshop_sensu_data
   Removing volume workshop_timescaledb_data
   Removing volume workshop_grafana_data   
   ```

### Inspect the contents of a Docker Volume 

1. **Inspect the Docker `volume` resource.**  

   ```
   $ sudo docker volume inspect workshop_timescaledb_data
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

   The "Mountpoint" field indicates the subdirectory where you can find the 
   contents of the volume. 
   
   If you have `jq` installed, the following commands may be useful: 
   
   ```
   $ sudo docker volume inspect workshop_timescaledb_data | jq -r .[].Mountpoint
   "/var/lib/docker/volumes/workshop_timescaledb_data/_data"
   ```
   
   For example, to list the contents of a volume: 
   
   ```
   $ sudo ls $(sudo docker volume inspect workshop_timescaledb_data | jq -r .[].Mountpoint)
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
