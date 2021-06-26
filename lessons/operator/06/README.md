# Lesson 6: Introduction to Filters

- [Overview](#overview)
- [Use Cases](#use-cases)
- [Filter execution environment & built-in helper functions](#filter-execution-environment--built-in-helper-functions)
- [Filter plugins](#filter-plugins)
- [EXERCISE 1: using built-in event filters](#exercise-1-using-built-in-event-filters)
- [EXERCISE 2: create a custom event filter](#exercise-2-create-a-custom-event-filter)
- [EXERCISE 3: using custom event filters](#exercise-3-using-custom-event-filters)
- [Learn more](#learn-more)
- [Next steps](#next-steps)

## Overview

Sensu event filters provide control over which events (observability data) get processed by Sensu event handlers.
Event filters apply various conditions (Sensu Query Expressions, or SQEs) to incoming events in realtime to determine whether they should be "allowed" (inclusive filtering) or "denied" (exlusive filtering).
Sensu processes all events with a configured event handler by default; in practice this means that almost all event handlers should be configured with one or more event filters to manage which events are allowed through the pipeline.

## Use Cases

Sensu event filters provide a realtime detection and analysis engine for the Sensu observability pipeline.
Some example use cases include:

- **Eliminating alert fatigue** by deduplicating incoming events and limiting repeat processing to predefined conditions (e.g. only alert once per hour per incident)
- **Optimizing metrics processing** by dropping events that do not contain metric data, or sampling metrics to reduce storage costs
- **Orchestrating event processing** via occurrence filtering (e.g. trigger a lightweight remediation action after 3 occurrences, and a more aggressive remediation action after 10+ occurrences)
- **Configuring conditional triggers** by evaluating incoming events to determine which event handler to use (e.g. notify developers via RocketChat, but send all incidents assigned to operations via Pagerduty using a handler set and corresponding filters)

## Filter execution environment & built-in helper functions

SQEs are Javascript expressions, executed in a sandboxed EMCAScript 5 Javascript virtual machine.
SQEs are valid EMCAScript 5 Javascript expression that return either `true` or `false` (all other return values will result in an error).
SQEs can be as simple as basic comparison operations – "less than" (`<`) or "greater than" (`>`) "equal to" (`==`) or "not equal" (`!=`) – or as complex as small Javascript programs.
You can even package filter logic as Javascript libraries and import them into the sandbox environment using Dynamic Runtime Assets!

_NOTE: Dynamic Runtime Assets are covered in greater detail in [Lesson 10: introduction to Assets](/lessons/operator/10/README.md#readme)._

Sensu includes built-in event helper functions and event filters to help you customize event pipelines for metrics and alerts, including:

- **`is_incident` (built-in filter):** only process warnings (`"status": 1`), critical (`"status": 2`), other (unknown or custom status), and resolution events.
- **`not_silenced` (built-in filter):** prevents processing of events that include the `silenced` attribute.
- **`has_metrics` (built-in filter):** only process events containing Sensu Metrics.
- **`hour()` (helper function):** a custom SQE function that returns the hour of a UNIX epoch timestamp in UTC and 24-hour time notation (e.g. `hour(event.timestamp) >= 17`)
- **`weekday()` (helper function):** a custom SQE function that returns a number that represents the day of the week of a UNIX epoch timestamp (Sunday is `0`; e.g. `weekday(event.timestamp) == 0`)

## Filter plugins

TODO (coming soon).

## EXERCISE 1: using built-in event filters

Let's use a built-in filter with a handler we configured in [Lesson 4](/lessons/operator/04/README.md#readme).

1. **Modify a handler configuration template to use a built-in filter.**

   Let's modify the handler template we created in [Lesson 4](/lessons/operator/04/README.md#readme) (i.e. `rocketchat.yaml`), and replace the `filters: []` line with the following:

   ```yaml
   filters:
   - is_incident
   ```

1. **Update the handler using `sensuctl create -f`.**

   ```shell
   sensuctl create -f rocketchat.yaml
   ```

   Now verify that the handler configuration was updated by viewing the handler using `sensuctl` or the Sensu web app.

   ```shell
   sensuctl handler info rocketchat --format yaml
   ```

1. **Configure environment variables.**

   _NOTE: instructor-led workshop users may need to download an `.envrc` or `.envrc.ps1` file at this time (if they haven't already);
   please consult [SETUP.md](/SETUP.md#instructor-led-workshop-setup-for-trainees) for more information._

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

1. **Test the filter.**

   The `is_incident` filter will prevent processing of healthy (`"status": 0`) events, unless they are resolving an incident.
   Let's send some events to see this behavior in action.

   The following event will be filtered:

   **Mac and Linux users:**

   ```shell
   curl -i -X POST -H "Authorization: Key ${SENSU_API_KEY}" \
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

   The following event will be processed:

   **Mac and Linux users:**

   ```shell
   curl -i -X POST -H "Authorization: Key ${SENSU_API_KEY}" \
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

   Try running these commands multiple times in different combinations and observing the behavior.
   The first occurrence of a `"status": 0` event following an active incident is treated as a "resolution" event, and will be processed; but subsequent occurrences of the `"status": 0` event will be filtered.
   Every occurrence of the `"status": 1` event will be processed, but we wouldn't typically want that to happen (because "alert fatigue"), so let's move on to the next exercise to learn how to modify that behavior.

**NEXT:** If you have have applied the built-in `is_incident` filter and observed it working as described above, then you're ready to move on to the next exercise.

## EXERCISE 2: create a custom event filter

1. **Configure a filter to reduce alert fatigue.**

   The Sensu observability pipeline uses a series of event counters that are quite effective for managing alert frequency.
   These counters include the `occurrences` counter, and the `occurrences_watermark` counter.
   The occurrences property is visible in the Sensu web app event detail view (see below for example).

   ![](/docs/img/app-occurrences.png)

   Let's configure a filter template to so that it only processes the first occurrence of an incident, and then again only once every hour.

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

1. **Create the "fitler-repeated" filter using `sensuctl`.**

   ```shell
   sensuctl create -f filter-repeated.yaml
   ```

   Then verify that the filter was successfully created:

   ```shell
   sensuctl filter list
   ```

   Our custom `filter-repeated` filter is now available to use with handlers!

**NEXT:** If you see your `filter-repeated` filter, you're ready to move on to the next exercise.

## EXERCISE 3: using custom event filters

1. **Modify a handler configuration template to use a custom filter.**

   Let's modify the handler template we created in [Lesson 4](/lessons/operator/04/README.md#readme) (i.e. `rocketchat.yaml`), and update the `filters` field with the following:

   ```yaml
   filters:
   - is_incident
   - filter-repeated
   ```

1. **Update the handler using `sensuctl create -f`.**

   ```shell
   sensuctl create -f rocketchat.yaml
   ```

   Now verify that the handler configuration was updated by viewing the handler using `sensuctl` or the Sensu web app.

   ```shell
   sensuctl handler info rocketchat --format yaml
   ```

1. **Configure environment variables.**

   _NOTE: instructor-led workshop users may need to download an `.envrc` or `.envrc.ps1` file at this time (if they haven't already);
   please consult [SETUP.md](/SETUP.md#instructor-led-workshop-setup-for-trainees) for more information._

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

1. **Test the filter.**

   The `filter-repeated` filter will prevent repeat processing of events (only allowing repeat processing once per hour).
   Let's send some events to see this behavior in action.

   The following event will be _processed_ (the first occurrence of a critical severity event):

   **Mac and Linux users:**

   ```shell
   curl -i -X POST -H "Authorization: Key ${SENSU_API_KEY}" \
        -H "Content-Type: application/json" \
        -d '{"entity":{"metadata":{"name":"i-424242"}},"check":{"metadata":{"name":"my-api"},"interval":30,"status":2,"output":"ERROR: failed to connect to database.","handlers":["rocketchat"]}}' \
        "${SENSU_API_URL:-http://127.0.0.1:8080}/api/core/v2/namespaces/${SENSU_NAMESPACE:-default}/events"
   ```

   **Windows users (Powershell):**

   ```powershell
   Invoke-RestMethod `
     -Method POST `
     -Headers @{"Authorization" = "Key ${Env:SENSU_API_KEY}";} `
     -ContentType "application/json" `
     -Body '{"entity":{"metadata":{"name":"i-424242"}},"check":{"metadata":{"name":"my-api"},"interval":30,"status":2,"output":"ERROR: failed to connect to database.","handlers":["rocketchat"]}}' `
     -Uri "${Env:SENSU_API_URL}/api/core/v2/namespaces/${Env:SENSU_NAMESPACE}/events"
   ```

   The following event will be _filtered_ (the second occurrence of a critical severity event):

   **Mac and Linux users:**

   ```shell
   curl -i -X POST -H "Authorization: Key ${SENSU_API_KEY}" \
        -H "Content-Type: application/json" \
        -d '{"entity":{"metadata":{"name":"i-424242"}},"check":{"metadata":{"name":"my-api"},"interval":30,"status":2,"output":"ERROR: failed to connect to database.","handlers":["rocketchat"]}}' \
        "${SENSU_API_URL:-http://127.0.0.1:8080}/api/core/v2/namespaces/${SENSU_NAMESPACE:-default}/events"
   ```

   **Windows users (Powershell):**

   ```powershell
   Invoke-RestMethod `
     -Method POST `
     -Headers @{"Authorization" = "Key ${Env:SENSU_API_KEY}";} `
     -ContentType "application/json" `
     -Body '{"entity":{"metadata":{"name":"i-424242"}},"check":{"metadata":{"name":"my-api"},"interval":30,"status":2,"output":"ERROR: failed to connect to database.","handlers":["rocketchat"]}}' `
     -Uri "${Env:SENSU_API_URL}/api/core/v2/namespaces/${Env:SENSU_NAMESPACE}/events"
   ```

   The following event will be _processed_ (the first occurrence of a recovery event):

   **Mac and Linux users:**

   ```shell
   curl -i -X POST -H "Authorization: Key ${SENSU_API_KEY}" \
        -H "Content-Type: application/json" \
        -d '{"entity":{"metadata":{"name":"i-424242"}},"check":{"metadata":{"name":"my-api"},"interval":30,"status":0,"output":"200 OK","handlers":["rocketchat"]}}' \
        "${SENSU_API_URL:-http://127.0.0.1:8080}/api/core/v2/namespaces/${SENSU_NAMESPACE:-default}/events"
   ```

   **Windows users (Powershell):**

   ```powershell
   Invoke-RestMethod `
     -Method POST `
     -Headers @{"Authorization" = "Key ${Env:SENSU_API_KEY}";} `
     -ContentType "application/json" `
     -Body '{"entity":{"metadata":{"name":"i-424242"}},"check":{"metadata":{"name":"my-api"},"interval":30,"status":0,"output":"200 OK","handlers":["rocketchat"]}}' `
     -Uri "${Env:SENSU_API_URL}/api/core/v2/namespaces/${Env:SENSU_NAMESPACE}/events"
   ```

   The following event will be _filtered_ (a repeat occurrence of a healthy event):

   **Mac and Linux users:**

   ```shell
   curl -i -X POST -H "Authorization: Key ${SENSU_API_KEY}" \
        -H "Content-Type: application/json" \
        -d '{"entity":{"metadata":{"name":"i-424242"}},"check":{"metadata":{"name":"my-api"},"interval":30,"status":0,"output":"200 OK","handlers":["rocketchat"]}}' \
        "${SENSU_API_URL:-http://127.0.0.1:8080}/api/core/v2/namespaces/${SENSU_NAMESPACE:-default}/events"
   ```

   **Windows users (Powershell):**

   ```powershell
   Invoke-RestMethod `
     -Method POST `
     -Headers @{"Authorization" = "Key ${Env:SENSU_API_KEY}";} `
     -ContentType "application/json" `
     -Body '{"entity":{"metadata":{"name":"i-424242"}},"check":{"metadata":{"name":"my-api"},"interval":30,"status":0,"output":"200 OK","handlers":["rocketchat"]}}' `
     -Uri "${Env:SENSU_API_URL}/api/core/v2/namespaces/${Env:SENSU_NAMESPACE}/events"
   ```

   Try running these commands multiple times in different combinations and observing the behavior.
   The `is_incident` and an occurrence-based filter like `filter-repeated` work very well together for reducing alert fatigue (i.e. with alert and incident management handlers).
   These few examples are just a small preview of Sensu's flexible filtering system, which makes it easy to customize how and when observability events will be processed by the observability pipeline.

**NEXT:** if you have successfully applied your filter and observed it working as described above, then you're ready to move on to the next lesson!

## Learn more

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

## Next steps

[Share your feedback on Lesson 06](https://github.com/sensu/sensu-go-workshop/issues/new?template=lesson_feedback.md&labels=feedback%2Clesson-06&title=Lesson%2006%20Feedback)

[Lesson 7: Introduction to Agents & Entities](../07/README.md#readme)
