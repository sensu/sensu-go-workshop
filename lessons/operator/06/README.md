# Lesson 6: Introduction to Filters

- [Goals](#goals)
- [Filters and Handlers](#filters-and-handlers)
- [Sensu Query Expressions (SQEs)](#sensu-query-expressions-sqes)
- [Built-in Filters and Helper Functions](#built-in-filters-and-helper-functions)
- [EXERCISE 1: Use a Built-in Filter to Only Alert on Problems](#exercise-1-use-a-built-in-filter-to-only-alert-on-problems)
- [EXERCISE 2: Create a Custom Filter to Prevent Repeated Alerts](#exercise-2-create-a-custom-filter-to-prevent-repeated-alerts)
- [EXERCISE 3: Using a Custom Filter in a Handler](#exercise-3-using-a-custom-filter-in-a-handler)
- [Discussion](#discussion)
- [Learn More](#learn-more)
- [Next Steps](#next-steps)

## Goals

In this lesson we will discuss using _filters_ in the observability pipeline. In the hands-on exercises you will use the built-in filters, then create and apply a custom filter. This lesson is intended for operators of Sensu, and assumes you have [set up a local workshop environment][setup_workshop].

## Filters and Handlers

Sensu filters provide control over which events get processed by downstream handlers.
The filter applies conditionals to an event stream in realtime using Sensu Query Expressions (SQEs).

By default, a Sensu handler will process all events sent to it. 
This is rarely desired behavior, so most handlers will have event filters applied to limit which events it processes.

## Sensu Query Expressions (SQEs)

Filters are written using simple JavaScript, known as [Sensu Query Expressions (SQEs)](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-filter/sensu-query-expressions/).
SQEs are EMCAScript 5 expressions that return either `true` or `false`.

SQEs can be as simple as basic comparison operations – "less than" (`<`) or "greater than" (`>`) "equal to" (`==`) or "not equal" (`!=`) – or as complex as small JavaScript programs.
You can even package filter logic as JavaScript libraries and import them into the sandbox environment using Dynamic Runtime Assets!

_NOTE: Dynamic Runtime Assets are covered in greater detail in [Lesson 10: Introduction to Assets](/lessons/operator/10/README.md#readme)._

## Built-in Filters and Helper Functions

Sensu includes built-in event filters and helper functions to customize event pipelines for metrics and alerts.

**Built-In Filters**

- **`is_incident`:** only process warnings (`"status": 1`), critical (`"status": 2`), other (unknown or custom status), and resolution events.
- **`not_silenced`:** prevents processing of events that include the `silenced` attribute.
- **`has_metrics`:** only process events containing Sensu Metrics.

**Helper Functions**

- **`hour()`:** a custom SQE function that returns the hour of a UNIX epoch timestamp in UTC and 24-hour time notation (e.g. `hour(event.timestamp) >= 17`)
- **`weekday()`:** a custom SQE function that returns a number that represents the day of the week of a UNIX epoch timestamp (Sunday is `0`; e.g. `weekday(event.timestamp) == 0`)

## EXERCISE 1: Use a Built-in Filter to Only Alert on Problems
### Scenario

You want to reduce the amount of alerts that are going to your chat-ops channel. 
You'd like to only get ones that indicate there's some kind of problem or possible incident.

### Solution

To accomplish this, we'll put a filter in front of the Rocket.Chat handler.
We will use the built-in filter `is_incident` on the `rocketchat` handler.
This filter will only let events be processed by the handler if they have a non-zero exit status.

### Steps

Let's use a built-in filter with a handler we configured in [Lesson 4](/lessons/operator/04/README.md#readme).

1. **Modify a handler configuration template to use a built-in filter.**

   Let's modify the handler template we created in [Lesson 4](/lessons/operator/04/README.md#readme) (i.e. `rocketchat.yaml`), and replace the `filters: []` line with the following:

   ```yaml
   filters:
   - is_incident
   ```

1. **Update the handler using `sensuctl create`.**

   ```shell
   sensuctl create -f rocketchat.yaml
   ```

   Now verify that the handler configuration was updated by viewing the handler info.

   ```shell
   sensuctl handler info rocketchat --format yaml
   ```

1. **Test the filter.**

   The `is_incident` filter will prevent processing of healthy (`"status": 0`) events, unless they are resolving an incident.
   Let's send some events to see this behavior in action.

   The following event will be filtered:

   **Mac and Linux:**

   ```shell
   curl -i -X POST -H "Authorization: Key ${SENSU_API_KEY}" \
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

   The following event will be processed:

   **Mac and Linux:**

   ```shell
   curl -i -X POST -H "Authorization: Key ${SENSU_API_KEY}" \
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

   Try running these commands multiple times in different combinations and observing the behavior in your local [Rocket.Chat instance](https://127.0.0.1:5000).

   The first occurrence of a `"status": 0` event following an active incident is treated as a "resolution" event, and will be processed; but subsequent occurrences of the `"status": 0` event will be filtered.

   Every occurrence of the `"status": 1` event will be processed, but we wouldn't typically want that to happen (because "alert fatigue").
   Let's move on to the next exercise to learn how to modify that behavior.

**NEXT:** If you have applied the built-in `is_incident` filter and observed it working as described above, then you're ready to move on to the next exercise.

## EXERCISE 2: Create a Custom Filter to Prevent Repeated Alerts
### Scenario

After applying the built-in `is_incident` feature, you now notice that during incidents you get repeated error messages in chat.
You want to reduce the alert fatigue so that you only get one error messages when the incident starts, then get another when it's over.

### Solution

To accomplish this we will write a custom filter using JavaScript.
Internally, Sensu maintains a counter on events which tracks how many times the event has been triggered.
We can use that in our filter to let only the first instance of the event through to the handler. 

### Steps

1. **Configure a filter to reduce alert fatigue.**

   The backend maintains a series of event counters that are effective for managing alert frequency.
   These counters include the `occurrences` counter, and the `occurrences_watermark` counter.
   The `occurrences` property is visible in the event detail output from a `sensuctl event info` command:

   **Mac and Linux** 
   
   ```shell
   sensuctl event info learn.sensu.io helloworld --format json | grep occurrences
   ```

   **Windows (PowerShell)**
   ```powershell
   sensuctl event info learn.sensu.io helloworld --format json | Select-String "occurrences"
   ```

   **Example Output:**

   ```json
   "occurrences": 8,
   "occurrences_watermark": 8,   
   ```

   Let's create a filter that only processes the first occurrence of an incident, and then again only once every hour.

   Copy the following contents to a file named `filter-repeated.yaml`:

   ```yaml
   ---
   type: EventFilter
   api_version: core/v2
   metadata:
     name: filter-repeated
   spec:
     action: allow
     expressions:
     - event.check.occurrences == 1 || event.check.occurrences % (3600 / event.check.interval) == 0
   ```

   _NOTE: for more information on this filter expression – specifically including the modulo operator (`%`) or "remainder" calculation – please visit the [sensu/catalog project on GitHub](https://github.com/sensu/catalog/blob/main/shared/filters/filter-repeated-hourly.yaml)._

1. **Create the `filter-repeated` filter using `sensuctl`.**

   ```shell
   sensuctl create -f filter-repeated.yaml
   ```

   Then verify that the filter was successfully created:

   ```shell
   sensuctl filter list
   ```

   **Example Output:**
   ```
             Name         Action                                            Expressions
    ───────────────── ──────── ────────────────────────────────────────────────────────────────────────────────────────────────
     filter-repeated   allow    (event.check.occurrences == 1 || event.check.occurrences % (3600 / event.check.interval) == 0)
   ```
   Our custom `filter-repeated` filter is now available to use with handlers!

**NEXT:** If you see your `filter-repeated` filter, you're ready to move on to the next exercise.

## EXERCISE 3: Using a Custom Filter in a Handler

### Scenario

You just created a custom filter and now you want to update your chat handler to use it.

### Solution

Handlers can have multiple filters stacked in order. 
Combining the built-in `is_incident` filter with the custom `filter-repeated` filter we just made, will result in only the first failure event showing up in chat.
To add this, we will edit our handler configuration to add `filter-repeated` to the `filters` property.

### Steps

1. **Modify the Rocket.Chat handler configuration to use a custom filter.**

   Let's modify the handler template we created in [Lesson 4](/lessons/operator/04/README.md#readme), `rocketchat.yaml`, and add `filter-repeated` to the `filters` field:

   ```yaml
   filters:
   - is_incident
   - filter-repeated
   ```

1. **Update the handler using `sensuctl create`.**

   ```shell
   sensuctl create -f rocketchat.yaml
   ```

   Now verify that the handler configuration was updated by viewing the handler configration using `sensuctl handler info`

   ```shell
   sensuctl handler info rocketchat --format yaml
   ```

1. **Test the filter.**

   The `filter-repeated` filter will prevent repeat processing of events (only allowing repeat processing once per hour).
   Let's send some events to see this behavior in action.

   The following event will be _processed_ (the first occurrence of a critical severity event):

   **Mac and Linux:**

   ```shell
   curl -i -X POST -H "Authorization: Key ${SENSU_API_KEY}" \
        -H "Content-Type: application/json" \
        -d '{"entity":{"metadata":{"name":"i-424242"}},"check":{"metadata":{"name":"my-api"},"interval":30,"status":2,"output":"ERROR: failed to connect to database.","handlers":["rocketchat"]}}' \
        "${SENSU_API_URL:-http://127.0.0.1:8080}/api/core/v2/namespaces/${SENSU_NAMESPACE:-default}/events"
   ```

   **Windows (PowerShell):**

   ```powershell
   Invoke-RestMethod `
     -Method POST `
     -Headers @{"Authorization" = "Key ${Env:SENSU_API_KEY}";} `
     -ContentType "application/json" `
     -Body '{"entity":{"metadata":{"name":"i-424242"}},"check":{"metadata":{"name":"my-api"},"interval":30,"status":2,"output":"ERROR: failed to connect to database.","handlers":["rocketchat"]}}' `
     -Uri "${Env:SENSU_API_URL}/api/core/v2/namespaces/${Env:SENSU_NAMESPACE}/events"
   ```

   The following event will be _filtered_ (the second occurrence of a critical severity event):

   **Mac and Linux:**

   ```shell
   curl -i -X POST -H "Authorization: Key ${SENSU_API_KEY}" \
        -H "Content-Type: application/json" \
        -d '{"entity":{"metadata":{"name":"i-424242"}},"check":{"metadata":{"name":"my-api"},"interval":30,"status":2,"output":"ERROR: failed to connect to database.","handlers":["rocketchat"]}}' \
        "${SENSU_API_URL:-http://127.0.0.1:8080}/api/core/v2/namespaces/${SENSU_NAMESPACE:-default}/events"
   ```

   **Windows (PowerShell):**

   ```powershell
   Invoke-RestMethod `
     -Method POST `
     -Headers @{"Authorization" = "Key ${Env:SENSU_API_KEY}";} `
     -ContentType "application/json" `
     -Body '{"entity":{"metadata":{"name":"i-424242"}},"check":{"metadata":{"name":"my-api"},"interval":30,"status":2,"output":"ERROR: failed to connect to database.","handlers":["rocketchat"]}}' `
     -Uri "${Env:SENSU_API_URL}/api/core/v2/namespaces/${Env:SENSU_NAMESPACE}/events"
   ```

   The following event will be _processed_ (the first occurrence of a recovery event):

   **Mac and Linux:**

   ```shell
   curl -i -X POST -H "Authorization: Key ${SENSU_API_KEY}" \
        -H "Content-Type: application/json" \
        -d '{"entity":{"metadata":{"name":"i-424242"}},"check":{"metadata":{"name":"my-api"},"interval":30,"status":0,"output":"200 OK","handlers":["rocketchat"]}}' \
        "${SENSU_API_URL:-http://127.0.0.1:8080}/api/core/v2/namespaces/${SENSU_NAMESPACE:-default}/events"
   ```

   **Windows (PowerShell):**

   ```powershell
   Invoke-RestMethod `
     -Method POST `
     -Headers @{"Authorization" = "Key ${Env:SENSU_API_KEY}";} `
     -ContentType "application/json" `
     -Body '{"entity":{"metadata":{"name":"i-424242"}},"check":{"metadata":{"name":"my-api"},"interval":30,"status":0,"output":"200 OK","handlers":["rocketchat"]}}' `
     -Uri "${Env:SENSU_API_URL}/api/core/v2/namespaces/${Env:SENSU_NAMESPACE}/events"
   ```

   The following event will be _filtered_ (a repeat occurrence of a healthy event):

   **Mac and Linux:**

   ```shell
   curl -i -X POST -H "Authorization: Key ${SENSU_API_KEY}" \
        -H "Content-Type: application/json" \
        -d '{"entity":{"metadata":{"name":"i-424242"}},"check":{"metadata":{"name":"my-api"},"interval":30,"status":0,"output":"200 OK","handlers":["rocketchat"]}}' \
        "${SENSU_API_URL:-http://127.0.0.1:8080}/api/core/v2/namespaces/${SENSU_NAMESPACE:-default}/events"
   ```

   **Windows (PowerShell):**

   ```powershell
   Invoke-RestMethod `
     -Method POST `
     -Headers @{"Authorization" = "Key ${Env:SENSU_API_KEY}";} `
     -ContentType "application/json" `
     -Body '{"entity":{"metadata":{"name":"i-424242"}},"check":{"metadata":{"name":"my-api"},"interval":30,"status":0,"output":"200 OK","handlers":["rocketchat"]}}' `
     -Uri "${Env:SENSU_API_URL}/api/core/v2/namespaces/${Env:SENSU_NAMESPACE}/events"
   ```

   Try running these commands multiple times in different combinations and observing the behavior.
   The `is_incident` and an occurrence-based filter like `filter-repeated` work very well together for reducing alert fatigue.

**NEXT:** if you have successfully applied your filter and observed it working as described above, then you're ready to move on to the next lesson!

## Discussion

In this lesson we learned how to apply filters to control the behavior of handlers. 
We also learned how to solve complex problems by authoring custom filters using JavaScript expressions.

These examples demonstrate Sensu's flexible filtering system, which allows you to customize how and when events will be processed by the Sensu pipeline.

### Use Cases

Event filters provide a real-time detection and analysis engine for the Sensu observability pipeline.

Some example use cases include:

- **Reduce alert fatigue** by deduplicating incoming events and limiting repeat processing (e.g. only alert once per hour per incident)
- **Optimize metrics processing** by dropping empty events, or sampling metrics to reduce storage costs
- **Orchestrate remediations** via [_occurrence_](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-events/events/#occurrences-and-occurrences-watermark) filtering (e.g. trigger a lightweight remediation action after 3 occurrences, and a more aggressive remediation action after 10+ occurrences)
- **Configure conditional triggers** by determining which event handler to use (e.g. notify developers via Rocket.Chat, but send all incidents assigned to operations to Pagerduty)

### Filter Execution Environment

The expressions are executed in a sandboxed EMCAScript 5 compatible JavaScript virtual machine called [Otto](https://github.com/robertkrimen/otto).

## Learn More

- [[Documentation] "Event Filters Overview" (docs.sensu.io)](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-filter/)
- [[Documentation] "Event Filters Reference" (docs.sensu.io)](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-filter/filters/)
- [[Documentation] "Sensu Query Expressions Reference" (docs.sensu.io)](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-filter/sensu-query-expressions/)
- [[Documentation] "Guide: Reduce alert fatigue with event filters" (docs.sensu.io)](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-filter/reduce-alert-fatigue/)
- [[Documentation] "Guide: Route alerts with event filters" (docs.sensu.io)](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-filter/route-alerts/)
- [[Blog Post] "Filters: valves for the Sensu Observability Pipeline" (sensu.io)](https://sensu.io/blog/filters-valves-for-the-sensu-monitoring-event-pipeline)
- [[Whitepaper] "Alert fatigue: avoidance and course correction" (sensu.io)](https://sensu.io/resources/whitepaper/alert-fatigue-guide)
- [[Blog Post] "Alert fatigue, part 1: avoidance and course correction" (sensu.io)](https://sensu.io/blog/alert-fatigue-part-1-avoidance-and-course-correction)
- [[Blog Post] "Alert fatigue, part 2: alert reduction with Sensu filters & token substitution" (sensu.io)](https://sensu.io/blog/alert-fatigue-part-2-alert-reduction-with-sensu-filters-token-substitution)
- [[Blog Post] "Alert fatigue, part 3: automating triage & remediation with check hooks & handlers" (sensu.io)](https://sensu.io/blog/alert-fatigue-part-3-automating-triage-remediation-with-checks-hooks-handlers)
- [[Blog Post] "Alert fatigue, part 4: alert consolidation" (sensu.io)](https://sensu.io/blog/alert-fatigue-part-4-alert-consolidation)
- [[Blog Post] "Alert fatigue, part 5: fine-tuning & silencing" (sensu.io)](https://sensu.io/blog/alert-fatigue-part-5-fine-tuning-silencing)

## Next Steps

[Share your feedback on Lesson 06](https://github.com/sensu/sensu-go-workshop/issues/new?template=lesson_feedback.md&labels=feedback%2Clesson-06&title=Lesson%2006%20Feedback)

[Lesson 7: Introduction to Agents & Entities](../07/README.md#readme)

[setup_workshop]: ../02/README.md#readme


