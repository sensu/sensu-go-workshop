# Sensu Go Workshop 

## Workshop contents

1. A Docker Compose environment file for customizing the workshop environment
1. A `docker-compose.yaml` for provisioning a simple Sensu Go workshop 
   environment, including:
   - A Sensu Go backend, API, and dashboard (`sensu-backend`)
   - A Sensu Go agent (`sensu-agent`)
   - A telemetry stack, including: 
     - TimescaleDB for storage
     - Grafana for visualization
2. Configuration files for TimescaleDB and Grafana 
3. Dockerfiles templates for building custom Sensu Docker images
4. Sensu resource templates for configuring an example pipeline

## Prerequisites

1. **Docker + Docker Compose**

   You'll need a working Docker environment with Docker Compose to run this 
   demo. MacOS users will need [Docker CE Desktop for Mac][1], Windows users 
   will need [Docker CE Desktop for Windows][2]. Linux users can find 
   installation instructions from the [Docker CE installation guide][3].
   
   _NOTE: in a workshop hosted by an instructor with a shared Sensu deployment,
   only the instructor needs a Docker host. Self-guided trainees can deploy the
   workshop environment on their workstations, though they may find it 
   advantageous to deploy._ 

## Setup

1. Review and optionally edit the Docker Compose environment file. 

   Please note the following configuration parameters: 
   
   - `COMPOSE_PROJECT_NAME`  
     The Docker resource prefix for all resources managed by Docker Compose.
     
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
     
   - `POSTGRES_PASSWORD`  
     The TimescaleDB Postgres database password (for the default `postgres` 
     user). 
   
   - `POSTGRES_DB`  
     The TimescaleDB Postgres database to connect to. If omitted, the default 
     database will be `postgres`. If provided and no such database exists, it 
     will be created. 

1. Clone this repository

   ```
   $ git clone git@github.com:calebhailey/sensu-go-workshop.git
   $ cd sensu-go-workshop/
   ```
     
2. Bootstrap our Sensu Go environment!

   ```
   $ sudo docker-compose -f docker-compose.yaml up -d
   Creating network "workshop_default" with the default driver
   Creating volume "workshop_sensu_data" with local driver
   Creating volume "workshop_timescaledb_data" with local driver
   Creating volume "workshop_grafana_data" with local driver
   Creating workshop_sensu-backend_1 ... done
   Creating workshop_sensu-agent_1   ... done
   Creating workshop_timescaledb-server_1 ... done
   Creating workshop_grafana-server_1     ... done
   ```

   _NOTE: you may see some `docker pull` and `docker build` output on your first
   run as Docker pulls down our base images and builds a few custom images._

   Once `docker-compose` is done standing up our systems we should be able to
   login to the Sensu Go dashboard! If you have deployed the workshop 
   environment on your local machine, visit http://localhost:3000/, otherwise 
   use the corresponding IP address for your Docker host in place of 
   "localhost".

   _NOTE: you may login to the dashboard using the username and password
   provided in the `.env` file._

3. Install and configure a local `sensuctl` (the new Sensu Go CLI)

   Mac users:

   ```
   $ curl -LO https://s3-us-west-2.amazonaws.com/sensu.io/sensu-go/5.15.0/sensu-go_5.15.0_darwin_amd64.tar.gz
   $ sudo tar -xzf sensu-go_5.15.0_darwin_amd64.tar.gz -C /usr/local/bin/
   ```

   Linux and Windows users can find [installation instructions][5] in the Sensu
   [user documentation][6]. The complete list of Sensu downloads is available at
   https://sensu.io/downloads

4. [OPTIONAL] Create RBAC resources

   ```
   $ sensuctl create -r -f users/
   ```
   
   _NOTE: this step is not required for self-guided trainees. Instructors may 
   wish to copy the `example.yaml` template for as many trainees as they wish 
   to create sandboxed training environments for (i.e. dedicated Sensu Go 
   Namespaces); see [Adding Sensu RBAC resources][rbac] for more information._

[rbac]: #adding-sensu-rbac-resources

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

1. **Create local user accounts w/ dedicated namespaces.**  
   To create local user accounts, copy the example.yaml template and replace 
   the name `lizy` with the desired username. Then run the following command: 
   
   ```
   $ sensuctl create -r -f users/
   ```

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

