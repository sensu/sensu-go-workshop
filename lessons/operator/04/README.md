# Lesson 4: Introduction to Handlers and Handler Sets

- [Overview](#overview)
- [Use Cases](#use-cases)
- [Pipe Handlers](#pipe-handlers)
- [Socket Handlers](#socket-handlers)
- [Handler Sets](#handler-sets)
- [Advanced topics](#advanced-topics)
  - [Handler templating](#handler-templating)
  - [Configuration overrides](#configuration-overrides)
- [EXERCISE: configure an alert handler](#exercise-configure-an-alert-handler)
- [EXERCISE: configure a metrics handler](#exercise-configure-a-metrics-handler)
- [Learn more](#learn-more)

## Overview

==TODO: handlers are the killer feature of the Sensu platform...==

## Use Cases

==TODO: send alerts, route event/telemetry data, trigger remediation action...==

## Pipe Handlers

## Socket Handlers

## Handler Sets

## Advanced topics

### Handler templating

### Configuration overrides

## EXERCISE: configure an alert handler

1. Create a Sensu Event Handler template for sending alerts via Slack.

   Copy and paste the following contents to a file named `slack.yaml`:

   ```
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
     - sensu/sensu-slack-handler:1.3.2
     timeout: 10
     filters:
     - is_incident
     secrets:
     - name: SLACK_WEBHOOK_URL
       secret: slack_webhook_url
     - name: SLACK_CHANNEL
       secret: slack_channel
   ```

1. Create the Handler using the `sensuctl create -f` command.

   ```
   sensuctl create -f slack.yaml
   ```

   Verify that your Handler was successfully created using the `sensuctl handler list` command:

   ```
   sensuctl handler list
   ```

   If you see the `slack` handler in the output, you're ready to proceed to the next step!

   ```
     Name    Type   Timeout     Filters     Mutator            Execute            Environment Variables               Assets
    ─────── ────── ───────── ───────────── ───────── ─────────────────────────── ─────────────────────── ─────────────────────────────────
     slack   pipe        10   is_incident             RUN:  sensu-slack-handler                           sensu/sensu-slack-handler:1.4.0
   ```

## EXERCISE: configure a metrics handler

1. Create a Sensu Event Handler template for sending metrics to a time-series database.

   Copy and paste the following contents to a file named `influxdb.yaml`:

   ```
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

## Learn more

## Next steps

[Lesson 5: Introduction to Events](../05/README.md#readme)
