# Lesson 5: Introduction to Events

- [Overview](#overview)
- [Events are observations](#events-are-observations)
- [Use cases](#use-cases)
- [EXERCISE 1: create an event using curl and the Sensu Events API](#exercise-1-create-an-event-using-curl-and-the-Sensu-Events-API-no-op)
- [EXERCISE 2: create an event that triggers an alert](#exercise-2-create-an-event-that-triggers-an-alert)
- [Learn more](#learn-more)
- [Next steps](#next-steps)

## Overview

## Events are Observations

Sensu Events are generic containers for all types of observability data.
In Sensu, every observation is an "event", including metrics (telemetry data).

Sensu Events are structed data identified by a timestamp, entity name (e.g. server, cloud compute instance, container, or service), a check/event name, and optional key-value metadata called "labels" and "annotations".

**Example check structure:**

```json
{
  "metadata": {
    "labels": {},
    "annotations": {}
  },
  "entity": {},
  "check": {},
  "metrics": {},
  "id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "timestamp": 0123456789
}
```

A single Sensu Event payload may include one or more metric `points`, represented as a JSON object containing a `name`, `tags` (key/value pairs), `timestamp`, and `value` (always a float).

<details>
<summary><strong>Example event with check + metric data:</strong></summary>

```json
{
  "type": "Event",
  "api_version": "core/v2",
  "metadata": {
    "namespace": "default"
  },
  "spec": {
    "check": {
      "command": "wget -q -O- http://127.0.0.1:9099/metrics",
      "duration": 0.060790838,
      "executed": 1552506033,
      "handlers": [],
      "history": [
        {
          "executed": 1552505833,
          "status": 0
        },
        {
          "executed": 1552505843,
          "status": 0
        }
      ],
      "interval": 10,
      "is_silenced": false,
      "issued": 1552506033,
      "last_ok": 1552506033,
      "low_flap_threshold": 0,
      "metadata": {
        "name": "curl_timings",
        "namespace": "default"
      },
      "occurrences": 1,
      "occurrences_watermark": 1,
      "output": "api_http_requests_total{service='example', region='us-west-1'} 42\napi_request_duration_seconds{service='example', region='us-west-1'} 0.8273645",
      "output_metric_format": "graphite_plaintext",
      "output_metric_handlers": [
        "influx-db"
      ],
      "output_metric_tags": [
         {
            "name": "region",
            "value": "{{ .labels.region }}"
         }
      ],
      "proxy_entity_name": "",
      "publish": true,
      "round_robin": false,
      "runtime_assets": [],
      "state": "passing",
      "status": 0,
      "stdin": false,
      "subdue": null,
      "subscriptions": [
        "app:example"
      ],
      "timeout": 0,
      "total_state_change": 0,
      "ttl": 0
    },
    "entity": {
      "deregister": false,
      "deregistration": {},
      "entity_class": "agent",
      "last_seen": 1552495139,
      "metadata": {
        "name": "i-424242",
        "namespace": "default",
        "labels": {
           "region": "us-west-1"
        }
      },
      "redact": [
        "password",
        "passwd",
        "pass",
        "api_key",
        "api_token",
        "access_key",
        "secret_key",
        "private_key",
        "secret"
      ],
      "subscriptions": [
        "app:example",
        "entity:i-424242"
      ],
      "system": {
        "arch": "amd64",
        "hostname": "i-424242",
        "network": {
          "interfaces": [
            {
              "addresses": [
                "127.0.0.1/8",
                "::1/128"
              ],
              "name": "lo"
            },
            {
              "addresses": [
                "10.0.2.15/24",
                "fe80::5a94:f67a:1bfc:a579/64"
              ],
              "mac": "08:00:27:8b:c9:3f",
              "name": "eth0"
            }
          ]
        },
        "os": "linux",
        "platform": "centos",
        "platform_family": "rhel",
        "platform_version": "7.5.1804",
        "processes": null
      },
      "user": "agent"
    },
    "metrics": {
      "handlers": [
        "influxdb"
      ],
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
    "timestamp": 1552506033,
    "id": "431a0085-96da-4521-863f-c38b480701e9",
    "sequence": 1
  }
}
```

</details>

## Use cases

Events must reference an `entity` and contain one or both of the `metrics` and service health information objects (i.e. `check` data); e.g. an event that only has `entity` and `metrics` objects (and no `check` object) is a valid Sensu event.

Some common use cases for Sensu Events:

- **Reporting service health information** (e.g. the result of a service check execution, including Nagios-style check scripts)
- **Collecting metrics** using a service check or scraping a metrics API endpoint (e.g. Prometheus exporters)
- **Endpoint discovery** and liveness monitoring (e.g. reporting the discovery of an endpoint, or additional data/metadata about a known entity)
- **Dead mans switches** (e.g. emitting events<sup>*</sup> containing a TTL from a shell script, such as a backup script cron job)

_NOTE: dead man's switches are covered in more detail in [Lesson 7: Introduction to Agents & Entities](/lessons/operator/07/README.md#readme), and check TTLs are covered in more detail in [Lesson 8: Introduction to Checks](/lessons/operator/08/README.md#readme)._

> **PROTIP:** Events may reference an `entity` that does not exist in Sensu.
> When a Sensu backend processes an event that references an `entity` that is not present in the Entities API, a "proxy" entity will be created containing the entity properties provided in the event payload.
>
> _NOTE: entities and proxy entities are covered in more detail in [Lesson 7: introduction to Agents & Entities](/lessons/operator/07/README.md#readme) and [Lesson 12: Introduction to Proxy Entities & Proxy Checks](/lessons/operator/12/README.md#readme)._

## EXERCISE 1: create an event using curl and the Sensu Events API

1. Configure environment variables

   Verify the contents of `.envrc` or `.envrc.ps1` to ensure that `SENSU_API_URL`, `SENSU_NAMESPACE`, and `SENSU_API_KEY` are set to the correct values, then run the following commands:

   - **Self-guided workshop users:** use the default values for `SENSU_API_URL` (`http://127.0.0.1:8080`) and `SENSU_NAMESPACE` (`default`).
   - **Instructor-led workshop users:** use the values provided by your instructor for `SENSU_API_URL` and `SENSU_NAMESPACE`.

   **Mac and Linux users (`.envrc`):**

   ```shell
   source .envrc
   env | grep SENSU
   ```

   **Windows users (`.envrc.ps1`):**

   ```powershell
   . .\.envrc.ps1
   Get-ChildItem env: | Out-String -Stream | Select-String -Pattern SENSU
   ```

   > _NOTE: if you need help creating an API Key, please refer to [Lesson 3, Exercise 6: "Create an API Key for personal use"](/lessons/operator/03/README.md#exercise-6-create-an-api-key-for-personal-use)._

   Do you see the expected values for `SENSU_API_URL`,`SENSU_NAMESPACE`, and `SENSU_API_KEY`?
   If so, you're ready to move on to the next step!

1. Create an event using `curl` and the Sensu Events API

   ```
   curl -i -X POST -H "Authorization: Key ${SENSU_API_KEY}" \
        -H "Content-Type: application/json" \
        -d '{"entity":{"metadata":{"name":"i-424242"}},"check":{"metadata":{"name":"my-app"},"interval":30,"status":2,"output":"ERROR: failed to connect to database."}}' \
        "${SENSU_API_URL:-http://127.0.0.1:8080}/api/core/v2/namespaces/${SENSU_NAMESPACE:-default}/events"
   ```

   What happens when Sensu processes an event?
   At minimum, Sensu will store the event, so we can inspect it via `sensuctl` or the Sensu web app.

   ```shell
      Entity         Check                     Output                   Status   Silenced             Timestamp                             UUID
    ──────────────── ──────────── ─────────────────────────────────────── ──────── ────────── ─────────────────────────────── ──────────────────────────────────────
     learn.sensu.io   helloworld   Hello, workshop world.                       1   false      2021-03-09 22:44:28 -0800 PST   8f0dfc70-8730-4b62-8f16-e4d8673f311f
     i-424242         my-app       ERROR: failed to connect to database.        2   false      2021-03-10 15:58:25 -0800 PST   0784e60b-96b1-4226-a151-13a645abdf67
   ```

   But what about the handler we configured in [Lesson 4](/lessons/04/README.md#readme)?
   If you expected that Sensu would process this event using that handler, you might have noticed that nothing happened.

   > _NOTE: The `curl` commands included in this lesson should generate output that starts with `HTTP/1.1 200 OK`, `HTTP/1.1 201 Created`, or `HTTP/1.1 202 Accepted`.
   > If you do not see this output, or if you received an error message, please ensure that you completed all of the steps in [Setup](/SETUP.md), and/or ask your instructor for help._

**NEXT:** Let's move on to the next exercise to see how event handling works in practice.

## EXERCISE 1: create an event that triggers an alert

Sensu matches incoming events with the corresponding event pipelines using an event attribute called `handlers` (e.g. `handlers:["slack","pagerduty"]`).
Let's create an event that will be processed using the handler we configured in [Lesson 4](/lessons/04/README.md#readme).

1. **Configure environment variables.**

   Verify the contents of `.envrc` or `.envrc.ps1` to ensure that `SENSU_API_URL`, `SENSU_NAMESPACE`, and `SENSU_API_KEY` are set to the correct values, then run the following commands:

   - **Self-guided workshop users:** use the default values for `SENSU_API_URL` (`http://127.0.0.1:8080`) and `SENSU_NAMESPACE` (`default`).
   - **Instructor-led workshop users:** use the values provided by your instructor for `SENSU_API_URL` and `SENSU_NAMESPACE`.

   **Mac and Linux users (`.envrc`):**

   ```shell
   source .envrc
   env | grep SENSU
   ```

   **Windows users (`.envrc.ps1`):**

   ```powershell
   . .\.envrc.ps1
   Get-ChildItem env: | Out-String -Stream | Select-String -Pattern SENSU
   ```

   The output should include the expected values for `SENSU_API_URL`,`SENSU_NAMESPACE`, and `SENSU_API_KEY`.

   > _NOTE: if you need help creating an API Key, please refer to the [Lesson 3 EXERCISE 6: create an API Key for personal use](/lessons/operator/03/README.md#exercise-6-create-an-api-key-for-personal-use)._

1. **Create an event using `curl` and the Sensu Events API.**

   Do you notice anything different about the contents of the event in the next step?
   There's an additional property called `handlers: ["slack"]` that provides instructions on which pipeline(s) Sensu should use to process the event (in this case, the Slack handler we configured in Lesson 4).
   If the `handlers` property is omitted from an event, Sensu will simply store the event and no additional processing will be performed.
   Run the following command to create an event that will be processed using our Slack handler.

   **Mac and Linux users:**

   ```shell
   curl \
     -i -X POST -H "Authorization: Key ${SENSU_API_KEY}" \
     -H "Content-Type: application/json" \
     -d '{"entity":{"metadata":{"name":"i-424242"}},"check":{"metadata":{"name":"my-app"},"interval":30,"status":2,"output":"ERROR: failed to connect to database.","handlers":["slack"]}}' \
     "${SENSU_API_URL:-http://127.0.0.1:8080}/api/core/v2/namespaces/${SENSU_NAMESPACE:-default}/events"
   ```

   **Windows users (Powershell):**

   ```powershell
   Invoke-RestMethod `
     -Method POST `
     -Headers @{"Authorization" = "Key ${Env:SENSU_API_KEY}";} `
     -ContentType "application/json" `
     -Body '{"entity":{"metadata":{"name":"i-424242"}},"check":{"metadata":{"name":"my-app"},"interval":30,"status":2,"output":"ERROR: failed to connect to database.","handlers":["slack"]}}' `
     -Uri "${Env:SENSU_API_URL}/api/core/v2/namespaces/${Env:SENSU_NAMESPACE}/events"
   ```

1. **Create a resolution event using `curl` and the Sensu Events API.**

   Let's send one more event to indicate that our imaginary app is now restored to a functional state:

   **Mac and Linux users:**

   ```shell
   curl \
     -i -X POST -H "Authorization: Key ${SENSU_API_KEY}" \
     -H "Content-Type: application/json" \
     -d '{"entity":{"metadata":{"name":"i-424242"}},"check":{"metadata":{"name":"my-app"},"interval":30,"status":0,"output":"200 OK","handlers":["slack"]}}' \
     "${SENSU_API_URL:-http://127.0.0.1:8080}/api/core/v2/namespaces/${SENSU_NAMESPACE:-default}/events"
   ```

   **Windows users (Powershell):**

   ```powershell
   Invoke-RestMethod `
     -Method POST `
     -Headers @{"Authorization" = "Key ${Env:SENSU_API_KEY}";} `
     -ContentType "application/json" `
     -Body '{"entity":{"metadata":{"name":"i-424242"}},"check":{"metadata":{"name":"my-app"},"interval":30,"status":0,"output":"200 OK","handlers":["slack"]}}' `
     -Uri "${Env:SENSU_API_URL}/api/core/v2/namespaces/${Env:SENSU_NAMESPACE}/events"
   ```

**NEXT:** Did Sensu create messages in Slack?
If so you're ready to move on to the next step!

## Learn more

- [[Documentation] "Sensu Events Reference" (docs.sensu.io)](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-events/events/)
- [[Documentation] "Sensu Events API Reference" (docs.sensu.io)](https://docs.sensu.io/sensu-go/latest/api/events/)
- [[Documentation] "Sensu Agent Events API Reference" (docs.sensu.io)](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-schedule/agent/#create-observability-events-using-the-agent-api)
- [[Blog Post] "Filling gaps in Kubernetes observability with the Sensu Kubernetes Events integration" (sensu.io)](https://sensu.io/blog/filling-gaps-in-kubernetes-observability-with-the-sensu-kubernetes-events-integration)

## Next steps

[Share your feedback on Lesson 05](https://github.com/sensu/sensu-go-workshop/issues/new?template=lesson_feedback.md&labels=feedback&title=Lesson%2005%20Feedback)

[Lesson 6: Introduction to Filters](../06/README.md#readme)
