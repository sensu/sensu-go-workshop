# Lesson 3: Using the Sensu CLI
- [Goals](#goals)
- [The `sensuctl` Command Line Interface (CLI)](#the-sensuctl-command-line-interface-cli)
   - [EXERCISE 1: Install the `sensuctl` CLI](#exercise-1-install-the-sensuctl-cli)
- [Configuration Options](#configuration-options)
   - [EXERCISE 2: Configure the `sensuctl` CLI](#exercise-2-configure-the-sensuctl-cli)
- [API Keys](#api-keys)
   - [EXERCISE 3: Create an API Key](#exercise-3-create-an-api-key)
- [Listing and Viewing Resources](#listing-and-viewing-resources)
  - [EXERCISE 4: List Sensu Resources](#exercise-4-list-sensu-resources)
- [Inventory Management](#inventory-management)
  - [EXERCISE 5: List an Inventory of Nodes](#exercise-5-list-an-inventory-of-nodes)
- [Monitoring as Code](#monitoring-as-code)
  - [EXERCISE 6: Exporting and Updating Resource Configurations](#exercise-6-exporting-and-updating-resource-configurations)
- [Learn More](#learn-more)
- [Next Steps](#next-steps)

## Goals

In this lesson we will introduce the `sensuctl` command-line tool.
You will learn how to install and configure the tool, then practice performing some essential operations.

This lesson is intended for operators of Sensu and assumes you have [set up a local workshop environment][setup_workshop].

## The `sensuctl` Command Line Interface (CLI)

The `sensuctl` tool, short for _Sensu Control_, gives you full control of your Sensu pipeline from a command-line environment. 
You can use `sensuctl` interactively in a shell, or script it as part of an automated solution.

The `sensuctl` tool is available for Linux, macOS, and Windows.

### EXERCISE 1: Install the `sensuctl` CLI
#### Scenario

You want to view and manage resources in Sensu from a command-line environment or in an automated script.

#### Solution

Install the `sensuctl` CLI tool.

First, we will configure some helpful environment variables, download the `sensuctl` archive, then unpack that to a standard location on your system.

#### Steps

1. **Configure Environment Variables.**

   The [workshop repository] includes platform-specific files that export some environment variables which we will use throughout the workshop.
   The exercises assume you are in a shell that has these variables configured.
   
   When you open a new shell environment, export the variables using one of the following commands:

   **Mac and Linux:**

   ```shell
   source .envrc
   ```

   **Windows (Powershell):**

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

1. **Download and Install `sensuctl`.**

   Download the platform-specific archive from Sensu's official release location. Unpack the archive into a standard location.

   **Mac:**

   ```shell
   curl -LO "https://s3-us-west-2.amazonaws.com/sensu.io/sensu-go/${SENSU_VERSION}/sensu-go_${SENSU_VERSION}_darwin_amd64.tar.gz"
   sudo tar -xzf "sensu-go_${SENSU_VERSION}_darwin_amd64.tar.gz" -C /usr/local/bin/
   ```

   **Linux:**

   ```shell
   curl -LO "https://s3-us-west-2.amazonaws.com/sensu.io/sensu-go/${SENSU_VERSION}/sensu-go_${SENSU_VERSION}_linux_amd64.tar.gz" 
   tar -xzf "sensu-go_${SENSU_VERSION}_linux_amd64.tar.gz" -C /usr/local/bin/ 
   ```
 
   **Windows (Powershell):**

   ```powershell
   Invoke-WebRequest `
     -Uri "https://s3-us-west-2.amazonaws.com/sensu.io/sensu-go/${Env:SENSU_VERSION}/sensu-go_${Env:SENSU_VERSION}_windows_amd64.zip" `
     -OutFile "${Env:UserProfile}\sensu-go_${Env:SENSU_VERSION}_windows_amd64.zip"
   Expand-Archive `
     -LiteralPath "${Env:UserProfile}\sensu-go_${Env:SENSU_VERSION}_windows_amd64.zip" `
     -DestinationPath "${Env:UserProfile}\Sensu\bin"
   ${Env:Path} += ";${Env:UserProfile}\Sensu\bin"
   ```

   > **NOTE:** On Unix-like systems `/usr/local/bin` is the [standard location for binaries shared between multiple users][fhs_usr_local_docs]. 
   > On macOS, the default permissions for `/usr/local/bin` require the used of `sudo`. 
   > However, any location that is on your `$PATH` will work (i.e. `~/bin`).
   > On Windows systems we create a new location specificly for Sensu, then add it to the path.

## Configuration Options

### Sensu is an API

Sensu has an [API-based][sensu_api_docs] architecture. 
Everything that happens on the platform is done by interacting with one or more APIs.
The primary function of `sensuctl` is to manage Sensu resources.
It does this by calling Sensu's API to create, read, update, and delete (CRUD) resources like _events_, _checks_, and _handlers_.

Since `sensuctl` is an API client, it requires some configuration settings to get started.

#### Sensu Backend Url
Sensu's API is provided by a _backend_. 
The backend URL is the adress and port of the backend you want to manage.

For this workshop, we will be using the URL `http://127.0.0.1:8080`.

#### Authentication Type

Because all access to the Sensu API requires authentication, `sensuctl` must be configured with login credentials.
Sensu supports both username/password and OIDC-based authentication.

For this workshop, we will be using the username `sensu` and the password `sensu`.

#### Namespaces

Sensu resources can be organized by _namespace_.
This is helpful in complex infrastructures where there are many systems to observe and manage.

For this workshop, we will be using the `default` namespace.

#### Output Format

Since `sensuctl` can be used both interactively and in automated scripts, there are a variety of output options available.
The default `tabular` output mode is a compact and human-readable format.

For this workshop, we will be using the `tabular` output mode.


### EXERCISE 2: Configure the `sensuctl` CLI

#### Scenario

You've just installed `sensuctl` and need to configure it to interact with a Sensu backend API.

#### Solution

Run the `sensuctl configure` command.
This interactive command will prompt you for all the necessary configuration variables.

#### Steps

1. **Run the `sensuctl configure` Command.**

   The `sensuctl configure` command will prompt you to provide the preferred authentication method, backend URL, namespace, output format, username, and password.

   ```shell
   sensuctl configure
   ```

   For this workshop, we will use the following options:
   - **Authentication method:** `username/password`
   - **Sensu Backend URL:** `http://127.0.0.1:8080`
   - **Namespace:** `default`
   - **Preferred output format:** `tabular`
   - **Username:** `sensu`
   - **Password:** `sensu`
   
 
1. **Verify the `sensuctl` Configuration.**

   You should now have successfully configured `sensuctl`.
 
   To confirm, run a `sensuctl` command to verify the configuration:

   ```shell
   sensuctl config view
   ```

   **Example Output:**

   ```
   === Active Configuration
   API URL:                  http://127.0.0.1:8080
   Namespace:                default
   Format:                   tabular
   Timeout:                  15s
   Username:                 sensu
   JWT Expiration Timestamp: 1234567890
   ```
> **PROTIP:** Certain `sensuctl` commands support a _non-interactive_ mode.
> This is helpful when using `sensuctl` in an automated context like a CI/CD pipeline.
> 
> For example, the `sensuctl configure` command can be run non-interactively using the `-n` option.
> 
> 
> **Example:** Non-interactive use of `sensuctl configure`
>
> ```shell
> $ sensuctl configure -n \
>   --api-url http://127.0.0.1:8080 \
>   --namespace default \
>   --username sensu \
>   --password ${SENSU_PASSWORD} \
>   --format json
> ```

## API Keys

Another way to authenticate requests is to use an [api key][api_key_docs]. 
API keys allow automated components access to the API without the need for usernames and passwords.

Many of the exercises in this workshop will require an API key, so let's create one now.

### EXERCISE 3: Create an API Key

#### Scenario

You want to use tools like `curl` and `sensuctl` to create and manage resources, but you do not want to use passwords. 

#### Solution

Create an API key using `sensuctl api-key grant`. This will create a user-specific key that can be used in an authorization header of an API request.

This key can also be used with any `sensuctl` command by adding the [`--api-key` option][sensuctl_global_flags_docs].

#### Steps

1. **Create an API Key Using the `sensuctl api-key grant` Command.**

   API keys are user-specfic, so we need to specify the user. 
   This key will be created for the `sensu` user.

   ```shell
   sensuctl api-key grant sensu
   ```

   **Example Output:**

   ```shell
   Created: /api/core/v2/apikeys/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
   ```

1. **Save the API Key in the `SENSU_API_KEY` Environment Variable.**

   For this workshop, we want to save the API key in an environment variable for use in future exercises.
   
   1. Copy the `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` part of the output onto the clipboard (without the `/api/core/v2/apikeys/` portion).
   
   1. Modify the `.envrc` or `.envrc.ps1`, replacing the value for `SENSU_API_KEY` with the key we just copied, then uncomment the line.
   
      When complete, your file should have a line like this:

      **Mac and Linux users (`.envrc`):**

      ```shell
      export SENSU_API_KEY=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
      ```

      **Windows users (`.envrc.ps1`):**

      ```powershell
      ${Env:SENSU_API_KEY}="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
      ```
   
1. **Reload the Environment Variables.**

   **Mac and Linux:**

   ```shell
   source .envrc
   ```

   **Windows (Powershell):**

   ```powershell
   . .\.envrc.ps1
   ```

1. Verify that the `SENSU_API_KEY` environment variable is set:

   **Mac and Linux:**
 
   ```shell
   echo $SENSU_API_KEY
   ```

   **Windows (Powershell):**

   ```powershell
   $env:SENSU_API_KEY
   ```

> **PROTIP:** If you like to automate things like this using shell scripts, you might already be thinking about how to parse the output of the `sensuctl api-key grant` command.
>
> The following example should do the trick for Mac and Linux users:
>
> **Example:** Parsing an API key using `awk`
> ```shell
> export SENSU_API_KEY=$(sensuctl api-key grant sensu | awk -F "/" '{print $NF}')
> ```

## Listing and Viewing Resources

One of the common uses of `sensuctl` is to list and view resources like namespaces, users, and entities. 

### EXERCISE 4: List Sensu Resources
#### Scenario

You want to explore the resources available in Sensu. 

#### Solution

To see a list, use the `sensuctl <resource_type> list` command pattern. 
The `list` subcommand is available for nearly all resources, including common resources like namespaces, users, and entities.

#### Steps

1. **Use the `sensuctl namespace list` Command to Get a List of Namespaces.**

   ```shell
   sensuctl namespace list
   ```
   
   **Example Output:**
   ```shell
      Name
    ─────────
     default
     trainee
   ```
1. **Use the `sensuctl user list` Command to Get a List of Users.**

   ```shell
   sensuctl user list
   ```
   
   **Example Output:**
   ```shell
     Username           Groups            Enabled
    ────────── ───────────────────────── ─────────
     agent      system:agents             true
     sensu      cluster-admins            true
     trainee    trainee,trainee:trainee   true
   ```
>**PROTIP:** Want to explore what `sensuctl` can do? Try using the  `--help` option to show a list of commands. This option is available on all commands and subcommands.

## Inventory Management

One common use case for `sensuctl` is to manage a real-time "inventory of nodes".
Nodes are represented as _entities_, and they either have an agent running locally, or are proxying observability data through an agent running elsewhere.

The commands `sensuctl entity list` and `sensuctl entity info <entity_id>` are used to list and inspect entities.

### EXERCISE 5: List an Inventory of Nodes
#### Scenario

You have a large inventory of nodes and you want to view a real-time list of those entities.
You also want to automate some tasks based on that list, but need some detailed information about the node in JSON format.

#### Solution

To view a list of nodes, use the `sensuctl entity list` command. 
Individual node information can be viewed using the `sensuctl entity info <entity_id>` command. 
In automated scenarios, adding the `--format json` option will output the information in JSON format.

#### Steps
1. **List Entities Under Management by Sensu.**

   To get a real-time list of entities, run `sensuctl entity list`.

   ```shell
   sensuctl entity list
   ```
 
   **Example Output:**
   ```shell
              ID         Class      OS                       Subscriptions                              Last Seen
    ──────────────── ─────── ────────── ───────────────────────────────────────────────── ───────────────────────────────
     0ed711859366     agent   linux      system/linux,workshop,devel,entity:0ed711859366   2021-09-15 17:18:18 -0700 PDT
     learn.sensu.io   proxy   Workshop   entity:learn.sensu.io                             N/A

   ```
  
1. **Show Detailed Entity Information.**

   To get detailed information about an entity, run `sensuctl entity info <entity_id>`.

   ```shell
   sensuctl entity info learn.sensu.io
   ```

   **Example Output:**
   ```shell
   === learn.sensu.io
   Name:                   learn.sensu.io
   Entity Class:           proxy
   Subscriptions:          entity:learn.sensu.io, workshop-test
   Last Seen:              N/A
   Hostname:               learn.sensu.io
   OS:                     Workshop
   Platform:               Sensu Go
   Platform Family:        Training
   Platform Version:       6.2.7
   Auto-Deregistration:    true
   Deregistration Handler: 
   ```

1. **Output Entity Information in JSON Format.**

   Entity information is commonly used in automation scenarios, such as scripts or CI/CD workflows.
   In those situations it you may wish to output this information in a structured format like JSON. 

   ```shell
   sensuctl entity info learn.sensu.io --format json
   ```

   **Example Output:**
   ```json
   {
     "entity_class": "proxy",
     "system": {
       "hostname": "learn.sensu.io",
       "os": "Workshop",
       "platform": "Sensu Go",
       "platform_family": "Training",
       "platform_version": "6.2.7",
       "network": {
         "interfaces": [
           {
             "name": "lo",
             "mac": "00:00:00:00:00:00",
             "addresses": [
               "127.0.0.1/8",
               "::1/128"
             ]
           },
           {
             "name": "eth0",
             "mac": "00:00:00:00:00:00",
             "addresses": [
               "10.0.0.1/8"
             ]
           }
         ]
       },
       "arch": "arm",
       "libc_type": "",
       "vm_system": "",
       "vm_role": "",
       "cloud_provider": "",
       "processes": null
     },
     "subscriptions": [
       "entity:learn.sensu.io",
       "workshop-test"
     ],
     "last_seen": 0,
     "deregister": true,
     "deregistration": {},
     "user": "workshop",
     "metadata": {
       "name": "learn.sensu.io",
       "namespace": "default",
       "labels": {
         "app": "workshop"
       },
       "created_by": "sensu"
     },
     "sensu_agent_version": ""
   }
   ```

## Monitoring as Code

The `sensuctl` monitoring-as-code workflow manages resource configurations using plain-text formats like YAML and JSON.

Managing resources follows these basic steps:
1. Resource configurations are defined in a YAML or JSON file.
2. The `sensuctl create` command reads the resource configuration from the file, then pushes that configuration to the backend API where the resource is created.
3. The file can then be saved to a file within a source code repository. 
4. Later, the file can be modified and `sensuctl create` is used to update the resource.

You can also use the `sensuctl dump` command to export a resource to a file, or add the `--format` option to a `sensuctl entity info` command to output the resource in a structured format. 

These features together enable Sensu's _monitoring-as-code_ workflow.

### EXERCISE 6: Exporting and Updating Resource Configurations
#### Scenario

You have an entity in a running Sensu environment but don't have a YAML file that describes it. You'd like to save the resource to a file so you can modify the configuration, and store that configuration to a code repository.

#### Solution

To accomplish this, we will use the `sensuctl entity info` command with the `--format yaml` option to output an existing resource to YAML. 
Once we have that YAML file, we can modify the configuration, then update the resource configuration using `sensuctl create`.

#### Steps
1. **Export an Entity Configuration in YAML Format.**

   Use the `sensuctl entity info` command with the `--format yaml` option. 
   Pipe the output to a file named `entity.yaml`.

   ```shell
   sensuctl entity info learn.sensu.io --format yaml > entity.yaml
   ```

   **Example Output:** `entity.yaml`
   ```yaml
   type: Entity
   api_version: core/v2
   metadata:
     created_by: sensu
     labels:
       app: workshop
     name: learn.sensu.io
     namespace: default
   spec:
     deregister: true
     deregistration: {}
     entity_class: proxy
     last_seen: 0
     sensu_agent_version: ""
     subscriptions:
     - entity:learn.sensu.io
     system:
       arch: arm
       cloud_provider: ""
       hostname: learn.sensu.io
       libc_type: ""
       network:
         interfaces:
         - addresses:
           - 127.0.0.1/8
           - ::1/128
           mac: "00:00:00:00:00:00"
           name: lo
         - addresses:
           - 10.0.0.1/8
           mac: "00:00:00:00:00:00"
           name: eth0
       os: Workshop
       platform: Sensu Go
       platform_family: Training
       platform_version: 6.2.7
       processes: null
       vm_role: ""
       vm_system: ""
     user: workshop
   ```
1. **Modify the Resource Configuration.**

   Using a text editor, change the `subscriptions` list, adding a new item `workshop-test`.
   
   **Example:** `entity.yaml`
   ```yaml
   type: Entity
   api_version: core/v2
   metadata:
     created_by: sensu
     labels:
       app: workshop
     name: learn.sensu.io
     namespace: default
     spec:
       deregister: true
       deregistration: {}
       entity_class: proxy
       last_seen: 0
       sensu_agent_version: ""
       subscriptions:
       - entity:learn.sensu.ioi
       - workshop-test
       system:     
   [..clipped..]
   ```
   
1. **Update the Running Resource Configuration.**

   Update the running entity configuration using `sensuctl create`. 
   The `-f` option specifies the YAML file to read from. 

   If the specified resource doesn't exist, the `sensuctl create` command will _create_ it.
   However, if it already exists, the command will _update_ it.

   ```shell
   sensuctl create -f entity.yaml
   ```

1. **Verify the Updated Configuration.**

   View the updated configuration by running `sensuctl entity info`.

   ```shell
   sensuctl entity info learn.sensu.io
   ```

   **Example Output:**
   ```
   === learn.sensu.io
   Name:                   learn.sensu.io
   Entity Class:           proxy
   Subscriptions:          entity:learn.sensu.io, workshop-test
   Last Seen:              N/A
   Hostname:               learn.sensu.io
   OS:                     Workshop
   Platform:               Sensu Go
   Platform Family:        Training
   Platform Version:       6.2.7
   Auto-Deregistration:    true
   Deregistration Handler:
   ```

   If you now have `workshop-test` listed in the `Subscriptions` value, the update was successful!

# Discussion

In this lesson, you learned how to install and configure the `sensuctl` CLI tool, create an API key, and how to explore and manage resources in Sensu.

### Sensu is an API, `sensuctl` is the Client

At the core of these operations is the [Sensu API][sensu_api_docs]. In fact, `sensuctl` can be thought of as a client for the Sensu API, making it easier to perform common tasks from the command line. These same tasks could have been perfomed with `curl` or any other system that can make HTTP requests.

Sensu's API-based design is key to enabling monitoring-as-code workflows, and allows for extensive customization via scripting and automation.

### Sensu Web App 

For those who prefer a browser-based user experience, the Sensu Web App can perform many of the same tasks. It interacts with the same APIs and gives you some powerful visualization and exploration tools. Learn more about the Sensu Web App in Lesson X.

## Learn More

- [[Documentation] "Sensu CLI" (docs.sensu.io)](https://docs.sensu.io/sensu-go/latest/sensuctl/)
- [[Documentation] "Create and manage resources with `sensuctl`" (docs.sensu.io)](https://docs.sensu.io/sensu-go/latest/sensuctl/create-manage-resources/)
- [[Documentation] "Backup and recover resources with `sensuctl`" (docs.sensu.io)](https://docs.sensu.io/sensu-go/latest/sensuctl/back-up-recover/)
- [[Documentation] "Filter responses with `sensuctl`" (docs.sensu.io)](https://docs.sensu.io/sensu-go/latest/sensuctl/filter-responses/)
- [[Documentation] "Set environment variables with `sensuctl`" (docs.sensu.io)](https://docs.sensu.io/sensu-go/latest/sensuctl/environment-variables/)
- [[Blog Post] "A Primer on Sensu Dashboards" (sensu.io)](https://sensu.io/blog/a-primer-on-sensu-dashboards-eb0940293a)

## Next Steps

[Share your feedback on Lesson 03](https://github.com/sensu/sensu-go-workshop/issues/new?template=lesson_feedback.md&labels=feedback%2Clesson-03&title=Lesson%2003%20Feedback)

[Lesson 4: Introduction to Handlers](../04/README.md#readme)

[setup_workshop]: https://github.com/sensu/sensu-go-workshop/blob/latest/SETUP.md
[fhs_usr_local_docs]: https://www.pathname.com/fhs/pub/fhs-2.3.html#USRLOCALLOCALHIERARCHY
[sensuctl_global_flags_docs]: https://docs.sensu.io/sensu-go/latest/sensuctl/#global-flags
[api_key_docs]: https://docs.sensu.io/sensu-go/latest/operations/control-access/use-apikeys/
[sensu_api_docs]: https://docs.sensu.io/sensu-go/latest/api/

