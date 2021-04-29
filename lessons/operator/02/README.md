# Lesson 2: Introduction to the Observability Data Model

- [What is Observability?](#what-is-observabilty)
- [Observability and structured events](#observability-and-structured-events)
- [Sensu Events](#sensu-events)
  - [Entities](#entities)
  - [Checks](#checks)
  - [Metrics](#metrics)
  - [Metadata](#metadata)
- [Learn more](#learn-more)
- [Next steps](#next-steps)

## What is Observability?

Observability is set of practices that include traditional monitoring (i.e. observability is a superset of monitoring).
The term "observability" originated in the discipline of control systems engineering, where it is defined as a measurement of how well a system's internal states could be inferred from its external outputs.
A system is observable if its current state can be determined in a finite time period using only the outputs of the system.
Observability is achieved by collecting and analyzing events, logs, metrics, and trace data from the systems we operate.

> _NOTE: Defining the terms "monitoring" and "observability" are non-goals for this workshop.
> However, a lot has been written on this topic and some of our favorite opinions on the matter are linked in the ["Learn more"](#learn-more) section, below._

## Observability and events

As a superset of monitoring, observability is, by necessity, event-based.
Monitoring is largely concerned with known indicators of a systems performance and health – metrics, logs, traces, and other signals that capture the various symptoms of the systems we operate – which can tell us _what_ is broken.
Observability provides insights into the inner workings of our systems.
Observability can tell us what the system was/is doing – or _attempting_ to do – and what the outcomes were/are from the system and/or user's perspective; for example, were we able to complete a users request to download a file or complete a transaction?

> **A brief aside about metrics vs events**
>
> Much of the attention around modern monitoring tools is largely oriented around metrics, and rightly so, because metrics provide a ton of insight into how our systems perform over time.
> The conventional wisdom around metrics supposes that basically any event – even log messages – can be represented as a measurement.
> At Sensu we agree that metrics are very versatile &ndash; they're easy and cheap to collect, store, and analyze &ndash; however, most time-series databases (storage systems that are optimized to store and analyze metric data) necessitate the omission of a lot of rich context when storing metrics, limiting the practical value of any given metric to comparison against other metrics.
>
> If metrics provide the broad strokes and omit context by design, what fills those gaps?
> **Events!**
> Events carry enough information that they can be interpreted on their own, unlike a single metric data point, which is generally only meaningful in the context of other metrics.
> A log message is an event.
> A metric can also be an event.
> Basically any observation can be captured as an event and stored with no loss in fidelity.

## Sensu Events

Sensu Events are generic containers for all types of observability data.
In Sensu, every observation is an "event", including metrics (telemetry data).

Sensu Events are structed data identified by a `timestamp`, `entity` name (e.g. server, cloud compute instance, container, or service), a check/event name, and optional key-value `metadata` called "labels" and "annotations".
Sensu Events also have an identifier (`id`) that is used to trace event processing in the observability pipeline.

<details>
<summary><strong>Example Sensu event structure:</strong></summary>

```json
{
  "metadata": {},
  "entity": {},
  "check": {},
  "metrics": {},
  "id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "timestamp": 1234567890
}
```

</details>

This generic container already provides a tremendous amount of flexibility in terms of the types of observability data that can be collected.
Future versions of Sensu Events may be extended to support additional data types and/or increase the flexibility of the system.

For now, let's take a closer look at the `entity`, `check`, `metrics`, and `metadata` objects to better understand how Sensu Events are structured.

### Entities

Sensu Entities are API resources that represent anything from a server, compute instance, container/pod, connected device (IoT gateways and devices), network device, application, or even a function.
Valid Sensu Events **must** be associated with an entity.
At minimum, a valid Sensu event needs to provide the `entity.metadata.name` and `entity.entity_class` fields.
If an event references an Entity that is already registered in the Sensu API, the Sensu platform will enrich the incoming event with the known entity properties (e.g. custom metadata and system details).

<details>
<summary><strong>Example Sensu event <code>entity</code> object:</strong></summary>

```json
{
  "metadata": {},
  "entity": {
    "metadata": {
      "name": "1-424242",
      "labels": {},
      "annotations": {}
    },
    "entity_class": "agent",
    "...": "..."
  },
  "check": {},
  "metrics": {},
  "id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "timestamp": 1234567890
}
```

</details>

More information about Sensu Entities is available in [Lesson 7: Introduction to Agents & Entities](/lessons/operator/07/README.md#readme).

### Checks

The Sensu Event `check` object is used to capture the results of a monitoring job (service check), or to describe a generic event (e.g. as emitted by an application).
At minimum, a valid Sensu Event that contains `check` data must include the following required fields:

- **`check.metadata.name`:** the event/check name (e.g. "nginx_status")
- **`check.output`:** the event details (e.g. service health information and/or metrics in plaintext or line protocol format)
- **`check.status`:** the event status (`0` = "ok", `1` = "warning", `2` = "critical", `3` = "unknown")

_NOTE: `4-255` are also supported `check.status` values, but these all currently map to "unknown"; future versions of Sensu may provide support for mapping these values to custom states._

<details>
<summary><strong>Example Sensu event <code>check</code> object:</strong></summary>

```json
{
  "metadata": {},
  "entity": {},
  "check": {
    "metadata": {
      "name": "service-health",
      "labels": {},
      "metadata": {}
    },
    "handlers": [],
    "output": "200 OK",
    "status": 0,
    "...": "..."
  },
  "metrics": {},
  "id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "timestamp": 1234567890
}
```

</details>

More information about Sensu Checks is available in [Lesson 8: Introduction to Checks](/lessons/operator/08/README.md#readme).

### Metrics

The Sensu Event `metrics` object is used to capture metrics in the [Sensu Metric Format](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-events/events/#metrics-attributes).
At minimum, a valid Sensu Event that contains `metrics` data must include the following required fields:

- **`metrics.points`:** An array containing metrics/measurements.
- **`metrics.points.[].name`:** The metric/measurement name (required for each metric point).
- **`metrics.points.[].timestamp`:** The metric/measurement timestamp (required for each metric point).
- **`metrics.points.[].value`:** The metric/measurement value (always a float; required for each metric point).

<details>
<summary><strong>Example Sensu event <code>check</code> object:</strong></summary>

```json
{
  "metadata": {},
  "entity": {},
  "check": {},
  "metrics": {
    "handlers": [],
    "points": [
      {
        "name": "api_http_requests.total",
        "tags": [
          {
            "name": "service",
            "value": "example"
          },
          {
            "name": "region",
            "value": "us-west-1"
          }
        ],
        "timestamp": 1552506033,
        "value": 42.0
      },
      {
          "name": "api_request_duration.seconds",
          "tags": [
            {
              "name": "service",
              "value": "example"
            },
            {
              "name": "region",
              "value": "us-west-1"
            }
          ],
          "timestamp": 1552506033,
          "value": 0.8273645
      }
    ]
  },
  "id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "timestamp": 1234567890
}
```

</details>

### Metadata

The Sensu Event `metadata` object is used to capture additional/custom event attributes as `labels` or `annotations`.
Labels and annotations are identical in format &ndash; they are represented as `"key": "value"` pairs, and all values must be strings &ndash; but they serve different purposes.

- **Labels**

  Labels are indexed by Sensu and used as selectors (e.g. for "filtering" resources).
  Good examples of labels include "environment" or "region" – metadata that can be used to group or select subsets of resources.

- **Annotations**

  Annotations are for storing additional data that may be used downstream in the Sensu observability pipeline, or by an external system that Sensu forwards data to.
  Good examples of annotations include things like configuration data (e.g. what Slack channel should Sensu alert in for a given entity/check/event), or other structured data (e.g. stringified JSON) containing instructions for third-party tools.
  Annotations are not indexed by Sensu, so they should not be used for grouping/selecting purposes.

<details>
<summary><strong>Example Sensu event <code>check</code> object:</strong></summary>

```json
{
  "metadata": {
    "labels": {
      "region": "us-west-2"
    },
    "annotations": {
      "sensu.io/plugins/slack/config/channel": "#dev"
    }
  },
  "entity": {},
  "check": {},
  "metrics": {},
  "id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "timestamp": 1234567890
}
```

</details>

## Learn more

- [[Documentation] "Sensu Events Reference" (docs.sensu.io)](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-events/events/)
- [[Documentation] "What is Observability?" (sumologic.com)](https://www.sumologic.com/glossary/observability/)
- [[Blog Post] "Monitoring and Observability", by Cindy Sridharan (copyconstruct.medium.com)](https://copyconstruct.medium.com/monitoring-and-observability-8417d1952e1c)
- [[Blog Post] "Monitoring versus Observability" (thenewstack.io)](https://thenewstack.io/monitoring-vs-observability-whats-the-difference/)

## Next steps

[Share your feedback on Lesson 02](https://github.com/sensu/sensu-go-workshop/issues/new?template=lesson_feedback.md&labels=feedback%2Clesson-02&title=Lesson%2002%20Feedback)

[Lesson 3: Introduction to Sensu Go](../03/README.md#readme)
