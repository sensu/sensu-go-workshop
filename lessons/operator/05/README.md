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

It's now commonly understood that there is great value in providing a lot of transparency into system state.
We design systems to emit, or allow the inspection of, as much detail as we can.
Our data processing and storage systems have evolved beyond the need to constrain or limit this information.

The more of this data we have available, the better off we are when trying to understand unexpected system behaviors.

### The Function of Time

Modern observability involves two categories of system information; data which is _emitted_, and data which is _queried_.
Broadly, emitted data is referred to as _logs_ or _events_, and queried or inspected data is known as _metrics_ or _telemetry_.
These differ primarily in their relationship to time.

Log messages are emitted at irregular and unpredictable times. 
They are emitted when _something happens_. 
Metrics however are queried, either by _polling_ on an periodic basis, or _ad hoc_ when someone is inspecting the system.

The unifying property of these two kinds of information is their _timestamp_.

### Structured Data

Where these two kinds of information differ though, is in structure.
Logs are presented as text strings, often in a human language. 
They are intended to be human-readable and have little to no structure.
Metrics are often presented as measurements in numerical form. 
They are intended to be machine-readable and are often structured as key-value pairs.

For a long time these two kinds of information were handled separately.
In Sensu, we have developed a way to bring them together in a unifying structure: the _event_.

## Working With Events

There is a constant stream of _observations_ in different formats coming from every layer of our systems.
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

You want to explore the Events API, or want to generate an event manually using common shell tools. 

### Solution

The Sensu API has an `/events` endpoint which can be used to `POST` an event to the backend.
Events sent to this API are processed in the same way as events generated by agents.
We can manually create an event using common shell tools like `curl` or PowerShell's `Invoke-RestMethod` cmdlet.

### Steps

