# Lesson 6: Introduction to Filters

- [Overview](#overview)
- [Use Cases](#use-cases)
- [Filter execution environment & built-in helper functions](#filter-execution-environment--built-in-helper-functions)
- [Filter plugins](#filter-plugins)
- [EXERCISE: using built-in event filters](#exercise-using-built-in-event-filters)
- [EXERCISE: create a custom event filter](#exercise-create-a-custom-event-filter)
- [EXERCISE: using custom event filters](#exercise-using-custom-event-filters)
- [Learn more](#learn-more)

## Overview

==TODO: Filters provide a realtime detection & analysis engine for Sensu...==

## Use Cases

==TODO: example use cases, including occurrence filtering.
Inclusive (`action: allow`) & exclusive (`action: deny`) filtering.==

## Filter execution environment & built-in helper functions

## Filter plugins

## EXERCISE: using built-in event filters

Sensu Go ships with built-in event filters for common operations, including:

- `is_incident`: only process warnings (`"status": 1`), critical (`"status": 2`), other (unknown or custom status), and resolution events.
- `not_silenced`: prevents processing of events that include the `silenced` attribute.
- `has_metrics`: only process events containing Sensu Metrics.

1. Modify a handler configuration template to use a built-in filter.

   Let's modify the handler template we created in [Lesson 4](/lessons/operator/04/README.md#readme) (i.e. `slack.yaml`), and replace the `filters: []` line with the following:

   ```yaml
   filters:
   - is_incident
   ```

1. Update the handler using `sensuctl create -f`.

   ```shell
   sensuctl create -f slack.yaml
   ```

   Now verify that the handler configuration was updated by viewing the handler using `sensuctl` or the Sensu web app.

   ```shell
   sensuctl handler info slack --format yaml
   ```

1. Test the filter.

   The `is_incident` filter will prevent processing of healthy (`"status": 0`) events, unless they are resolving an incident.
   Let's send some events to see this behavior in action.

   The following event will be filtered:

   ```shell
   curl -i -X POST -H "Authorization: Key ${SENSU_API_KEY}" \
        -H "Content-Type: application/json" \
        -d '{"entity":{"metadata":{"name":"server-01"}},"check":{"metadata":{"name":"my-app"},"interval":30,"status":0,"output":"200 OK","handlers":["slack"]}}' \
        "${SENSU_API_URL:-http://127.0.0.1:8080}/api/core/v2/namespaces/${SENSU_NAMESPACE:-default}/events"
   ```

   The following event will be processed:

   ```shell
   curl -i -X POST -H "Authorization: Key ${SENSU_API_KEY}" \
        -H "Content-Type: application/json" \
        -d '{"entity":{"metadata":{"name":"server-01"}},"check":{"metadata":{"name":"my-app"},"interval":30,"status":2,"output":"ERROR: failed to connect to database.","handlers":["slack"]}}' \
        "${SENSU_API_URL:-http://127.0.0.1:8080}/api/core/v2/namespaces/${SENSU_NAMESPACE:-default}/events"
   ```

   Try running these commands multiple times in different combinations and observing the behavior.
   The first occurrence of a `"status": 0` event following an active incident is treated as a "resolution" event, and will be processed; but subsequent occurrences of the `"status": 0` event will be filtered.
   Every occurrence of the `"status": 1` event will be processed, but we wouldn't typically want that to happen (because "alert fatigue"), so let's move on to the next exercise to learn how to modify that behavior.

**NEXT:** If you have have applied the built-in `is_incident` filter and observed it working as described above, then you're ready to move on to the next exercise.

## EXERCISE: create a custom event filter

1. Configure a filter to reduce alert fatigue.

   The Sensu observability pipeline uses a series of event counters that are quite effective for managing alert frequency.
   These counters include the `occurrences` counter, and the `occurrences_watermark` counter.
   The occurrences property is visible in the Sensu web app event detail view (see below for example).

   ![](/docs/img/app-occurrences.png)

   Let's configure a filter template to so that it only processes the first occurrence of an incident, and then again only once every hour.

   ```yaml
   ---
   type: EventFilter
   api_version: core/v2
   metadata:
     name: filter-repeated
     namespace: default
   spec:
     action: allow
     expressions:
     - event.check.occurrences == 1 || event.check.occurrences % (3600 / event.check.interval) == 0
   ```

   _NOTE: for more information on this filter expression (specifically including the modulus operator calculation), please visit the [sensu/catalog project on GitHub](https://github.com/sensu/catalog/blob/main/shared/filters/filter-repeated-hourly.yaml)._

1. Create the "fitler-repeated" filter using `sensuctl`.

   ```shell
   sensuctl create -f filter-repeated.yaml
   ```

   Then verify that the filter was successfully created:

   ```shell
   sensuctl filter list
   ```

   Our custom `filter-repeated` filter is now available to use with handlers!

**NEXT:** If you see your `filter-repeated` filter, you're ready to move on to the next exercise.

## EXERCISE: using custom event filters

1. Modify a handler configuration template to use a custom filter.

   Let's modify the handler template we created in [Lesson 4](/lessons/operator/04/README.md#readme) (i.e. `slack.yaml`), and update the `filters` field with the following:

   ```yaml
   filters:
   - is_incident
   - filter-repeated
   ```

1. Update the handler using `sensuctl create -f`.

   ```shell
   sensuctl create -f slack.yaml
   ```

   Now verify that the handler configuration was updated by viewing the handler using `sensuctl` or the Sensu web app.

   ```shell
   sensuctl handler info slack --format yaml
   ```

1. Test the filter.

   The `filter-repeated` filter will prevent repeat processing of events (only allowing repeat processing once per hour).
   Let's send some events to see this behavior in action.

   The following event will be _processed_ (the first occurrence of a critical severity event):

   ```shell
   curl -i -X POST -H "Authorization: Key ${SENSU_API_KEY}" \
        -H "Content-Type: application/json" \
        -d '{"entity":{"metadata":{"name":"server-01"}},"check":{"metadata":{"name":"my-api"},"interval":30,"status":2,"output":"ERROR: failed to connect to database.","handlers":["slack"]}}' \
        "${SENSU_API_URL:-http://127.0.0.1:8080}/api/core/v2/namespaces/${SENSU_NAMESPACE:-default}/events"
   ```

   The following event will be _filtered_ (the second occurrence of a critical severity event):

   ```shell
   curl -i -X POST -H "Authorization: Key ${SENSU_API_KEY}" \
        -H "Content-Type: application/json" \
        -d '{"entity":{"metadata":{"name":"server-01"}},"check":{"metadata":{"name":"my-api"},"interval":30,"status":2,"output":"ERROR: failed to connect to database.","handlers":["slack"]}}' \
        "${SENSU_API_URL:-http://127.0.0.1:8080}/api/core/v2/namespaces/${SENSU_NAMESPACE:-default}/events"
   ```
   The following event will be _processed_ (the first occurrence of a recovery event):

   ```shell
   curl -i -X POST -H "Authorization: Key ${SENSU_API_KEY}" \
        -H "Content-Type: application/json" \
        -d '{"entity":{"metadata":{"name":"server-01"}},"check":{"metadata":{"name":"my-api"},"interval":30,"status":0,"output":"200 OK","handlers":["slack"]}}' \
        "${SENSU_API_URL:-http://127.0.0.1:8080}/api/core/v2/namespaces/${SENSU_NAMESPACE:-default}/events"
   ```

   The following event will be _filtered_ (a repeat occurrence of a healthy event):

   ```shell
   curl -i -X POST -H "Authorization: Key ${SENSU_API_KEY}" \
        -H "Content-Type: application/json" \
        -d '{"entity":{"metadata":{"name":"server-01"}},"check":{"metadata":{"name":"my-api"},"interval":30,"status":0,"output":"200 OK","handlers":["slack"]}}' \
        "${SENSU_API_URL:-http://127.0.0.1:8080}/api/core/v2/namespaces/${SENSU_NAMESPACE:-default}/events"
   ```

   Try running these commands multiple times in different combinations and observing the behavior.
   The `is_incident` and an occurence-based filter like `filter-repeated` work very well together for reducing alert fatigue (i.e. with alert and incident management handlers).
   These few examples are just a small preview of Sensu's flexible filtering system, which makes it easy to customize how and when observability events will be processed by the observability pipeline.

**NEXT:** if you have successfully applied your filter and observed it working as described above, then you're ready to move on to the next lesson!

## Learn more

## Next steps

[Lesson 7: Introduction to Agents & Entities](../07/README.md#readme)
