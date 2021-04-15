# Lesson 4: Introduction to Handlers and Handler Sets

- [Overview](#overview)
- [Use Cases](#use-cases)
- [Pipe Handlers](#pipe-handlers)
- [Socket Handlers](#socket-handlers)
- [Handler Sets](#handler-sets)
- [Advanced topics](#advanced-topics)
  - [Handler templating](#handler-templating)
  - [Configuration overrides](#configuration-overrides)
- [EXERCISE 1: configure an alert handler](#exercise-1-configure-an-alert-handler)
- [EXERCISE 2: configure a metrics handler](#exercise-2-configure-a-metrics-handler)
- [Learn more](#learn-more)
- [Next steps](#next-steps)

## Overview

Handlers are actions the Sensu backend executes on incoming events (observability data).
Because Handler configuration determines what happens to events that flow through the Sensu pipeline, they are one of the most important building blocks of the Sensu solution.

Mutliple types of handlers are supported by Sensu, the most popular of which is the `pipe` handler.

Handler types:

- **Pipe handlers** send observability data (events) to arbitrary commands via standard input.
- **TCP/UDP handlers** forward observability data (events) to a remote socket.
- **Handler sets** group event handlers and streamline groups of actions to perform for certain types of events.

## Use Cases

Sensu event handlers can be used for a wide variety of workflows.
Some of the more popular uses cases are:

- **Send alerts** using tools like Slack
- **Create and resolve** incidents using tools like Pagerduty, ServiceNow, and JIRA
- **Store observability data** (including metrics) in data platforms like SumoLogic, Elasticsearch, and Splunk
- **Store metrics** to time-series databases (TSDBs) like Prometheus, InfluxDB, Graphite, Wavefront, and TimescaleDB
- **Trigger automated remediations** using tools like Rundeck or Ansible Tower

## Pipe Handlers

Pipe handlers are external commands that can consume event data via STDIN.

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

## Socket Handlers

TCP and UDP handlers enable Sensu to forward event data to arbitrary TCP or UDP sockets for external services to process.

**Example TCP and UDP handlers:**

```yaml
---
type: Handler
api_version: core/v2
metadata:
  name: example_tcp_handler
spec:
  type: tcp
  socket:
    host: 10.0.0.10
    port: 1234
  timeout: 30
```

```yaml
---
type: Handler
api_version: core/v2
metadata:
  name: example_udp_handler
spec:
  type: udp
  socket:
    host: 10.0.0.10
    port: 1234
  timeout: 30
```

## Handler Sets

Handler sets allow you to use a single named handler set to refer to groups of handlers.
Handler sets effectively enable a secondary publish/subscribe mechanism in Sensu, in which events are _published_ to a named handler set, and the configured handlers _subscribe_ to incoming events in a one-to-many fashion.
Handler sets with zero handlers will result in a "no-op".
Handler sets that reference handlers that don't exist will result in a "handler not found" error in the Sensu backend log.

> _NOTE: the primary publish/subscribe mechanism in Sensu is check and agent "subscriptions", which are covered in more detail in [Lesson 7: Introduction to Agents & Entities](/lessons/operator/07/README.md#readme) and [Lesson 8: Introduction to Checks](/lessons/operator/08/README.md#readme)._

**Example handler set:**

```yaml
---
type: Handler
api_version: core/v2
metadata:
  name: alert
spec:
  type: set
  handlers:
  - email
  - slack
  - microsoft-teams
```

## Advanced topics

### Handler templating

Sensu handlers developed using the Sensu Plugin SDK – including all officially supported handler integrations – provide built-in support for templating handler output (e.g. email notifications or Slack message contents).
Sensu handler templates use the [Golang `text/template` package](https://pkg.go.dev/text/template), and support generating text output that includes observabilty data from Sensu events, enabling users to provide include meaningful context and actionable alerts.

**Example HTML email template:**

```html
<html>
The entity {{ .Entity.Name }} has a status of {{ .Check.State }}. The entity has reported the same status for {{ .Check.Occurrences }} preceding events.<br>
<br>
The playbook for responding to this incident is available at https://{{ .Entity.Labels.playbook_host | default "wiki.example.com" }}/observability/alerts/{{ .Check.Labels.playbook_id }}.
</html>
```

To learn more, including a complete list of available fields, please visit the [handler template reference documentation](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-process/handler-templates/).

### Configuration overrides

Sensu handlers developed using the Sensu Plugin SDK – including all officially supported handler integrations – provide built-in support for overriding configuration parameters using check and entity metadata (annotations).

**Example:**

For example, the Sensu Slack handler must be configured with a default channel to send notifications to; the default channel is configured via the `sensu-slack-handler --channel` flag. This setting should be configured in your Slack handler template, but you can override this setting using the `sensu.io/plugins/slack/config/channel` annotation, which may be set on a per-check or per-entity basis.

Here's an example Slack handler template:

```yaml
---
type: Handler
api_version: core/v2
metadata:
  name: slack
spec:
  type: pipe
  command: >-
    sensu-slack-handler
    --channel "#sensu"
    --username SensuGo
    --description-template "{{ .Check.Output }}\n\n[namespace: {{.Entity.Namespace}}]"
    --webhook-url ${SENSU_WEBHOOK_URL}
  timeout: 0
  filters:
  - is_incident
  - not_silenced
  runtime_assets:
  - sensu/sensu-slack-handler:1.4.0
  secrets:
  - name: SLACK_WEBHOOK_URL
    secret: slack_webhook_url
```

Here's an example check configuration template which would override the channel provided in the handler template to the `--handler` flag.

```yaml
---
type: CheckConfig
api_version: core/v2
metadata:
  name: nginx-status
  annotations:
    sensu.io/plugins/slack/config/channel: "#ops"
spec:
  command: check-nginx-status.rb --url http://127.0.0.1:80/nginx_status
  publish: true
  subscriptions:
    - nginx
  interval: 30
  timeout: 10
  handlers:
    - slack
```

For more information on configuration overrides via check and entity annotations, please consult the corresponding handler documentation (examples: [Slack](https://bonsai.sensu.io/assets/sensu/sensu-slack-handler#annotations), [Pagerduty](https://bonsai.sensu.io/assets/sensu/sensu-pagerduty-handler#argument-annotations), and [ServiceNow](https://bonsai.sensu.io/assets/sensu/sensu-servicenow-handler#annotations)).

## EXERCISE 1: configure an alert handler

1. **Configure a Sensu Event Handler for sending alerts via Slack.**

   Copy and paste the following contents to a file named `slack.yaml`:

   ```yaml
   ---
   type: Handler
   api_version: core/v2
   metadata:
     name: slack
     labels:
       sensu.io/workflow: sensu-flow/v1
   spec:
     type: pipe
     command: >-
       sensu-slack-handler
       --channel ${SLACK_CHANNEL}
       --username SensuGo
       --description-template "{{ .Check.Output }}\n\n[namespace: {{.Entity.Namespace}}]"
     runtime_assets:
     - sensu/sensu-slack-handler:1.4.0
     timeout: 10
     filters: []
     secrets:
     - name: SLACK_WEBHOOK_URL
       secret: slack_webhook_url
     - name: SLACK_CHANNEL
       secret: slack_channel
   ```

1. **Create the Handler using the `sensuctl create -f` command.**

   ```shell
   sensuctl create -f slack.yaml
   ```

   Verify that your Handler was successfully created using the `sensuctl handler list` command:

   ```shell
   sensuctl handler list
   ```

   Example output:

   ```shell
     Name    Type   Timeout     Filters     Mutator            Execute            Environment Variables               Assets
    ─────── ────── ───────── ───────────── ───────── ─────────────────────────── ─────────────────────── ─────────────────────────────────
     slack   pipe        10   is_incident             RUN:  sensu-slack-handler                           sensu/sensu-slack-handler:1.4.0
   ```

**NEXT:** Do you see the `slack` handler in the output?
If so, you're ready to proceed to the next step!

## EXERCISE 2: configure a metrics handler

1. **Configure a Sensu Event Handler for sending metrics to a time-series database.**

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

1. **Create the Handler using the `sensuctl create -f` command.**

   ```shell
   sensuctl create -f influxdb.yaml
   ```

   Verify that your handler was created:

   ```shell
   sensuctl handler list
   ```

**NEXT:** Do you see the `influxdb` handler in the output?
If so, you're ready to move on to the next step!

## Learn more

- [[Documentation] "Sensu Handlers Overview" (docs.sensu.io)](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-process/)
- [[Documentation] "Sensu Handlers Reference" (docs.sensu.io)](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-process/handlers/)
- [[Documentation] "Guide: Send Pagerduty alerts with Sensu" (docs.sensu.io)](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-process/send-pagerduty-alerts/)
- [[Documentation] "Guide: Send Slack alerts with Sensu" (docs.sensu.io)](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-process/send-slack-alerts/)
- [[Documentation] "Supported Handler Integrations" (docs.sensu.io)](https://docs.sensu.io/sensu-go/latest/plugins/supported-integrations/)
- [[Blog Post] "Reducing alert fatigue with GoAlert, Target’s on-call scheduling and notification platform" (sensu.io)](https://sensu.io/blog/reducing-alert-fatigue-with-goalert)

## Next steps

[Share your feedback on Lesson 04](https://github.com/sensu/sensu-go-workshop/issues/new?template=lesson_feedback.md&labels=feedback&title=Lesson%2004%20Feedback)

[Lesson 5: Introduction to Events](../05/README.md#readme)
