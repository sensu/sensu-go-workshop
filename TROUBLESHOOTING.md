# Troubleshooting

- [Scale one of the workshop services](#scale-one-of-the-workshop-services)
- [Reset the workshop environment](#reset-the-workshop-environment)
- [Inspect the contents of a Docker volume](#inspect-the-contents-of-a-docker-volume)
- [Error executing `git` commands on MacOS (Developer Tools)](#error-executing-git-commands-on-macos-developer-tools)
- [Deploying the workshop using `docker-compose` without `sudo`](#sudo-less-docker-compose)
- [Certain `sensuctl` commands produce authorization errors](#certain-sensuctl-commands-produce-authorization-errors)
- [The sensu-agent reports various "permission denied" errors](#the-sensu-agent-reports-various-permission-denied-errors)
- [Unknown user `sensu` or `_sensu` when starting Sensu Agent](#unknown-user-sensu-or-_sensu-when-starting-sensu-agent)
- [Create a Sensu user account (service account)](#create-a-sensu-user-account-service-account)
- [Encountering "command not found" errors when running `sensu-agent` on MacOS](#encountering-command-not-found-errors-when-running-sensu-agent-on-macos)
- [How to access Sensu Agent logs when starting the agent via systemd](#how-to-access-sensu-agent-logs-when-starting-the-agent-via-systemd)
- [Help installing a Sensu Agent](#help-installing-a-sensu-agent)
- [Copy files into running containers](#copy-files-into-running-containers)
- [Delete trainee namespaces](#delete-trainee-namespaces)
- [Unable to execute Powershell scripts on a Windows workstation](#unable-to-execute-powershell-scripts-on-a-windows-workstation)

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

## Error executing `git` commands on MacOS (Developer Tools)

On MacOS systems that don't have [Apple's Developer Tools (XCode) package](https://apps.apple.com/us/app/xcode/id497799835?mt=12) installed may encounter an error like the following when trying to execute various `git` commands:

```
xcode-select: note: no developer tools were found at '/Applications/Xcode.app', requesting install. Choose an option in the dialog to download the command line developer tools.
```

```shell
curl -L https://github.com/sensu/sensu-go-workshop/archive/latest.zip -o sensu-go-workshop.zip
unzip sensu-go-workshop.zip
mv sensu-go-workshop-latest sensu-go-workshop
cd sensu-go-workshop
```

## Deploying the workshop using `docker-compose` without `sudo`

The Sensu Go Workshop `docker-compose` templates are designed to be customized using environment variables.
Some of these environment variables are read from an "environment file" (`.env`), while others are read from the local shell environment.
Care has been taken to avoid conflicts between the environment file and the local shell environment, however there are a few situations when these conflicts will cause issues which can be difficult to troubleshoot.
The most common conflict typically arises when deploying the workshop without `sudo` (e.g. if your Docker configuration does not require `sudo`), and the most common evidence of this is when the `workshop_sensuctl_` container reaches the `Exit 1` status during the initial deployment (see below).

```shell
          Name                        Command                       State                               Ports
----------------------------------------------------------------------------------------------------------------------------------
workshop_artifactory_1     /entrypoint-artifactory.sh       Up (healthy)            0.0.0.0:8881->8081/tcp, 0.0.0.0:8882->8082/tcp
workshop_configurator_1    generate_user_rbac               Exit 0
workshop_grafana_1         /run.sh                          Up (healthy)            0.0.0.0:3001->3000/tcp
workshop_sensu-agent_1     sensu-agent start --log-le ...   Up (health: starting)   2379/tcp, 2380/tcp, 3000/tcp,
                                                                                    0.0.0.0:49162->3031/tcp, 8080/tcp, 8081/tcp,
                                                                                    0.0.0.0:49162->8125/udp
workshop_sensu-backend_1   sensu-backend start --log- ...   Up (healthy)            2379/tcp, 2380/tcp, 0.0.0.0:3000->3000/tcp,
                                                                                    0.0.0.0:8080->8080/tcp, 0.0.0.0:8081->8081/tcp
workshop_sensuctl_1        wait-for-sensu-backend sen ...   Exit 1
workshop_timescaledb_1     docker-entrypoint.sh postgres    Up (healthy)            0.0.0.0:5432->5432/tcp
workshop_vault_1           docker-entrypoint.sh vault ...   Up (healthy)            0.0.0.0:8200->8200/tcp
```

If you see `Exit 1`, try running these commands and compare the output:

```
env | grep SENSU
sudo env | grep SENSU
```

The output will likely look similar to the following (`sudo env | grep SENSU` reveals that the root shell does not have any `SENSU_` environment variables set):

```shell
$ env | grep SENSU
SENSU_API_URL=http://127.0.0.1:8080
SENSU_NAMESPACE=default
SENSU_VERSION=6.2.7
SENSU_BACKEND_HOST=127.0.0.1
SENSU_PASSWORD=sensu
SENSU_BUILD=4449
SENSU_USER=sensu
SENSU_BACKEND_URL=ws://127.0.0.1:8081
$ sudo env | grep SENSU
$
```

This can happen if the `SENSU_API_URL` environment variable has been set in the local shell, and the workshop environment is deployed without `sudo` (i.e. `docker-compose up -d`).
With `sudo`, the local shell environment variables are not passed through (unless the `sudo -E` flag is used); but without `sudo` the local shell value for `SENSU_API_URL` is used instead of the default value (`http://sensu-backend:8080`).

To resolve this issue, redeploy the workshop environment using `sudo`, or explicitly set `SENSU_API_URL` to the correct value.

## Certain `sensuctl` commands produce authorization errors

Trainees may occassional encounter errors with messages like "Error putting resource..." and "unauthorized to perform action".
These messages are typically the result of Sensu's role-based access controls (RBAC) working as intended and informing users that they do not have the correct permissions.
In the sensu-go-workshop environment, the most common reason for these errors is a misconfiguration of `sensuctl`.

Sensu Go is a multi-tenant platform (multi-user, and multi-org), so a user may be authorized to perform a given action in one context, but unauthorized to perform the same action in another context.
The most common `sensuctl` functions (e.g. `sensuctl event list`) are designed to interact with namespaced resources; if no namespace is explicitly provided (e.g. `sensuctl event list --namespace default`) then `sensuctl` will use the currently configured namespace.

To view the current `sensuctl` configuration, run the following command:

```shell
sensuctl config view
```

It should output the following information:

```
=== Active Configuration
API URL:                  http://127.0.0.1:8080
Namespace:                default
Format:                   tabular
Timeout:                  15s
Username:                 trainee
JWT Expiration Timestamp: 1615511071
```

In the example above the `trainee` user has read-only permissions to the "default" namespace, so any attempts to create or update resources with commands like `sensuctl create -f` without the `--namespace trainee` flag will use the configure namespace (i.e. "default") and result in authorization errors.

To update the current configuration, please run the following command:

```
sensuctl config set-namespace trainee
```

## The sensu-agent reports various "permission denied" errors

If you have run the `sensu-agent` as the `root` user, or other user with elevated privileges, and then attempt to start the `sensu-agent` process via service management or using a service account, you may encounter various "permission denied" errors (e.g. "error creating agent: could not open api queue").
The officially supported Sensu Agent installation packages (e.g. `.rpm` and `.deb` packages) will install and run all Sensu services as the `sensu` user (i.e. not `root`).
To ensure that the `sensu` users owns all of the files needed to run the Sensu Agent, run the following commands:

**Mac users:**

```
sudo chown -R _sensu:_sensu /opt/sensu
```

**Linux users:**

```shell
sudo chown -R sensu:sensu /etc/sensu
sudo chown -R sensu:sensu /var/lib/sensu
sudo chown -R sensu:sensu /var/cache/sensu
```

This should resolve any outstanding permissions errors.

## Unknown user `sensu` or `_sensu` when starting Sensu Agent

This workshop encourages Linux and MacOS users to run the `sensu-agent` with an unpriveleged service account (e.g. `sensu` or `_sensu`).
Executing commands like `sudo -u _sensu sensu-agent-start...` may result in errors like the following:

```shell
sudo: unknown user: _sensu
```

To resolve this issue, please [Create a Sensu user account (service account)](#create-a-sensu-user-account-service-account).

## Create a Sensu user account (service account)

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
sudo mkdir -p /opt/sensu/tmp
sudo chown -R _sensu:_sensu /opt/sensu
```

To delete the `_sensu` service account and remove the service account home directory, run the following commands:

```shell
sudo dscl . -delete /Groups/_sensu
sudo dscl . -delete /Users/_sensu
sudo rm -rf /opt/sensu
```

**Linux users:**

If you installed the Sensu Agent from a Linux binary archive (e.g. `.tar.gz` or `.zip` file) instead of using installer packages, you may encounter "unknown user" errors when running the `sensu-agent`.
The follow commands can be used on Linux systems to create the `sensu` group and user (these are the same commands used by the `.rpm` and `.deb` installer packages):

```shell
sudo groupadd -r sensu
sudo useradd -r -g sensu -d /opt/sensu -s /bin/false -c "Sensu Go" sensu
```

If you would prefer not to install a service account on your workstation, you may run the `sensu-agent` as root (e.g. remove the `-u _sensu` from `sudo sensu-agent start`), or set the `--cache-dir` to a writable location (e.g. `--cache-dir .sensu`).

## Encountering "command not found" errors when running `sensu-agent` on MacOS

Fresh MacOS installations may need to add `/usr/local/bin` to the system `$PATH`.
To temporarily modify `$PATH` in your current shell, use the following command:

```shell
export PATH=/usr/local/bin:$PATH
```

For more information on managing system `$PATH`, please consult the `path_helper` utilty (via `man path_helper`).

## How to access Sensu Agent logs when starting the agent via systemd

```shell
sudo journalctl -fu sensu-agent
```

### Help installing a Sensu Agent

If you are having trouble installing a Sensu Agent on your workstation you can run an agent in the workshop environment.

```
sudo docker-compose run --no-deps --rm -d \
-e SENSU_API_URL=${SENSU_API_URL} \
-e SENSU_NAMESPACE=${SENSU_NAMESPACE} \
-e SENSU_LABELS='{"app": "workshop", "environment": "training"}' \
sensu-agent
```

### The sensu-agent reports various "permission denied" errors

If you have run the `sensu-agent` as the `root` user, or other user with elevated privileges, and then attempt to start the `sensu-agent` process via service management or using a service account, you may encounter various "permission denied" errors.
The officially supported Sensu Agent installation packages (e.g. `.rpm` and `.deb` packages) will install and run all Sensu services as the `sensu` user (i.e. not `root`).
To ensure that the `sensu` users owns all of the files needed to run the Sensu Agent, run the following commands:

**Mac users:**

```
sudo chown -R _sensu:_sensu /opt/sensu
```

**Linux users:**

```shell
sudo chown -R sensu:sensu /etc/sensu
sudo chown -R sensu:sensu /var/lib/sensu
sudo chown -R sensu:sensu /var/cache/sensu
```

This should resolve any outstanding permissions errors.

### Unknown user `sensu` or `_sensu` when starting Sensu Agent

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

**Linux users:**

If you installed the Sensu Agent from a Linux binary archive (e.g. `.tar.gz` or `.zip` file) instead of using installer packages, you may encounter "unknown user" errors when running the `sensu-agent`.
The follow commands can be used on Linux systems to create the `sensu` group and user (these are the same commands used by the `.rpm` and `.deb` installer packages):

```shell
sudo groupadd -r sensu
sudo useradd -r -g sensu -d /opt/sensu -s /bin/false -c "Sensu Go" sensu
```

If you would prefer not to install a service account on your workstation, you may run the `sensu-agent` as root (e.g. remove the `-u _sensu` from `sudo sensu-agent start`), or set the `--cache-dir` to a writable location (e.g. `--cache-dir .sensu`).

### Encountering "command not found" errors when running `sensu-agent` on MacOS

Fresh MacOS installations may need to add `/usr/local/bin` to the system `$PATH`.
To temporarily modify `$PATH` in your current shell, use the following command:

```shell
export PATH=/usr/local/bin:$PATH
```

For more information on managing system `$PATH`, please consult the `path_helper` utilty (via `man path_helper`).

## How to access Sensu Agent logs when starting the agent via systemd

```shell
sudo journalctl -fu sensu-agent
```

## Copy files into running containers

In some cases it may be useful for troubleshooting and/or one-off customization of the workshop environment to copy files into a running container.
In a Docker environment this can be accomplished via the `docker cp` command, which is very similar to how you might use `scp` in a traditional virtualization environment.

```shell
sudo docker cp example.json workshop_sensu-backend_1:/tmp/example.json
```

The `docker cp` utility can also be used to _extract_ files from a running container.

```shell
sudo docker cp workshop_sensu-backend_1:/tmp/example.json example.json
```

## Delete Trainee namespaces

In some cases it may be useful to delete and recreate a trainee namespace (e.g. if a trainee user account was created on accident).

```shell
TRAINEE_NAMESPACE=trainee
sensuctl dump entities,events,assets,checks,filters,handlers,secrets/v1.Secret --namespace ${TRAINEE_NAMESPACE} | sensuctl delete
```

## Unable to execute Powershell scripts on a Windows workstation

In some cases users may encounter errors like `"File <filename.ps1> cannot be loaded because running scripts is disabled on this system."`.
This error is either the result of the default [Powershell Execution Policy](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies), or a restriction placed on employee workstations by an employer.
PowerShell's execution policy is a safety feature that controls the conditions under which PowerShell loads configuration files and runs scripts.
In some cases this can be easily resolved via the following steps:

1. Check the Powershell Execution Policy:

   ```powershell
   Get-ExecutionPolicy -List
   ```

   If the output looks like this (the default for Windows workstations), it may be possible to fix:

   ```
           Scope ExecutionPolicy
           ----- ---------------
   MachinePolicy       Undefined
      UserPolicy       Undefined
         Process       Undefined
     CurrentUser       Undefined
    LocalMachine       Undefined
   ```

1. Update the Powershell Execution Policy:

   To modify the execution policy, open Powershell with the "Run as Administrator" option and run the following commands:

   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine
   ```

   If you are unable to run Powershell as Administrator, you can scope the execution policy to CurrentUser instead with:

   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser
   ```

   To check the active execution policy is st to unrestricted use the following command:

   ```powershell
   Get-ExecutionPolicy
   ```

If a user is unable to modify the execution policy for their workstation, they should still be able to execute the commands contained in the Powershell script file directly via their terminal.

Reference: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies
