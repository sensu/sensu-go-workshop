# Lesson 8: Introduction to Checks

- [Overview](#overview)
- [Scheduling](#scheduling)
- [Subscriptions](#subscriptions)
- [Metrics collection](#metrics-collection)
  - [Output Metric Extraction](#output-metric-extraction)
  - [Output Metric Handlers](#output-metric-handlers)
  - [Output Metric Tags](#output-metric-tags)
- [Check templates](#check-templates)
- [Advanced Topics](#advanced-topics)
  - [TTLs (Dead Man Switches)](#ttls-dead-man-switches)
  - [Proxy requests (pollers)](#proxy-requests-pollers)
  - [Execution environment & environment variables](#execution-environment--environment-variables)
- [EXERCISE: configure a check](#exercise-configure-a-check)
- [EXERCISE: modify a check configuration using tokens](#exercise-modify-a-check-using-tokens)
- [Learn more](#learn-more)


## Overview

==TODO: service checks are "monitoring jobs".
Popularized by Nagios...
Simple specification...
Extensibility (any programming language in the world)...==

## Scheduling

## Subscriptions

## Metrics collection

### Output Metric Extraction

### Output Metric Handlers

==TODO: explain how metrics are processed in the pipeline (i.e. metrics not persisted to Sensu data store)==

### Output Metric Tags

==TODO: enrich PerfData metrics with `output_metric_tags` and check tokens!==

## Check Templates

==TODO: templating "monitoring jobs" with tokens...==

## Advanced Topics

### TTLs (Dead Man Switches)

### Proxy Requests (Pollers)

==TODO: reference lesson 12...==

### Execution environment & environment variables

## EXERCISE: configure a check

1. Configure a Sensu Check for monitoring system clock drift.

   Copy and paste the following contents to a file named `ntp.yaml`:

   ```yaml
   ---
   type: CheckConfig
   api_version: core/v2
   metadata:
     name: ntp
   spec:
     command: >-
       check_ntp_time -H time.google.com
       --warn {{ .labels.ntp_warn_threshold | default "0.5" }}
       --critical {{ .labels.ntp_crit_threshold | default "1.0" }}
     runtime_assets:
     - sensu/monitoring-plugins:2.6.0
     publish: true
     subscriptions:
     - ntp
     interval: 10
     timeout: 9
     handlers:
     - alert
     output_metric_format: nagios_perfdata
     output_metric_handlers:
     - metrics
     output_metric_tags:
     - name: entity
       value: "{{ .name }}"
     - name: namespace
       value: "{{ .namespace }}"
   ```

1. Create the Check using the `sensuctl create -f` command.

   ```shell
   sensuctl create -f ntp.yaml
   ```

   Verify that the Check was successfully created using the `sensuctl check list` command:

   ```shell
   sensuctl check list
   ```

   Example output:

   ```shell
     Name                                                                         Command                                                                         Interval   Cron   Timeout   TTL                           Subscriptions                            Handlers               Assets               Hooks   Publish?   Stdin?    Metric Format    Metric Handlers
   ────── ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── ────────── ────── ───────── ───── ──────────────────────────────────────────────────────────────── ────────── ──────────────────────────────── ─────── ────────── ──────── ───────────────── ─────────────────
     ntp    check_ntp_time -H time.nist.gov --warn {{ .labels.ntp_warn_threshold | default "0.5" }} --critical {{ .labels.ntp_crit_threshold | default "1.0" }}         30               10     0   system/linux,system/linux/ntp,system/windows,system/window/ntp              sensu/monitoring-plugins:2.6.0           true       false    nagios_perfdata   influxdb
   ```

**NEXT:** do you see the `ntp` check in the output?
If so, you're ready to move on to the next exercise!

## EXERCISE: modify check configuration using tokens

==TODO: show alternative check configuration workflows (e.g. `sensuctl create -f`, `sensuctl edit`, and the web app).==

## Learn more

## Next steps

[Lesson 9: Introduction to Check Hooks](../09/README.md#readme)
