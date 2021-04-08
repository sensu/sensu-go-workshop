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

Sensu Checks are monitoring jobs that are managed by the Sensu platform (control plane) and executed by Sensu Agents.
A Sensu Check is a modern take on the traditional "service check" &ndash; a task (check) performed by the monitoring platform to determine the status of a system or service.

Although service checks were originally popularized by Nagios, they continue to fill a critical role in the modern era of cloud computing.
Sensu orchestrates service checks in a similar manner as cloud-native platforms like Kubernetes and Prometheus which use "Jobs" as a central concept for scheduling and running tasks.
Where Prometheus jobs are limited to HTTP GET requests (for good reason), a Sensu monitoring job ("check") provides a significantly more flexible tool.

A valid service check must satisfy the following requirements:

1. Communicate status via exit status codes
1. Emit service status information and telemetry data via STDOUT

That's the entire specification (more or less)!
Service checks have provided sustained value thanks to this incredibly simple specification, providing tremendous extensibility.
In fact, service checks can be written in any programming language in the world (including simple Bash and MS DOS scripts).

## Scheduling

The Sensu backend handles the scheduling of all monitoring jobs (checks).
Check scheduling is configured using the following attributes:

- **`publish`:** enables or disables scheduling
- **`interval` or `cron`:** the actual schedule upon which check requests will be published to the corresponding subscriptions
- **`subscriptions`:** the subscriptions to publish check requests to
- **`round_robin`:** limits check scheduling to one execution per request (useful for configuring pollers when there are multiple agent members in a given subscription)
- **`timeout`:** instructs the agent to terminate check execution after the configured number of seconds

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

### Proxy Checks (Pollers)

The Sensu check scheduler can orchestrate monitoring jobs for entities that are not actively managed by a Sensu agent.
These monitoring jobs are called "proxy checks", or checks that target a proxy entity.
Proxy checks are discussed in greater detail in [Lesson 13: Introduction to Proxy Entities & Proxy Checks](/lessons/operator/13/README.md#readme)._

At a high level, a proxy check is a Sensu check with `proxy_requests`, which are effectively query parameters Sensu will use to look for matching entities that should be targeted by the check.
Proxy requests are published to the configured subscription(s) once per matching entity.
In the following example, we would expect Sensu to find two (2) entities with `entity_class == "proxy"` and a `proxy_type` label set to "website"; for each matching entity, the Sensu backend will first replace the configured tokens using the corresponding entity attributes (i.e. one request to execute the command `nslookup sensu.io`, and one request to execute the command `nslookup google.com`).
To avoid redundant processing, we recommend using the `round_robin` attribute with proxy checks.


```yaml
---
type: CheckConfig
api_version: core/v2
metadata:
  name: proxy-nslookup
spec:
  command: >-
    nslookup {{ .annotations.proxy_host }}
  runtime_assets: []
  publish: true
  subscriptions:
  - workshop
  interval: 30
  timeout: 10
  round_robin: true
  proxy_requests:
    entity_attributes:
      - entity.entity_class == "proxy"
      - entity.labels.proxy_type == "website"

---
type: Entity
api_version: core/v2
metadata:
  name: proxy-a
  labels:
    proxy_type: website
  annotations:
    proxy_host: sensu.io
spec:
  entity_class: proxy

---
type: Entity
api_version: core/v2
metadata:
  name: proxy-b
  labels:
    proxy_type: website
  annotations:
    proxy_host: google.com
spec:
  entity_class: proxy
```

### Execution environment & environment variables

## EXERCISE: configure a check

1. Configure a Sensu Check for monitoring system clock drift.

   Copy and paste the following contents to a file named `disk.yaml`:

   ```yaml
   ---
   type: CheckConfig
   api_version: core/v2
   metadata:
     name: disk
   spec:
     command: check-disk-usage --warning 80.0 --critical 90.0
     runtime_assets:
     - sensu/check-disk-usage:0.4.2
     publish: true
     interval: 30
     subscriptions:
     - system/macos
     - system/macos/disk
     - system/windows
     - system/windows/disk
     - system/linux
     - system/linux/disk
     timeout: 10
     check_hooks: []
   ```

   Notice the values of `subscriptions` and `interval` – these will instruct the Sensu platform to schedule (or "publish") monitoring jobs every 30 seconds on any agent with the `system/macos`, `system/windows`, or `system/linux` subscriptions.
   Agents opt-in (or "subscribe") to monitoring jobs by their corresponding `subscriptions` configuration.

1. Create the Check using the `sensuctl create -f` command.

   ```shell
   sensuctl create -f disk.yaml
   ```

   Verify that the Check was successfully created using the `sensuctl check list` command:

   ```shell
   sensuctl check list
   ```

   Example output:

   ```shell
     Name                       Command                       Interval   Cron   Timeout   TTL                                            Subscriptions                                             Handlers              Assets              Hooks   Publish?   Stdin?   Metric Format   Metric Handlers
    ────── ───────────────────────────────────────────────── ────────── ────── ───────── ───── ────────────────────────────────────────────────────────────────────────────────────────────────── ────────── ────────────────────────────── ─────── ────────── ─────────────────────── ─────────────────
     disk   check-disk-usage --warning 80.0 --critical 90.0         30               10     0   system/macos,system/macos/disk,system/windows,system/windows/disk,system/linux,system/linux/disk              sensu/check-disk-usage:0.4.2           true       false
   ```

**NEXT:** do you see the `disk` check in the output?
If so, you're ready to move on to the next exercise!

## EXERCISE: modify check configuration using tokens

Sensu's service-oriented configuration model (as opposed to traditional host-based models) makes monitoring configuration easier to manage at scale.
A single check definition can be used to collect monitoring data from hundreds or thousands of endpoints!
However, there are often cases when you need to override various monitoring job configuration parameters on an per-endpoint basis.
For these situations, Sensu provides a templating feature called [Tokens](#).

Let's modify our check from the previous exercise using some Tokens.

1. **Update the `disk` check configuration template.**

   Modify `disk.yaml` with the following contents:

   ```yaml
   ---
   type: CheckConfig
   api_version: core/v2
   metadata:
     name: disk
   spec:
     command: >-
       check-disk-usage
       --warning {{ .annotations.disk_usage_warning_threshold | default "80.0" }}
       --critical {{ .annotations.disk_usage_critical_threshold | default "90.0" }}
     runtime_assets:
     - sensu/check-disk-usage:0.4.2
     publish: true
     interval: 30
     subscriptions:
     - system/macos
     - system/macos/disk
     - system/windows
     - system/windows/disk
     - system/linux
     - system/linux/disk
     timeout: 10
     check_hooks: []
   ```

   _NOTE: this example uses a [YAML multiline "block scalar"](https://yaml-multiline.info) (`>-`) for improved readability of a longer check `command` (without the need to escape newlines)._

   Did you notice?
   We're now making the disk usage warning and critical thresholds configurable via entity annotations (`disk_usage_warning_threshold` and `disk_usage_critical_threshold`)!
   Both of the tokens we're using here are offering default values, which will be used if the corresponding annotation is not set.

1. **Update the Check using `sensuctl create -f`.**

   ```
   sensuctl create -f disk.yaml
   ```

   Verify that the Check was successfully created using the `sensuctl check list` command:

   ```shell
   sensuctl check info disk --format yaml
   ```

## EXERCISE: collecting metrics with Sensu Checks

1. **Update the `disk` check configuration template.**

   Modify `disk.yaml` with the following contents (adding `output_metric_format`, `output_metric_handlers`, and `output_metric_tags` fields):

   ==TODO==

   These fields instruct Sensu what metric format to expect as output from the check, which handler(s) should be used to process the metrics, and what tags should be added to the metrics.
   The metric formats Sensu can extract from check output as of this writing are: `nagios_perfdata`, `graphite_plaintext`, `influxdb_line`, `opentsdb_line`, and `prometheus_text` (StatsD metrics are also supported, but only via the Sensu Agent StatsD API).

1. **Update the Check using `sensuctl create -f`.**

   ```
   sensuctl create -f disk.yaml
   ```

   Verify that the Check was successfully created using the `sensuctl check list` command:

   ```shell
   sensuctl check info disk --format yaml
   ```


## Learn more

## Next steps

[Lesson 9: Introduction to Check Hooks](../09/README.md#readme)
