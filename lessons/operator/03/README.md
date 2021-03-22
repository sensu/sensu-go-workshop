# Lesson 3: Introduction to Sensu Go

- [Web App](#web-app)
  - [Dashboard](#dashboard)
  - [Namespaces switcher](#namespaces-switcher)
  - [Event list & event detail views](#event-list--event-detail-views)
  - [Entity list & entity detail views](#entity-list--entity-detail-views)
  - [Silencing](#silencing)
  - [Configuration](#configuration)
- [EXERCISE: log in to the Sensu web app](#log-in-to-the-sensu-web-app)
- [Command Line Interface (CLI)](#command-line-interface--cli)
  - [API client](#api-client)
  - [Configuration management](#configuration-management)
  - [Inventory](#inventory)
  - [Output formats](#output-formats)
  - [Interactive and non-interactive modes](#interactive-and-non-interactive-modes)
- [EXERCISE: install and configure `sensuctl`](#exercise-install-and-configure-sensuctl)
- [EXERCISE: use the `sensuctl --help` command](#exercise-use-the-sensuctl---help-command)
- [EXERCISE: inspect an event in JSON format](#exercise-inspect-an-event-in-json-format)
- [EXERCISE: explore Sensu resources using `sensuctl`](#exercise-explore-sensu-resources-using-sensuctl)
- [EXERCISE: create an API Key for personal use](#exercise-create-an-api-key-for-personal-use)
- [EXERCISE: export Sensu resources using `sensuctl dump`](#exercise-export-sensu-resources-using-sensuctl-dump)
- [Learn more](#learn-more)
- [Next steps](#next-steps)

## Web App

The Sensu backend process includes a web app that provides a unified view of your observability data (events, entities, and silences) and monitoring configuration (checks, handlers, etc) with user-friendly tools to reduce alert fatigue.

### Dashboard

The Sensu web app homepage is a dashboard that provides a high level overview of the overall health of the systems under management by Sensu.
The dashboard includes a summary of active incidents, a breakdown of incidents by severity, information about entities under management, and a high level overview of the namespaces (tenants).
This dashboard complies with Sensu RBAC, so individual users will see summary information relevant to their access.

![The Sensu dashboard](/docs/img/lessons/operator/03-01-dashboard.png)

_**Figure 1:** the Sensu dashboard._

### Namespaces switcher

Beyond the overview dashboard, most Sensu data is accessed on a per-namespace basis.
To select or switch namespaces, press the "Select Namespace" option from the sidebar, or press the `Control + k` keyboard shortcut from anywhere in the Sensu web app.

![The namespace switcher modal](/docs/img/lessons/operator/03-02-namespace-switcher.png)

_**Figure 2:** the namespace switcher._

![The "Select Namespace" option in the navigation sidebar](/docs/img/lessons/operator/03-03-select-namespace.png)

_**Figure 3:** the "Select Namespace" option in the navigation sidebar._

### Event list & event detail views

The default view that will be opened when navigating to a namespace is the event list view.
A filter is applied to this view by default to show only events with a "non-passing" status (i.e. `event.check.state != 0-`).
The event list view provides a number of options for filtering and sorting the list by event status, related entities, and more.

![The event list view](/docs/img/lessons/operator/03-04-event-list-view.png)

_**Figure 4:** the event list view.
Note the default filter applied here (`event.check.state != 0`)._

![The event detail view](/docs/img/lessons/operator/03-05-event-detail-view.png)

_**Figure 5:** the event detail view._

### Entity list & entity detail views

The second most popular view in the Sensu web app is the entity list view, which provides realtime inventory information of endpoints under management by Sensu (for a given namespace).
Selecting an entity from the entity list view will take you to the entity detail view, which provides information about all associated events, system properties (e.g. operating system details and network interfaces), and entity metadata (labels and annotations).

![The entity list view](/docs/img/lessons/operator/03-06-entity-list-view.png)

_**Figure 6:** the entity list view._

![The entity detail view](/docs/img/lessons/operator/03-07-entity-detail-view.png)

_**Figure 7:** the entity detail view.
Note that the "Events" tab is selected by default)._

### Silencing

### Configuration

## EXERCISE: log in to the Sensu web app

1. Log in to the Sensu web app.

   - **Self guided users:** please visit http://127.0.0.1:3000 and login with the default workshop admin username (`sensu`) and password (`sensu`).
   - **Instructor-led workshop users:** please visit the URL provided by your instructor and login using the username and password provided by your instructor.

   ![](/docs/img/login.png)

   > **NEXT:** if you were able to login you're ready to continue with the workshop.

   > _TROUBLESHOOTING: if you are unable to reach the login screen, please consult with your instructor, or double-check that you completed all of the steps in [SETUP.md](/docs/SETUP.md) before proceeding._

## Command line interface (CLI)

### API client

==TODO: Sensu is an API-based observability platform; web app and CLI are just API clients.
Authenticate using `sensuctl configure`.
To learn more about the Sensu APIs, please visit the API reference documentation and/or Sensu Developer Training (coming soon).==

### Configuration management

==TODO: declarative configuration files and configuration management commands==

### Inventory

### Output Formats

### Interactive and non-interactive modes

## EXERCISE: install and configure `sensuctl`

1. Download and install `sensuctl`.

   Mac users:

   ```shell
   SENSU_CLI_VERSION=${SENSU_CLI_VERSION:-"6.2.5"}
   curl -LO "https://s3-us-west-2.amazonaws.com/sensu.io/sensu-go/${SENSU_CLI_VERSION}/sensu-go_${SENSU_CLI_VERSION}_darwin_amd64.tar.gz"
   sudo tar -xzf "sensu-go_${SENSU_CLI_VERSION}_darwin_amd64.tar.gz" -C /usr/local/bin/
   rm sensu-go_${SENSU_CLI_VERSION}_darwin_amd64.tar.gz
   ```

   > _NOTE: Windows and Linux users can find [installation instructions](#) in the Sensu [user documentation](#).
   > The complete list of Sensu downloads is available at https://sensu.io/downloads._

1. Configure `sensuctl`.

   Configure the Sensu CLI to connect to your backend by running the `sensuctl
   configure` command.
   Sensuctl will prompt you to provide a Sensu Backend URL,
   username, password, namespace, and preferred output format.

   ```shell
   sensuctl configure --interactive
   ```

   Backend URL:

   - **Self guided users:** self-guided trainees who are running the workshop on their local workstation should use the default backend URL (`http://127.0.0.1:8080`), username (`sensu`), and password (`sensu`).
   - **Instructor-led workshop users:** please use the Backend URL provided by your instructor.

   The `sensuctl configure --interactive` mode will prompt you for the following settings:

   ```shell
   ? Authentication method: username/password
   ? Sensu Backend URL: http://127.0.0.1:8080
   ? Namespace: default
   ? Preferred output format: tabular
   ? Username: sensu
   ? Password: *****
   ```

1. Verify your `sensuctl` configuration.

   If you do not receive an error message after entering your username and password you should have a successfully configured CLI.
   To confirm, let's run a `sensuctl` command to verify that we are successfully connected to the cluster:

   ```shell
   sensuctl namespace list
   ```

   The output should look something like the following:

   ```
      Name
    ─────────
     default
     user
   ```

**NEXT:** If you see output with a list of one or more namespaces you are ready to continue to the next step!

## EXERCISE: use the `sensuctl --help` command

Sensuctl includes a `--help` flag for getting help with every command and subcommand.

Try running some of the following commands:

1. See all available `sensuctl` commands and global flags:

   ```
   sensuctl --help
   ```

1. See all of the available subcommands and flags for the `sensuctl check` command:

   ```
   sensuctl check --help
   ```

1. See all of the available flags for the `sensuctl check create` subcommand:

   ```
   sensuctl check create --help
   ```

Learning how to navigate the `sensuctl` tool with the assistance of the `--help` flag will make the Sensu CLI much easier to use.

**NEXT:** after you've tried a few `--help` commands you're ready to move on to the next step.

## EXERCISE: inspect an event in JSON format

1. Use the `sensuctl event info` command to get information about an event.

   ```
   sensuctl event info learn.sensu.io helloworld
   ```

   The Sensu CLI will use your default output format (which defaults to "tabular") for displaying information about most resources.
   The tabular output format is usually easier to read, but doesn't show all of the available properties for a given resource.

   Example tabular output:

   ```shell
   === learn.sensu.io - helloworld
   Entity:    learn.sensu.io
   Check:     helloworld
   Output:    Hello, workshop world.
   Status:    1
   History:
   Silenced:  false
   Timestamp: 2021-03-09 22:44:28 -0800 PST
   UUID:      7d0721c8-d203-4e80-a399-05070a914b20
   ```

1. View event information in JSON format.

   To modify the output format on a per-command basis use the `--format` flag:

   ```shell
   sensuctl event info learn.sensu.io helloworld --format json
   ```

   > **NOTE:** the `--output` flag is available for a variety of `sensuctl` commands, which can be quite helpful for writing scripts that leverage data from Sensu APIs.

**NEXT:** If `sensuctl` output a JSON formatted event, you're ready to move on to the next step.

## EXERCISE: explore Sensu resources using `sensuctl`

1. Use the `sensuctl namespace list` command to get a list of namespaces.

   ```shell
   sensuctl namespace list
   ```

   _NOTE: the output of this command is filtered based on RBAC, so different users may see different results._

1. Use the `sensuctl event list` command to get a list of events.

   ```shell
   sensuctl event list
   ```

   _NOTE (for trainees in instructor-led workshops): try adding `--namespace default` to get a list of events from the `default` namespace._

1. Use the `sensuctl entity list` command to get a list of nodes under management.

   ```shell
   sensuctl entity list
   ```

   _NOTE: try adding `--format json` or `--format yaml` to view the list in JSON or YAML format._

1. Get information about a specific entity using the `sensuctl entity info` command

   ```shell
   sensuctl entity info learn.sensu.io
   ```

1. Try exploring some other resources.

   _NOTE: don't forget to use `--help`; for example, `sensuctl --help` will output a list of "management commands" which are effectively API resources that are accessible via `sensuctl`._

**NEXT:** when you're done exploring `sensuctl` resource list and info commands, you're ready to move on to the next step.

## EXERCISE: create an API Key for personal use

1. Use the `sensuctl api-key grant` command to create an API Key.

   ```shell
   sensuctl api-key grant sensu
   ```

   > _NOTE: self-guided trainees should grant an api-key for the default user (`sensu`), as shown above.
   > Trainees in instructor-led workshops should create an api-key for their own user, using the username provided by the instructor (e.g. `sensuctl api-key grant <username>`)._

   The output of this command will look like:

   ```shell
   Created: /api/core/v2/apikeys/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
   ```

1. Save the API Key user in a future exercise.

   For the purposes of this workshop, we want to capture this API key (the
   `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` part of the output) for use in a future exercise.
   You can either copy the output from the `sensuctl api-key grant` command manually, like this:

   Modify the provide `.envrc` file using your API Key.
   Uncomment the line that begins with `# export SENSU_API_KEY` so that it looks like the following example:

   ```shell
   export SENSU_API_KEY=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
   ```

   > **PROTIP:** if you like to automate things like this using shell scripts, you might already be thinking about how to parse the output of the `sensuctl api-key grant` command.
   > The following example should do the trick:
   >
   > ```shell
   > export SENSU_API_KEY=$(sensuctl api-key grant sensu | awk -F "/" '{print $NF}')
   > ```


   Verify that you have successfully set an environment variable with your API
   key:

   ```shell
   echo $SENSU_API_KEY
   xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
   ```

**NEXT:** If you see your API key, you're ready to move on to the next step!

## EXERCISE: export Sensu resources using `sensuctl dump`

The `sensuctl dump` command is a built-in solution for exporting & importing Sensu API resources.
You can use `sensuctl dump` to output Sensu configuration resources to STDOUT (i.e. for viewing in the terminal), or to a file.
The `sensuctl dump` command has a wide range of use cases from simple backup and restore, to inspecting configuration resources, scripting maintenance tasks (e.g. bulk deletion of entities), and more.

1. Export all resources.

   ```shell
   sensuctl dump all
   ```

1. Export resources for a single namespace.

   ```shell
   sensuctl dump all --namespace default
   ```

1. Export specific resources, by type.

   ```shell
   sensuctl dump checks,handlers
   sensuctl dump checks > checks.yaml
   sensuctl dump handlers > handlers.yaml
   ```

   _NOTE: at this stage in the workshop this command may not generate any output (becase we haven't created any checks or handlers yet)._

1. Get a complete list of resource types supported by `sensuctl dump`.

   ```shell
   sensuctl describe-type all --format yaml
   ```

   Notice that some resources have "short names" (e.g. `core/v2.CheckConfig` has the short name `check`).
   Try exporting a resource by its Fully Qualified Name.

   ```shell
   sensuctl dump core/v2.Entity --format wrapped-json
   sensuctl dump secrets/v1.Secret --format yaml
   ```

**NEXT:** once you have exported your secrets you're ready to move on to the next step!

## Learn more

## Next steps

[Lesson 4: Introduction to Handlers & Handler Sets](../04/README.md#readme)
