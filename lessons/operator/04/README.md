# Lesson 4: Introduction to Handlers

- [Goals](#goals)
- [Handlers](#handlers)
  - [Pipe Handlers](#pipe-handlers)
  - [EXERCISE 1: Create a Handler that Sends Alerts to a Chat App](#exercise-1-create-a-handler-that-sends-alerts-to-a-chat-app)
- [Using Handlers to Store Observability Data](#using-handlers-to-store-observability-data)
  - [Events and Metrics](#events-and-metrics)
  - [Handler Filters](#handler-filters)
  - [EXERCISE 2: Create a Handler that Stores Metrics to a Time-Series Database](#exercise-2-create-a-handler-that-stores-metrics-to-a-time-series-database)
- [Discussion](#discussion)
  - [Where Do Handlers Run?](#where-do-handlers-run)
  - [Monitoring as Code and Sensu’s API-based Architecture](#monitoring-as-code-and-sensus-api-based-architecture)
  - [Sensu Plugin SDK, Templating, and Configuration Overrides](#sensu-plugin-sdk-templating-and-configuration-overrides)
  - [Additional Use Cases](#additional-use-cases)
- [Learn more](#learn-more)
- [Next steps](#next-steps)

## Goals

In this lesson we will introduce Sensu Handlers, and show how to configure an alert handler and a metrics handler. 
This lesson is intended for operators of Sensu, and assumes you have [set up a local workshop environment][setup_workshop].

## Handlers 

Handlers are actions the Sensu backend executes on incoming observability events.
Handler configurations are one of the most important building blocks within Sensu, because they determine what happens to events that flow through the Sensu pipeline.

Handlers can be used to send alerts, store observability data, create and resolve incidents, and trigger automated remediations.
In the following exercises we will configure two handlers; one that send alerts to a chat app, and another that stores metrics to a time-series database.

### Pipe Handlers

The most common type of handler is a _pipe handler_. 
A pipe handler can be any program that accepts event data as JSON input to `STDIN`, even a shell script. 
There are many existing handlers [available in Bonsai][bonsai_handlers].
 
**Example pipe handler:**

```yaml
---
type: Handler
api_version: core/v2
metadata:
  name: example_pipe_handler
spec:
  type: pipe
  command: do_something.sh
```

### EXERCISE 1: Create a Handler that Sends Alerts to a Chat App

#### Scenario

Your SRE team primarily communicates via a chat app like [Slack] or [RocketChat]. They want to recieve alerts as chat messages.

#### Solution

To accomplish this we will use the [sensu-rocketchat-handler][sensu_rocketchat_handler].
The handler will send event data to a channel in a [RocketChat] instance.

#### Steps

1. **Create a YAML File Containing the Handler Configuration**

   Copy and paste the following contents to a file named `rocketchat.yaml`:

   ```yaml
   ---
   type: Handler
   api_version: core/v2
   metadata:
     name: rocketchat
     labels:
       sensu.io/workflow: sensu-flow/v1
   spec:
     type: pipe
     command: >-
       sensu-rocketchat-handler
       --url ${ROCKETCHAT_URL}
       --channel ${ROCKETCHAT_CHANNEL}
       --user ${ROCKETCHAT_USER}
       --description-template "{{ .Check.Output }}\n\n[namespace: {{.Entity.Namespace}}]"
     runtime_assets:
     - sensu/sensu-rocketchat-handler:0.1.0
     timeout: 10
     filters: []
     secrets:
     - name: ROCKETCHAT_URL
       secret: rocketchat_url
     - name: ROCKETCHAT_CHANNEL
       secret: rocketchat_channel
     - name: ROCKETCHAT_USER
       secret: rocketchat_user
     - name: ROCKETCHAT_PASSWORD
       secret: rocketchat_password
   ```
   
   > **Understanding the YAML:**
   > - The asset identifier `sensu/sensu-rocketchat-handler:0.1.0` instructs the backend to download the handler executable from [Bonsai]. 
   > - The `--description-template` option uses a [handler template][handler_template_docs] to format the event into a message string.
   > - The handler is configured using environment variables and secrets available to the Sensu backend.
   
1. **Create the Handler Using the `sensuctl create` Command**

   ```shell
   sensuctl create -f rocketchat.yaml
   ```

   This command will create the handler configuration contained in the YAML file by sending it to the [Sensu Handler API][handler_api_docs].

1. **Verify that the handler was successfully created.**

   ```shell
   sensuctl handler list
   ```

   **Output:**

   ```shell
     Name    Type   Timeout     Filters     Mutator            Execute            Environment Variables               Assets
    ─────── ────── ───────── ───────────── ───────── ─────────────────────────── ─────────────────────── ─────────────────────────────────
    rocketchat   pipe     10   is_incident           RUN:  sensu-rocketchat-handler                      sensu/sensu-rocketchat-handler:0.1.0
   ```

   Do you see the `rocketchat` handler in the output? 
   If so, you've successfully created your first handler.

## Using Handlers to Store Observability Data

Sensu is designed to be a pipeline for observability events, but does not store the events directly.
If you want to keep a historical record of the data, a handler can be used. 
The handler converts incoming events into the required format, then sends it to a database for storage.

### Events and Metrics

In Sensu, observability data is modelled as [events][events_reference_docs]. 
Some events contain metrics as part of their payload in the `metrics` property. 
Learn more about metrics in the [metrics reference docs](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-events/events/#metrics-attribute).

### Handler Filters

Handlers can apply a _filter_ to ensure that they only operate on matching events.
There are some [built-in filters][builtin_filters_docs] available for common use cases, or you can write your own using a JavaScript-based [Sensu Query Expression][sensu_query_expressions_docs].

In the exercise below, we will use the built-in filter [`has_metrics`][has_metrics_docs] to ensure that only events with a `metrics` property are processed by the handler.


### EXERCISE 2: Create a Handler that Stores Metrics to a Time-Series Database

#### Scenario

You want to store metrics data in a time-series database like [Prometheus] or [InfluxDB].

#### Solution

To accomplish this we will use the [sensu-influxdb-handler][sensu_influxdb_handler].
The handler sends metrics which are contained in events to an [InfluxDB] instance.

#### Steps

1. **Create a YAML file containing the handler configuration.**

   Copy and paste the following contents to a file named `influxdb.yaml`:

   ```yaml
   type: Handler
   api_version: core/v2
   metadata:
     name: influxdb
   spec:
     type: pipe
     command: >-
       sensu-influxdb-handler
     runtime_assets:
     - sensu/sensu-influxdb-handler:3.5.0
     timeout: 10
     secrets:
     - name: INFLUXDB_ADDR
       secret: influxdb_addr
     - name: INFLUXDB_HOST
       secret: influxdb_host
     - name: INFLUXDB_PORT
       secret: influxdb_port
     filters:
     - has_metrics
     mutator: ""
   ```
   
   > **Understanding the YAML:**
   > - The asset identifier `sensu/sensu-influxdb-handler:3.5.0` instructs the backend to download the handler executable from [Bonsai]. 
   > - The built-in filter [`has_metrics`][has_metrics_docs] is used to ensure that only events with metrics are processed by the handler.
   > - The handler is configured using environment variables and secrets available to the Sensu backend.
   

1. **Create the Handler Using the `sensuctl create` command.**

   ```shell
   sensuctl create -f influxdb.yaml
   ```

1. **Verify that the handler was created.**

   ```shell
   sensuctl handler list
   ```

   Do you see the `influxdb` handler in the output?
   If so, you've successfully created the handler!

## Discussion

In this lesson, we've only scratched the surface of what handlers can do.
You learned how to create a handler using a YAML file, use handler templating to format event data, use built-in filters, reference assets published to [Bonsai], and view a list of running handler configurations.

### Where Do Handlers Run?

Handlers are part of the [process stage][process_stage_docs] of the [observability pipeline][observability_pipeline_docs]. That means all of this happens on the Sensu backend, running the handlers in the same place where agents and checks send their observability data. 

### Monitoring as Code and Sensu's API-based Architecture

Because Sensu is [API-based][sensu_api_docs], we were able to create the handlers remotely, using `sensuctl` to push the desired configuration to the backend via the [Handler API][handler_api_docs].

We used a [Monitoring as Code][monitoring_as_code_blog_post] workflow, authoring the handler configurations with YAML files. 
We did not need to send any executable code, environment variables, or secrets along with this configuration. This means you can safely store the YAML configuration files in a git repo. 

The executables are stored as assets in [Bonsai] (or a private asset server), and the secrets are stored in [Vault].
The Sensu backend will automatically download them as needed.

All of this works together to allow you to quickly add, remove, or change handler configurations in a live system at any time, without the need to redeploy.

### Sensu Plugin SDK, Templating, and Configuration Overrides

Handlers developed using the [Sensu Plugin SDK][sensu_plugin_sdk] have built-in support for templating using the [Golang `text/template` package][go_template_package]. 
This can be used to merge observability data directly into the output, providing meaningful context and actionable alerts.

For example, an email handler could use an HTML message template that includes information like the status, number of occurences, or a customized playbook link.

**Example: HTML email Template**

```html
<html>
The entity {{ .Entity.Name }} has a status of {{ .Check.State }}. The entity has reported the same status for {{ .Check.Occurrences }} preceding events.<br>
<br>
The playbook for responding to this incident is available at https://{{ .Entity.Labels.playbook_host | default "wiki.example.com" }}/observability/alerts/{{ .Check.Labels.playbook_id }}.
</html>
```

Another feature of the SDK is the ability to [override handler configuration][sdk_configuration_options_docs] using metadata embedded in the event.

For example, you may want to send certain events to the `#ops` channel in RocketChat. 
The channel can be specifed in an annotation like `sensu.io/plugins/rocketchat/config/channel` on a per-check basis. 

**Example: Check Configuration Using Annotations to Override Destination Channel**

```yaml
---
type: CheckConfig
api_version: core/v2
metadata:
  name: nginx-status
  annotations:
    sensu.io/plugins/rocketchat/config/channel: "#ops"
spec:
  command: check-nginx-status.rb --url http://127.0.0.1:80/nginx_status
  publish: true
  subscriptions:
    - nginx
  interval: 30
  timeout: 10
  handlers:
    - rocketchat
```

For more examples of configuration overrides using annotations, read the handler documentation for some frequently-used handlers (i.e. [RocketChat][rocketchat_handler_annotations], [Slack][slack_handler_annotations], [Pagerduty][pagerduty_handler_annotations], and [ServiceNow][servicenow_handler_annotations]).


### Additional Use Cases

With handlers, you can also send event data [directly to a TCP or UDP socket][socket_handler_docs], trigger automated remediations using tools like [Rundeck] or [Ansible Tower], create and resolve incidents in [Pagerduty][pagerduty_alerts_docs], [ServiceNow], or [JIRA], and send alerts as [Slack messages][slack_alerts_docs] or [emails][email_alerts_docs].

For more complex workflows, multiple handlers can be [stacked][handler_stacks_docs] using [handler sets][handler_sets_docs].

Read more about handlers in the [handler reference documentation][handlers_docs].

## Learn more

- [[Documentation] "Sensu Handlers Overview" (docs.sensu.io)][process_stage_docs]
- [[Documentation] "Sensu Handlers Reference" (docs.sensu.io)][handlers_docs]
- [[Documentation] "Guide: Send Pagerduty alerts with Sensu" (docs.sensu.io)][pagerduty_alerts_docs]
- [[Documentation] "Guide: Send Slack alerts with Sensu" (docs.sensu.io)][slack_alerts_docs]
- [[Documentation] "Supported Handler Integrations" (docs.sensu.io)][supported_integrations_docs]
- [[Blog Post] "Reducing alert fatigue with GoAlert, Target’s on-call scheduling and notification platform" (sensu.io)][reduce_alert_fatigue_blogpost]

## Next steps

[Share your feedback on Lesson 04](https://github.com/sensu/sensu-go-workshop/issues/new?template=lesson_feedback.md&labels=feedback%2Clesson-04&title=Lesson%2004%20Feedback)

[Lesson 5: Introduction to Events][next lesson]

<!-- Other lessons -->
[setup_workshop]: https://github.com/sensu/sensu-go-workshop/blob/latest/SETUP.md
[next lesson]: ../05/README.md#readme
<!-- Product Links -->
[slack]: https://slack.com/
[rocketchat]: https://rocket.chat/
[bonsai]: https://bonsai.sensu.io/
[bonsai_handlers]: https://bonsai.sensu.io/assets?q=handler
[prometheus]: https://prometheus.io/
[influxdb]: https://www.influxdata.com/
[vault]: https://www.vaultproject.io/
[rundeck]: https://docs.sensu.io/sensu-go/latest/plugins/supported-integrations/rundeck/
[ansible tower]: https://docs.sensu.io/sensu-go/latest/plugins/supported-integrations/ansible/
[servicenow]: https://docs.sensu.io/sensu-go/latest/plugins/supported-integrations/servicenow/
[jira]: https://docs.sensu.io/sensu-go/latest/plugins/supported-integrations/jira/
<!-- GitHub Projects -->
[sensu_rocketchat_handler]: https://github.com/sensu/sensu-rocketchat-handler
[sensu_influxdb_handler]: https://github.com/sensu/sensu-influxdb-handler
[sensu_plugin_sdk]: https://github.com/sensu/sensu-plugin-sdk
<!-- Sensu Doc Links -->
[handler_template_docs]: https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-process/handler-templates/
[handler_api_docs]: https://docs.sensu.io/sensu-go/latest/api/handlers/#create-a-new-handler
[has_metrics_docs]: https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-filter/filters/#built-in-filter-has_metrics
[process_stage_docs]: https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-process/
[observability_pipeline_docs]: https://docs.sensu.io/sensu-go/latest/observability-pipeline/
[sensu_api_docs]: https://docs.sensu.io/sensu-go/latest/api/
[monitoring_as_code_blog_post]: https://thenewstack.io/monitoring-as-code-what-it-is-and-why-you-need-it/
[sdk_configuration_options_docs]: https://github.com/sensu/sensu-plugin-sdk#plugin-configuration-options
[socket_handler_docs]: https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-process/handlers/#tcpudp-handlers
[pagerduty_alerts_docs]: https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-process/send-pagerduty-alerts
[slack_alerts_docs]: https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-process/send-slack-alerts/
[email_alerts_docs]: https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-process/send-email-alerts/#create-the-email-handler-definition
[handlers_docs]: https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-process/handlers/
[handler_stacks_docs]: https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-process/handlers/#handler-stacks
[handler_sets_docs]: https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-process/handlers/#execute-multiple-handlers-handler-set
[go_template_package]: https://pkg.go.dev/text/template
[rocketchat_handler_annotations]: https://bonsai.sensu.io/assets/sensu/sensu-rocketchat-handler#annotations
[slack_handler_annotations]: https://bonsai.sensu.io/assets/sensu/sensu-slack-handler#annotations
[pagerduty_handler_annotations]: https://bonsai.sensu.io/assets/sensu/sensu-pagerduty-handler#argument-annotations
[servicenow_handler_annotations]: https://bonsai.sensu.io/assets/sensu/sensu-servicenow-handler#annotations
[supported_integrations_docs]: https://docs.sensu.io/sensu-go/latest/plugins/supported-integrations/
[reduce_alert_fatigue_blogpost]: https://sensu.io/blog/reducing-alert-fatigue-with-goalert
[builtin_filters_docs]: https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-filter/filters/#built-in-event-filters
[sensu_query_expressions_docs]: https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-filter/sensu-query-expressions/
[events_reference_docs]: https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-events/events/