1. **Create an Event Using the Events API.**

   Any tool that can `POST` to an HTTP endpoint can be used.
   For example, you could instrument your application to emit events directly to Sensu, using standard libraries for HTTP and JSON.
   
   For this exercise we will use `curl` on Mac/Linux and PowerShell's `Invoke-RestMethod` cmdlet on Windows. 

   **Mac and Linux:**

   ```shell
   curl -i -X POST -H "Authorization: Key ${SENSU_API_KEY}" \
        -H "Content-Type: application/json" \
        -d '{"entity":{"metadata":{"name":"i-424242"}},"check":{"metadata":{"name":"my-app"},"interval":30,"status":2,"output":"ERROR: failed to connect to database."}}' \
        "${SENSU_API_URL:-http://127.0.0.1:8080}/api/core/v2/namespaces/${SENSU_NAMESPACE:-default}/events"
   ```
   > _NOTE: The `curl` commands included in this lesson should generate output that starts with `HTTP/1.1 200 OK`, `HTTP/1.1 201 Created`, or `HTTP/1.1 202 Accepted`.
   > If you do not see this output, or if you received an error message, please ensure that you completed all of the steps in [Lesson2](/SETUP.md)._

   **Windows (PowerShell):**

   ```powershell
   Invoke-RestMethod `
     -Method POST `
     -Headers @{"Authorization" = "Key ${Env:SENSU_API_KEY}";} `
     -ContentType "application/json" `
     -Body '{"entity":{"metadata":{"name":"i-424242"}},"check":{"metadata":{"name":"my-app"},"interval":30,"status":2,"output":"ERROR: failed to connect to database."}}' `
     -Uri "${Env:SENSU_API_URL}/api/core/v2/namespaces/${Env:SENSU_NAMESPACE}/events"
   ```
    
   Let's break down what we just did there. 

   We `POST`ed an event payload, in JSON format, to a secure endpoint in the [Events API][events_api_docs].

   #### The URL
   
   The destination URL was `http://127.0.0.1:8080/api/core/v2/namespaces/default/events`.

   Let's break this URL down into its parts:
   - `http://127.0.0.1:8080`: The address and port of the backend.
   - `api/core/v2`: The base address of the Sensu API. 
     
     Notice the version in the path. 
     This is how Sensu guarantees to never break backwards compatibility! 
     
   - `namespaces/default`: The namespace to `POST` the event to. 
     
     You are likely using the `default` namespace, but just in case, the command checks to see if the `$SENSU_NAMESPACE` environment variable is set.

   - `events`: This is the root of the [Events API][events_api_docs].

   #### The Header

   The API key that we generated in [Lesson 3](../03/README.md#readme) was used to authenticate the request. 
   This is stored in the `$SENSU_API_KEY` environment variable.
   The command included an `Authorization` header, with a value using the format of `Key <api_key>`. 
   
   #### The Payload

   The payload included a JSON formatted `event` structure in the `POST` body. 
   This event is mimicing the kind of event that an automated `check` would generate.

   <details>
   <summary><strong>Example: </strong>Event Structure in JSON</summary>

   ```json
   {
     "entity": {
       "metadata":{ 
         "name": "i-424242"
       }
     },
     "check":{ 
       "metadata":{
         "name": "my-app"
         },
       "interval": 30,
       "status": 2,
       "output": "ERROR: failed to connect to database."
     }
   }
   ```
   </details>

   This `event` contains an `entity` with a `metadata` property, indicating that  `i-424242` is the name of the node the event came from.
   There is also a `check` structure describing the _check_ that generated it. 
   The check is named `my-app` and its `interval` says that it runs every 30 seconds.

   The remaining two are the `status` and `output`. 
   Following common UNIX conventions, if a `check` executable exits with a status other than `0`, it is considered an error.
   In such cases, the `output` is captured and included with the event.
   The output message indicates a database connection failure. 

   #### What Happens When Sensu Processes an Event?
   
   At minimum, the backend will store the most recent event for an entity, so we can inspect it via `sensuctl`.

   **View a List of Events**
   
   ```shell
   sensuctl event list
   ```

   **Example Output:**
   ```shell
      Entity         Check                     Output                   Status   Silenced             Timestamp                             UUID
    ──────────────── ──────────── ─────────────────────────────────────── ──────── ────────── ─────────────────────────────── ──────────────────────────────────────
     learn.sensu.io   helloworld   Hello, workshop world.                       1   false      2021-03-09 22:44:28 -0800 PST   8f0dfc70-8730-4b62-8f16-e4d8673f311f
     i-424242         my-app       ERROR: failed to connect to database.        2   false      2021-03-10 15:58:25 -0800 PST   0784e60b-96b1-4226-a151-13a645abdf67
   ```

   But what about the handler we configured in [Lesson 4](/lessons/04/README.md#readme)?
   If you expected that Sensu would process this event using that handler, you might have noticed that nothing happened.

**NEXT:** Let's move on to the next exercise to see how event handling works in practice.

## EXERCISE 2: Create an Event that Triggers an Alert
### Scenario

You want to create an event that triggers an alert via a handler.

### Solution

A `check` event needs to specify which handlers the event should be passed to.
This is part of the `check` configuration, which is included in the `event` context via the `handlers` property.
The backend will match this to the corresponding handler configurations.

Let's create an event that will be processed using the Rocket.Chat handler we configured in [Lesson 4](/lessons/04/README.md#readme).

### Steps

1. **Create an Event that Alerts in Rocket.Chat.**

   This step is the same as last time, but now includes a `handlers` property in the `check` structure. 
   The value is a simple list of handler names.
   The Rocket.Chat handler is named `rocketchat`.

   <details>
   <summary><strong>Example: </strong>Event with `handlers` Property</summary>

   ```json
   {
     "entity": {
       "metadata":{ 
         "name": "i-424242"
       }
     },
     "check":{ 
       "metadata":{
         "name": "my-app"
         },
       "interval": 30,
       "status": 2,
       "output": "ERROR    : failed to connect to database.",
       "handlers": ["rocketchat"]
     }
   }
   ```
   </details>

  
   Run the following command to create the event.

   **Mac and Linux:**

   ```shell
   curl \
     -i -X POST -H "Authorization: Key ${SENSU_API_KEY}" \
     -H "Content-Type: application/json" \
     -d '{"entity":{"metadata":{"name":"i-424242"}},"check":{"metadata":{"name":"my-app"},"interval":30,"status":2,"output":"ERROR: failed to connect to database.","handlers":["rocketchat"]}}' \
     "${SENSU_API_URL:-http://127.0.0.1:8080}/api/core/v2/namespaces/${SENSU_NAMESPACE:-default}/events"
   ```

   **Windows (PowerShell):**

   ```powershell
   Invoke-RestMethod `
     -Method POST `
     -Headers @{"Authorization" = "Key ${Env:SENSU_API_KEY}";} `
     -ContentType "application/json" `
     -Body '{"entity":{"metadata":{"name":"i-424242"}},"check":{"metadata":{"name":"my-app"},"interval":30,"status":2,"output":"ERROR: failed to connect to database.","handlers":["rocketchat"]}}' `
     -Uri "${Env:SENSU_API_URL}/api/core/v2/namespaces/${Env:SENSU_NAMESPACE}/events"
   ```

   
   This time, because this event defines handlers, the backend will generate an alert in Rocket.Chat. 
   To view the alert, open up [Rocket.Chat](http://127.0.0.1:5000/) and login using the default credentials (username: `sensu`, password: `sensu`)."

1. **Send an Event with a Successful Exit Status.**

   The last event we sent had an error state. 
   In most scenarios, this would open an incident. 
   Let's send one more event to indicate that our app is now restored to a functional state.

   This time the `status` will be set to 0 and the output message is `200 OK`.

   <details>
   <summary><strong>Example: </strong>Event with a Handler and Successful Exit Status</summary>

   ```json
   {
     "entity": {
       "metadata":{ 
         "name": "i-424242"
       }
     },
     "check":{ 
       "metadata":{
         "name": "my-app"
         },
       "interval": 30,
       "status": 0,
       "output": "200 OK",
       "handlers": ["rocketchat"]
     }
   }
   ```
   </details>

   Run the following command to create the event.

   **Mac and Linux:**

   ```shell
   curl \
     -i -X POST -H "Authorization: Key ${SENSU_API_KEY}" \
     -H "Content-Type: application/json" \
     -d '{"entity":{"metadata":{"name":"i-424242"}},"check":{"metadata":{"name":"my-app"},"interval":30,"status":0,"output":"200 OK","handlers":["rocketchat"]}}' \
     "${SENSU_API_URL:-http://127.0.0.1:8080}/api/core/v2/namespaces/${SENSU_NAMESPACE:-default}/events"
   ```

   **Windows (PowerShell):**

   ```powershell
   Invoke-RestMethod `
     -Method POST `
     -Headers @{"Authorization" = "Key ${Env:SENSU_API_KEY}";} `
     -ContentType "application/json" `
     -Body '{"entity":{"metadata":{"name":"i-424242"}},"check":{"metadata":{"name":"my-app"},"interval":30,"status":0,"output":"200 OK","handlers":["rocketchat"]}}' `
     -Uri "${Env:SENSU_API_URL}/api/core/v2/namespaces/${Env:SENSU_NAMESPACE}/events"
   ```

**NEXT:** Did the handler send messages to [Rocket.Chat](http://127.0.0.1:5000)?
If so you're ready to move on to the next lesson!

## Discussion
<!-- Summary --> 

In this lesson you learned about the event data structure, and how it unifies all kinds of information into a single data type.
We manually created some events with different statuses and learned how to configure events to get sent to the right handlers.

At the moment, our handler will just post every message that comes in directly to the channel. 
In the next lesson, we will use _filters_ to show how the handler can notice this status change and resolve the incident, while also preventing the chat from being spammed with redundant messages.


### Use Cases

Some common use cases for events:

- **Service Health Reporting** as the result of a service check, including [Nagios](https://www.nagios.org/)-style check scripts.
- **Collecting Metrics** using a service check or scraping a metrics API endpoint, like [Prometheus](https://prometheus.io/) exporters
- **Endpoint Discovery** and liveness monitoring by reporting the discovery of an endpoint
- **Dead Man's Switches** using events with a TTL, such as a backup script cron job

#### Service Health and Metrics Collection

We showed a simple example of a service health check in this exercise, and touched on metrics in the previous exercise. 
Both topics will be covered in more detail in [Lesson 8: Introduction to Checks](/lessons/operator/08/README.md#readme).

#### Dead Man's Switches

A [_dead man's switch_](https://en.wikipedia.org/wiki/Dead_man%27s_switch#Software) can alert on systems that have become unresponsive or are failing to report their status.
These are covered in more detail in [Lesson 7: Introduction to Agents & Entities](/lessons/operator/07/README.md#readme), and check TTLs, which are the underlying mechanism used for this, are covered in more detail in [Lesson 8: Introduction to Checks](/lessons/operator/08/README.md#readme).

#### Endpoint Discovery

Events may reference an `entity` that does not exist in Sensu.
When a backend processes an event that references an `entity` that is not known, a _proxy entity_ will be created.

Entities and proxy entities are covered in more detail in [Lesson 7: introduction to Agents & Entities](/lessons/operator/07/README.md#readme) and [Lesson 12: Introduction to Proxy Entities & Proxy Checks](/lessons/operator/12/README.md#readme).

## Learn More

- [[Documentation] "Sensu Events Reference" (docs.sensu.io)](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-events/events/)
- [[Documentation] "Sensu Events API Reference" (docs.sensu.io)](https://docs.sensu.io/sensu-go/latest/api/events/)
- [[Documentation] "Sensu Agent Events API Reference" (docs.sensu.io)](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-schedule/agent/#create-observability-events-using-the-agent-api)
- [[Blog Post] "Filling gaps in Kubernetes observability with the Sensu Kubernetes Events integration" (sensu.io)](https://sensu.io/blog/filling-gaps-in-kubernetes-observability-with-the-sensu-kubernetes-events-integration)

## Next Steps

[Share your feedback on Lesson 05](https://github.com/sensu/sensu-go-workshop/issues/new?template=lesson_feedback.md&labels=feedback%2Clesson-05&title=Lesson%2005%20Feedback)

[Lesson 6: Introduction to Filters](../06/README.md#readme)


[setup_workshop]: https://github.com/sensu/sensu-go-workshop/blob/latest/SETUP.md
[events_api_docs]: https://docs.sensu.io/sensu-go/latest/api/events/

