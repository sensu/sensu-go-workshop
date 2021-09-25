# Lesson 5: Introduction to Events

- [Goals](#goals)
- [Events are Observations](#events-are-observations)
  - [System Transparency](#system-transparency)
  - [The Function of Time](#the-function-of-time)
  - [Structured Data](#structured-data)
- [Working With Events](#working-with-events)
  - [Event Data Structure](#event-data-structure) 
  - [EXERCISE 1: Create an Event Manually](#exercise-1-create-an-event-manually)
  - [EXERCISE 2: Create an Event that Triggers an Alert](#exercise-2-create-an-event-that-triggers-an-alert)
- [Discussion](#discussion)
- [Learn More](#learn-more)
- [Next Steps](#next-steps)

## Goals
In this lesson we will take a deeper look at events in Sensu, create an event manually using common shell tools, and show how events can trigger alerts. 
This lesson is intended for operators of Sensu, and assumes you have [set up a local workshop environment][setup_workshop].

## Events are Observations

We often use the term _observability_ to describe the set of practices around understanding and managing complex software systems.
But what do we mean by that?

Observability describes a quality of the system; a measure of how much visibility we have into its state and behaviors.

The more you _observe_, the richer your knowledge is of the system.
The richer that knowledge is, the better you can understand and reason about the system.

So what is it that we are observing?

### System Transparency 
From our vantage point looking at a dashboard, we can only observe what the system shares with us.
In traditional software development this involved informational output in the form of logs.
Later, some systems were instrumented to allow on-demand inspection.

It's now commonly understood that there is great value in providing a lot of transparency.
We design systems to emit or allowing the inspection of as much detail as we can.
Our data processing and storage systems have evolved past the need to constrain or limit this information.

The more of this data we have available, the better off we are when trying to understand unexpected system behaviors.

### The Function of Time

This model involves two categories of system information; data which is _emitted_, and data which is _queried_.
Broadly, emitted data is referred to as _logs_ or _events_, and queried or inspected data is known as _metrics_ or _telemetry_.
These differ primarily in their relationship to time.

Log messages are emitted at irregular and unpredictable times. 
They are emitted when _something happens_. 
Metrics however are _polled_, either on an periodic basis, or on-demand when someone is inspecting the system.

The unifying property of these two kinds of information is their _timestamp_.

### Structured Data

Where these two kinds of information differ though, is in structure.
Logs are presented as text strings, often in a human language. 
They are intended to be human-readable and have little to no structure.
Metrics are often presented as measurements in numerical form. 
They are intended to be machine-readable and are often structured as a key-value pair.

For a long time these two kinds of information were handled separately.
In Sensu, we have developed a way to bring them together in a unifying structure: the _event_.

## Working With Events

There is a constant stream of these _observations_ in different formats coming from every layer of our systems.
But we still don't have great tools for correlating this information.
Often what we are looking for is some kind of obvious change of condition, and the way we detect that change is by comparing measurements over time.

But just because two things happened at the same time, doesn't mean that they are related.

Historically, these two kinds of observation were separate and lacked relational information.
Metrics were often loose numerical measurements with no additional context, and logs often appeared out of sequence, making it difficult to group them into meaningful units of work.
There was also generally little forethought put into making sure that the system provided complete, accurate, and actionable information.


### Event Data Structure

In Sensu, we have solved part of this problem by unifying all observations into the `event` data structure.
Sensu operators work with different kinds of observations in the same cognitive space, to find meaningful relationships, define operating thresholds, predict system behaviors, and to discover the meaning within the data.

Sensu _events_ are structured data which include:
- a standard [UNIX `timestamp`](https://en.wikipedia.org/wiki/Unix_time)
- an `entity` name indicating the origin (e.g. a server, cloud compute instance, container, or service)
- a check/event name indicating what kind of event it is
- an optional `metrics` structure containing one or more `points`
- an optional `metadata` structure containing key-value pairs, `labels`, and `annotations`
- a UUID (`id`) used to trace event processing

<details>
<summary><strong>Example:</strong> Sensu Event Structure</strong></summary>

```json
{
  "timestamp": 1234567890,
  "entity": {},
  "check": {},
  "metrics": {},
  "metadata": {
    "labels": {},
    "annotations": {}
  },
  "id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
```

</details>

This generic container provides a tremendous amount of flexibility in terms of the types of observations that can be collected.
For all the details on what kind of data events can hold, read the [Events reference documentation](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-events/events/). 

Let's try making an event manually, using some common command-line tools.

## EXERCISE 1: Create an Event Manually
### Scenario
### Solution
### Steps

## EXERCISE 2: Create an Event that Triggers an Alert
### Scenario
### Solution
### Steps

## Discussion
<!-- Summary --> 

### Use Cases
<!-- service health, metrics, endpoint discovery, deadman's switch) -->

## Learn More

- [[Documentation] "Sensu Events Reference" (docs.sensu.io)](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-events/events/)
- [[Documentation] "Sensu Events API Reference" (docs.sensu.io)](https://docs.sensu.io/sensu-go/latest/api/events/)
- [[Documentation] "Sensu Agent Events API Reference" (docs.sensu.io)](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-schedule/agent/#create-observability-events-using-the-agent-api)
- [[Blog Post] "Filling gaps in Kubernetes observability with the Sensu Kubernetes Events integration" (sensu.io)](https://sensu.io/blog/filling-gaps-in-kubernetes-observability-with-the-sensu-kubernetes-events-integration)

## Next Steps

[Share your feedback on Lesson 05](https://github.com/sensu/sensu-go-workshop/issues/new?template=lesson_feedback.md&labels=feedback%2Clesson-05&title=Lesson%2005%20Feedback)

[Lesson 6: Introduction to Filters](../06/README.md#readme)


[setup_workshop]: https://github.com/sensu/sensu-go-workshop/blob/latest/SETUP.md

<!--  ------ OLD ------- DELETE BELOW THIS LINE ----------------------

# Use cases

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

## EXERCISE 1: create an event using shell commands and the Sensu Events API

1. Configure environment variables

   Setup the necessary environment variables by running one of the following commands:
   
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

   Do you see the expected values for `SENSU_API_URL`,`SENSU_NAMESPACE`, and `SENSU_API_KEY`?
   If so, you're ready to move on to the next step!

   > _NOTE: if you need help creating an API Key, please refer to [Lesson 3, Exercise 6: "Create an API Key for personal use"](/lessons/operator/03/README.md#exercise-6-create-an-api-key-for-personal-use)._

1. Create an event using shell commands and the Sensu Events API

   **Mac and Linux users:**

   ```shell
   curl -i -X POST -H "Authorization: Key ${SENSU_API_KEY}" \
        -H "Content-Type: application/json" \
        -d '{"entity":{"metadata":{"name":"i-424242"}},"check":{"metadata":{"name":"my-app"},"interval":30,"status":2,"output":"ERROR: failed to connect to database."}}' \
        "${SENSU_API_URL:-http://127.0.0.1:8080}/api/core/v2/namespaces/${SENSU_NAMESPACE:-default}/events"
   ```

   **Windows users (Powershell):**

   ```powershell
   Invoke-RestMethod `
     -Method POST `
     -Headers @{"Authorization" = "Key ${Env:SENSU_API_KEY}";} `
     -ContentType "application/json" `
     -Body '{"entity":{"metadata":{"name":"i-424242"}},"check":{"metadata":{"name":"my-app"},"interval":30,"status":2,"output":"ERROR: failed to connect to database."}}' `
     -Uri "${Env:SENSU_API_URL}/api/core/v2/namespaces/${Env:SENSU_NAMESPACE}/events"
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
   > If you do not see this output, or if you received an error message, please ensure that you completed all of the steps in [Setup](/SETUP.md)._

**NEXT:** Let's move on to the next exercise to see how event handling works in practice.

## EXERCISE 2: create an event that triggers an alert

Sensu matches incoming events with the corresponding event pipelines using an event attribute called `handlers` (e.g. `handlers:["rocketchat","pagerduty"]`).
Let's create an event that will be processed using the handler we configured in [Lesson 4](/lessons/04/README.md#readme).

1. **Configure environment variables.**

   Setup the necessary environment variables by running one of the following commands:

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

   The output should include the expected values for `SENSU_API_URL`, `SENSU_NAMESPACE`, and `SENSU_API_KEY`.

   > _NOTE: if you need help creating an API Key, please refer to the [Lesson 3 EXERCISE 6: create an API Key for personal use](/lessons/operator/03/README.md#exercise-6-create-an-api-key-for-personal-use)._

1. **Create an event using shell commands and the Sensu Events API.**

   Do you notice anything different about the contents of the event in the next step?
   There's an additional property called `handlers: ["rocketchat"]` that provides instructions on which pipeline(s) Sensu should use to process the event (in this case, the RocketChat handler we configured in Lesson 4).
   If the `handlers` property is omitted from an event, Sensu will simply store the event and no additional processing will be performed.
   Run the following command to create an event that will be processed using our RocketChat handler.

   **Mac and Linux users:**

   ```shell
   curl \
     -i -X POST -H "Authorization: Key ${SENSU_API_KEY}" \
     -H "Content-Type: application/json" \
     -d '{"entity":{"metadata":{"name":"i-424242"}},"check":{"metadata":{"name":"my-app"},"interval":30,"status":2,"output":"ERROR: failed to connect to database.","handlers":["rocketchat"]}}' \
     "${SENSU_API_URL:-http://127.0.0.1:8080}/api/core/v2/namespaces/${SENSU_NAMESPACE:-default}/events"
   ```

   **Windows users (Powershell):**

   ```powershell
   Invoke-RestMethod `
     -Method POST `
     -Headers @{"Authorization" = "Key ${Env:SENSU_API_KEY}";} `
     -ContentType "application/json" `
     -Body '{"entity":{"metadata":{"name":"i-424242"}},"check":{"metadata":{"name":"my-app"},"interval":30,"status":2,"output":"ERROR: failed to connect to database.","handlers":["rocketchat"]}}' `
     -Uri "${Env:SENSU_API_URL}/api/core/v2/namespaces/${Env:SENSU_NAMESPACE}/events"
   ```

1. **Create a resolution event using shell commands and the Sensu Events API.**

   Let's send one more event to indicate that our imaginary app is now restored to a functional state:

   **Mac and Linux users:**

   ```shell
   curl \
     -i -X POST -H "Authorization: Key ${SENSU_API_KEY}" \
     -H "Content-Type: application/json" \
     -d '{"entity":{"metadata":{"name":"i-424242"}},"check":{"metadata":{"name":"my-app"},"interval":30,"status":0,"output":"200 OK","handlers":["rocketchat"]}}' \
     "${SENSU_API_URL:-http://127.0.0.1:8080}/api/core/v2/namespaces/${SENSU_NAMESPACE:-default}/events"
   ```

   **Windows users (Powershell):**

   ```powershell
   Invoke-RestMethod `
     -Method POST `
     -Headers @{"Authorization" = "Key ${Env:SENSU_API_KEY}";} `
     -ContentType "application/json" `
     -Body '{"entity":{"metadata":{"name":"i-424242"}},"check":{"metadata":{"name":"my-app"},"interval":30,"status":0,"output":"200 OK","handlers":["rocketchat"]}}' `
     -Uri "${Env:SENSU_API_URL}/api/core/v2/namespaces/${Env:SENSU_NAMESPACE}/events"
   ```

**NEXT:** Did Sensu create messages in RocketChat?
If so you're ready to move on to the next step!

Note: You can login to the workshop-provided Rocketchat instance at `http://127.0.0.1:5000` with `user: trainee` `password: workshop`. 

-->
