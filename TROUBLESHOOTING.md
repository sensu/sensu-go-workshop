# Troubleshooting

- [Deploying the workshop using `docker-compose` without `sudo`](#sudo-less-docker-compose)
- [Certain `sensuctl` commands produce authorization errors](#certain-sensuctl-commands-produce-authorization-errors)
- [Using the `sensuctl` container as a sandboxed workstation](#using-the-sensuctl-container-as-a-sandboxed-workstation)
- [Copy files into running containers](#copy-files-into-running-containers)
- [Delete trainee namespaces](#delete-trainee-namespaces)
- [Unable to execute Powershell scripts on a Windows workstation](#unable-to-execute-powershell-scripts-on-a-windows-workstation)

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

Trainees in instructor-led workshops may occassional encounter errors with messages like "Error putting resource..." and "unauthorized to perform action".
These messages are typically the result of Sensu's role-based access controls (RBAC) working as intended and informing users that they do not have the correct permissions.
In the sensu-go-workshop environment, the most common reason for these errors is a misconfiguration of `sensuctl`.

Sensu Go is a multi-tenant platform (multi-user, and multi-org), so a user may be authorized to perform a given action in one context, but unauthorized to perform the same action in another context.
For example, in the sensu-go-workshop environment, trainees in instructor-led workshops have full read/write access to their individual namespaces, and read-only access to the `default` namespace.
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

> _**NOTE:** please use the namespace as provided by your instructure (hint: this is usually the same as the username provided by your instructor)._

## Using the `sensuctl` container as a sandboxed workstation

This workshop includes a Docker container image with `sensuctl` and some additional helper utilities pre-installed.
This Docker image can be used as a "clean" workstation environment to avoid conflicts on your local workstation.

```
cd sensu-go-workshop
sudo docker-compose run --entrypoint="" sensuctl /bin/ash
```

You should now be presented with a prompt inside the running container.
This container has a volume mount of the contents of your local `sensu-go-workshop/` directory, so files you edit from your favorite editor on your local workstation will also be available inside the running container (at `/root/workshop`).

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

If a user is unable to modify the execution policy for their workstation, they should still be able to execute the commands contained in the Powershell script file directly via their terminal.

Reference: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies