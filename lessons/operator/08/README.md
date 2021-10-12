# Lesson 8: Introduction to Checks

- [Goals](#goals)
- [What are Checks?](#what-are-checks)
  - [Subscriptions and Check Scheduling](#subscriptions-and-check-scheduling)
  - [EXERCISE 1: Configure a Check](#exercise-1-configure-a-check)
- [Check Templates](#check-templates)
  - [EXERCISE 2: Modify a Check Using Tokens](#exercise-2-modify-a-check-using-tokens)
- [Metrics Collection and Extractions](#metrics-collection-and-extractions)
  - [Output Metric Extraction](#output-metric-extraction)
  - [Output Metric Tags](#output-metric-tags)
  - [Output Metric Handlers](#output-metric-handlers)
  - [EXERCISE 3: Tagging and Handling Metrics Using Checks](#exercise-3-tagging-and-handling-metrics-using-checks)
- [Discussion](#discussion)
  - [Subscriptions, Loose Coupling, and Elastic Infrastructure](#subscriptions-loose-coupling-and-elastic-infrastructure)
  - [Dead Man Switches (TTLs)](#dead-man-switches-ttls)
  - [Proxy Checks (Pollers)](#proxy-checks-pollers)
- [Learn More](#learn-more)
- [Next Steps](#next-steps)

## Goals

## What are Checks?

In Sensu, *checks* are monitoring jobs that are managed by the Sensu control plane, and executed by Sensu Agents.
A Sensu Check is a modern take on the traditional "service check" performed by a monitoring platform to determine the status of a system or service.

<details>
<summary><strong>Example:</strong> YAML Check Configuration</summary>

```yaml
type: CheckConfig
api_version: core/v2
metadata:
  name: node_exporter
spec:
  command: wget -q -O- http://127.0.0.1:{{ .labels.node_exporter_port | default "9100" }}/metrics
  runtime_assets: []
  publish: true
  interval: 30
  subscriptions:
  - linux
  timeout: 10
  ttl: 0
  output_metric_format: prometheus_text
  output_metric_handlers:
  - elasticsearch
  output_metric_tags:
  - name: entity
    value: "{{ .name }}"
  - name: region
    value: "{{ .labels.region | default 'unknown' }}"
```

</details>

Although service checks were originally popularized by Nagios (circa 1999-2002), they continue to fill a critical role in the modern era of cloud computing.
Sensu orchestrates service checks in a similar manner as cloud-native platforms like Kubernetes and Prometheus which use "Jobs" as a central concept for scheduling and running tasks.
Where Prometheus jobs are limited to HTTP GET requests, a Sensu check provides a significantly more flexible tool.

A service check can be any program that satisfies the following requirements:

1. Communicate status via exit status codes
2. Emit service status information and telemetry data via `STDOUT`

That's the entire specification (more or less)!
Service checks remain very useful because their simple specification makes it easy to extend monitoring to any area.
Service checks can be written in any programming or scripting language, including Bash, PowerShell, and MS-DOS scripts.

### Subscriptions and Check Scheduling

In Sensu, *subscriptions* are equivalent to topics in a traditional [pub/sub](https://en.wikipedia.org/wiki/Publish–subscribe_pattern) model. Agents are the subscribers and the backend is the publisher.

Checks are scheduled at pre-set intervals. The backend automatically publishes a request, and agents who are subscribed to the topic receive the request. The agent then performs the corresponding check, and sends the event data to the backend for processing via the observability pipeline.

Check scheduling is configured using the following attributes:

- **`publish`:** enables or disables scheduling
- **`interval` or `cron`:** the schedule in [cron format](https://crontab.guru/)
- **`subscriptions`:** the subscriptions to publish check requests to
- **`round_robin`:** limits check scheduling to one execution per request (useful for configuring pollers when there are multiple agent members in a given subscription)
- **`timeout`:** how much time, in seconds, to allow a check to run before terminating it

### EXERCISE 1: Configure a Check

#### Scenario

You have a collection of servers and you want to start monitoring their disk usage. You want this to run on all Mac, Linux, and Windows hosts that Sensu is aware of.

#### Solution

To accomplish this, we can configure a check that will periodically pull the disk usage metrics from your servers. We will use the `check-disk-usage` plugin available in [Bonsai](https://bonsai.sensu.io/) and configure it to run every 30 seconds. The agents are already configured to subscribe to `system/macos`, `system/windows`, and `system/linux` requests, so we can start running this right away.

#### Steps

1. **Configure a Check to Monitor Disk Usage.**

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

   Notice the values of `subscriptions` and `interval` – these will instruct Sensu to publish checks every 30 seconds on any agent with the `system/macos`, `system/windows`, or `system/linux` subscriptions.
   Agents opt-in to checks via their `subscriptions` configuration.

2. **Create the Check Using the `sensuctl create` Command.**

   ```shell
   sensuctl create -f disk.yaml
   ```

   Verify that the check was successfully created using the `sensuctl check list` command:

   ```shell
   sensuctl check list
   ```

   **Example Output:**

   ```shell
     Name                       Command                       Interval   Cron   Timeout   TTL                                            Subscriptions                                             Handlers              Assets              Hooks   Publish?   Stdin?   Metric Format   Metric Handlers
    ────── ───────────────────────────────────────────────── ────────── ────── ───────── ───── ────────────────────────────────────────────────────────────────────────────────────────────────── ────────── ────────────────────────────── ─────── ────────── ─────────────────────── ─────────────────
     disk   check-disk-usage --warning 80.0 --critical 90.0         30               10     0   system/macos,system/macos/disk,system/windows,system/windows/disk,system/linux,system/linux/disk              sensu/check-disk-usage:0.4.2           true       false
   ```

**NEXT:** Do you see the `disk` check in the output?
If so, you're ready to move on to the next exercise!

## Check Templates

Sensu's pub/sub configuration model makes monitoring configuration easier to manage at scale.
A single check definition can be used to collect monitoring data from hundreds or thousands of endpoints!

However, there are often cases when you need to override check configurations on a per-endpoint basis.
For these situations, Sensu provides a templating feature called [Tokens](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-schedule/tokens/).

Checks can be templated using placeholders called *tokens* which are replaced with entity information before the job is executed.

Tokens are references to entity attributes and metadata, wrapped in double curly braces (`{{  }}`).
Default values can also be provided as a fallback for [unmatched tokens](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-schedule/tokens/#unmatched-tokens).

**Examples:**

- **`{{ .name }}`:** replaced by the target entity name
- **`{{ .labels.url }}`:** replaced by the target entity "url" label
- **`{{ .labels.disk_warning | default "85%" }}`:** replaced by the target entity "disk_warning" label; if the label is not set then the default/fallback value of `85%` will be used

==TODO: add an example check config w/ .labels.disk_warning label==

Tokens can be used to configure dynamic monitoring jobs (e.g. enabling node-based configuration overrides for things like alerting threshold, etc).

Let's modify our check from the previous exercise using some tokens.

### EXERCISE 2: Modify a Check Using Tokens

#### Scenario

You've noticed that "one size fits all" is not true for your infrastructure. While the default disk check values are working for *most* of the servers in your system, certain servers are more sensitive to disk space usage. You want to use different warning/critical thresholds for them.

#### Solution

This can be accomplished using entity annotations, tokens, and a templated check.
First, by setting annotations on the entity we can configure a value that is unique to that entity.
Then, we can use a token to read that value when the check is executed, and give the check executable a different configuration. 

#### Steps

1. **Update the `disk` Check Configuration.**

   Modify `disk.yaml` with the following contents:

   ```yaml
   ---
   type: CheckConfig
   api_version: core/v2
   metadata:
     name: disk-usage
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

   This configuration makes the disk usage warning and critical thresholds configurable via entity annotations (`disk_usage_warning_threshold` and `disk_usage_critical_threshold`).
   We also provided default values, which are used if the annotation is not set.

1. **Update the Check Using `sensuctl create`.**

   ```shell
   sensuctl create -f disk.yaml
   ```

   Verify that the check was successfully created:

   ```shell
   sensuctl check info disk-usage --format yaml
   ```

1. TODO: Add annotation to an entity?

## Metrics Collection and Extractions

One common use case for checks is to collect system and service metrics (e.g. cpu, memory, or disk utilization; or api response times).

To learn more about Sensu's metrics processing capabilities, please visit the [Sensu Metrics reference documentation](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-schedule/metrics/).

### Output Metric Extraction

The agent provides built-in support for normalizing metrics generated by service checks in the following formats:

- **`prometheus_text`:** [Prometheus exposition format](https://prometheus.io/docs/instrumenting/exposition_formats/)
- **`influxdb_line`:** [InfluxDB line protocol](https://docs.influxdata.com/influxdb/cloud/reference/syntax/line-protocol/)
- **`opentsdb_line`:** [OpenTSDB line protocol](http://opentsdb.net/docs/build/html/user_guide/writing/index.html)
- **`graphite_plaintext`:** [Graphite plaintext protocol](https://graphite.readthedocs.io/en/latest/feeding-carbon.html)
- **`nagios_perfdata`:** [Nagios Performance Data](https://assets.nagios.com/downloads/nagioscore/docs/nagioscore/3/en/perfdata.html)

Configuring `output_metrics` causes the agent to extract metrics at the edge, before sending event data to the observability pipeline, optimizing performance of the platform at scale.

> **NOTE:** Sensu also provides support for collecting StatsD metrics, however these are consumed via the StatsD API &ndash; not collected as output of a check.

### Output Metric Tags

Metrics extracted with `output_metrics_format` can also be enriched using `output_metric_tags`.
Metric sources vary in verbosity. Some metric formats don't support tags (e.g. Nagios Performance Data), and those that do might be implemented in ways that don't provide enough contextual data.
In either case, Sensu's `output_metric_tags` are great for enriching collected metrics using entity data/metadata.
Sensu breathes new life into legacy monitoring plugins and other metric sources that generate the raw data you care about, but which lack tags or other context to make sense of the data. Simply configure `output_metric_tags` and Sensu will add the tag data to the resulting metrics.

**Example:** Metrics Tags

```yaml
output_metric_tags:
- name: application
  value: "my-app"
- name: entity
  value: "{{ .name }}"
- name: region
  value: "{{ .labels.region | default 'unknown' }}"
- name: store_id
  value: "store/{{ .labels.store_id | default 'none' }}"
```

Metric tag values can be provided as strings, or [tokens](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-schedule/tokens/) which can be used for generating dynamic tag values.

### Output Metric Handlers

In addition to `output_metric_format`, Sensu checks also provide configuration for dedicated `output_metric_handlers`, which are event handlers that are specially optimized for processing metrics.
If an event containing metrics is configured with one or more `output_metric_handlers`, a copy of the event is forwarded to the metric handler prior to Sensu's own event persistence; this specialized handling is implemented as a performance optimization to prioritize metric processing.

> **NOTE:** Checks may be configured with multiple `handlers` and `output_metric_handlers`, enabling service health checking, alerting, _and_ metrics collection in a single check.

### EXERCISE 3: Tagging and Handling Metrics Using Checks

#### Scenario

You have some existing metrics providers which provide output in Nagios format, which you want to store in InfluxDB. You also want to capture some additional information about the entity and have the metrics, along with it's context be handled by the pipeline.  

#### Solution

This can be accomplished by configuring the check to expect Nagios format via the `output_metric_format` option, and configuring a metrics-specific storage handler via `output_metric_handlers`. We can also add additional metadata to the event using `output_metric_tags`.

#### Steps

1. **Update the `disk` Check Configuration.**

   Modify `disk.yaml` with the following contents (adding `output_metric_format`, `output_metric_handlers`, and `output_metric_tags` fields):

   == TODO: Write the YAML for this! ==

   These fields instruct Sensu what metric format to expect as output from the check, which handler(s) should be used to process the metrics, and what tags should be added to the metrics.
   
   The metric formats Sensu can extract from check output as of this writing are: `nagios_perfdata`, `graphite_plaintext`, `influxdb_line`, `opentsdb_line`, and `prometheus_text`. StatsD metrics are also supported, but only via the Sensu Agent StatsD API.

2. **Update the Check using `sensuctl create`.**

   ```shell
   sensuctl create -f disk.yaml
   ```

   Verify that the check was successfully created:

   ```shell
   sensuctl check info disk-usage --format yaml
   ```

## Discussion

In this lesson you learned how to configure checks, which are periodic monitoring jobs, and how to select which hosts to run checks on using subscriptions. You also learned how to use tokens to template the check to have a unique configuration on each host, and covered some powerful tools to help modernize an older Nagios-based monitoring solution.

### Subscriptions, Loose Coupling, and Elastic Infrastructure

The publish/subscribe model is powerful in ephemeral or elastic infrastructures, where endpoint identifiers are unpredictable and break traditional host-based monitoring configuration.

Instead of configuring monitoring on a per-host basis, Sensu follows a service-based model, with one subscription per service (e.g. "postgres"), and agents ephemeral compute instances, simply register with a Sensu backend, subscribe to the relevant monitoring topics and begin reporting observability data.

Because subscriptions are [loosely coupled](https://en.wikipedia.org/wiki/Loose_coupling) references, Sensu checks can be configured with subscriptions that have no agent members and the result is simply a ["no-op"](https://en.wikipedia.org/wiki/NOP_(code)) (no action is taken).

### Dead Man Switches (TTLs)

The Agent Events API makes it easy to implement [Dead Man Switches](https://en.wikipedia.org/wiki/Dead_man%27s_switch) with as little as one line of Bash or PowerShell (see below for examples).

This can be implemented via the [`event.check.ttl` property](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-filter/filters/#check-attributes-available-to-filters) in the [event specification](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-events/events/#events-specification). This can be set to instruct Sensu to expect a continued stream of events. If there is a delay between events longer than the configured TTL, Sensu will generate a TTL event with a status like "Last check execution was 120 seconds ago".

Dead Man Switches are useful for monitoring jobs like nightly backup jobs.
For example, you could add a line at the end of a cron'ed Bash script to report on the backup status, with a ~25hr TTL. A failed backup job will result in a TTL event without any additional if/else-style conditional logic, or any additional code to send a "job failed" event. The absence of an "OK" event sent during the TTL window is all that is needed.

**Examples:** Dead Man Switches using TTLs

**MacOS/Linux**

```shell
curl -XPOST -H 'Content-Type: application/json' -d '{"check":{"metadata":{"name":"dead-mans-switch"},"output":"Alert if another event is not received in 30s","status":0,"ttl":30}}' 127.0.0.1:3031/events
```

**Windows (PowerShell)**

```powershell
Invoke-RestMethod -Method POST -ContentType "application/json" -Body '{"check":{"metadata":{"name":"dead-mans-switch"},"output":"Alert if another event is not received in 30s","status":0,"ttl":30}}' -Uri "${Env:SENSU_API_URL}/api/core/v2/namespaces/${Env:SENSU_NAMESPACE}/events"
```

### Proxy Checks (Pollers)

The Sensu scheduler can also checks for entities that are not actively managed by a Sensu agent. 
These monitoring jobs are called *proxy checks*, or checks that target a _proxy entity_. 

At a high level, a proxy check is a Sensu check with `proxy_requests`, which are query parameters Sensu will use to look for entities that should be targeted by the check.

In the following example, we would expect Sensu to find two (2) entities with `entity_class == "proxy"` and a `proxy_type` label set to `"website"`. For each matching entity, the backend will first replace the tokens using entity attributes. This would create one request to execute the command `nslookup sensu.io`, and one request to execute the command `nslookup google.com`.
To avoid redundant processing, we recommend using the `round_robin` attribute with proxy checks.

<details>
<summary><strong>Example:</strong> Proxy Check Configuration</summary>

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

</details>

Proxy entities are discussed in greater detail in [Lesson 13: Introduction to Proxy Entities & Proxy Checks](/lessons/operator/13/README.md#readme).

## Learn More

- [[Documentation] "Schedule observability data collection" (docs.sensu.io)](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-schedule/)
- [[Documentation] "Sensu Checks Reference" (docs.sensu.io)](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-schedule/checks/)
- [[Documentation] "Sensu Tokens Reference" (docs.sensu.io)](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-schedule/tokens/)
- [[Documentation] "Guide: Monitor server resources with Sensu Checks" (docs.sensu.io)](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-schedule/monitor-server-resources/)
- [[Documentation] "Guide: Collect service metrics with Sensu Checks" (docs.sensu.io)](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-schedule/collect-metrics-with-checks/)
- [[Documentation] "Guide: Collect Prometheus metrics with Sensu" (docs.sensu.io)](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-schedule/prometheus-metrics/)
- [[Blog Post] "Self-service monitoring checks in Sensu Go" (sensu.io)](https://sensu.io/blog/self-service-monitoring-checks-in-sensu-go)
- [[Blog Post] "The story of Nagios plugin support in Sensu (or, why service checks are so amazing)" (sensu.io)](https://sensu.io/blog/the-story-of-nagios-plugin-support-in-sensu)
- [[Blog Post] "Check output metric extraction with InfluxDB & Grafana" (sensu.io)](https://sensu.io/blog/check-output-metric-extraction-with-influxdb-grafana)
- [[Blog Post] "How to collect Prometheus metrics and store them anywhere (with Sensu!)" (sensu.io)](https://sensu.io/blog/how-to-collect-prometheus-metrics-and-store-them-anywhere-with-sensu)

## Next Steps

[Share your feedback on Lesson 08](https://github.com/sensu/sensu-go-workshop/issues/new?template=lesson_feedback.md&labels=feedback%2Clesson-08&title=Lesson%2008%20Feedback)

[Lesson 9: Introduction to Check Hooks](../09/README.md#readme)
