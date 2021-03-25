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
     command: check_ntp_time -H time.google.com --warn 0.5 --critical 1.0
     runtime_assets:
     - sensu/monitoring-plugins:2.6.0
     publish: true
     subscriptions:
     - linux
     - system/linux
     interval: 30
     timeout: 10
     check_hooks: []
   ```

   Notice the values of `subscriptions` and `interval` – these will instruct the Sensu platform to schedule (or "publish") monitoring jobs every 30 seconds on any agent with the `linux` or `system/linux` subscriptions.
   Agents opt-in (or "subscribe") to monitoring jobs by their corresponding `subscriptions` configuration.

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

Sensu's service-oriented configuration model (as opposed to traditional host-based models) makes monitoring configuration easier to manage at scale.
A single check definition can be used to collect monitoring data from hundreds or thousands of endpoints!
However, there are often cases when you need to override various monitoring job configuration parameters on an per-endpoint basis.
For these situations, Sensu provides a templating feature called [Tokens](#).

Let's modify our check from the previous exercise using some Tokens.

1. Update the `ntp` check configuration template.

   Modify `ntp.yaml` with the following contents:

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
     - linux
     - system/linux
     interval: 30
     timeout: 10
     check_hooks: []
   ```

   _NOTE: this example uses a [YAML multiline "block scalar"](https://yaml-multiline.info) (`>-`) for improved readability of a longer check `command`._

   Did you notice?
   We're now making the NTP warning and critical thresholds configurable via entity labels (`ntp_warn_threshold` and `ntp_crit_threshold`)!
   Both of the tokens we're using here are offering default values, which will be used if the corresponding label is not set.

1. Update the Check using `sensuctl create -f`.

   ```
   sensuctl create -f ntp.yaml
   ```

   Verify that the Check was successfully created using the `sensuctl check list` command:

   ```shell
   sensuctl check list
   ```

## EXERCISE: collecting metrics with Sensu Checks

1. Update the `ntp` check configuration template.

   Modify `ntp.yaml` with the following contents (adding `output_metric_format`, `output_metric_handlers`, and `output_metric_tags` fields):

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
     - linux
     - system/linux
     interval: 30
     timeout: 10
     check_hooks: []
     output_metric_format: nagios_perfdata
     output_metric_handlers:
     - metrics
     output_metric_tags:
     - name: entity
       value: "{{ .name }}"
     - name: namespace
       value: "{{ .namespace }}"
   ```

   _NOTE: this example uses a [YAML multiline "block scalar"](https://yaml-multiline.info) (`>-`) for improved readability of a longer check `command`._

   These fields instruct Sensu what metric format to expect as output from the check, which handler(s) should be used to process the metrics, and what tags should be added to the metrics.
   The metric formats Sensu can extract from check output as of this writing are: `nagios_perfdata`, `graphite_plaintext`, `influxdb_line`, `opentsdb_line`, and `prometheus_text` (StatsD metrics are also supported, but only via the Sensu Agent StatsD API).

1. Update the Check using `sensuctl create -f`.

   ```
   sensuctl create -f ntp.yaml
   ```

   Verify that the Check was successfully created using the `sensuctl check list` command:

   ```shell
   sensuctl check list
   ```


## Learn more

## Next steps

[Lesson 9: Introduction to Check Hooks](../09/README.md#readme)
