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

- `is_incident`: only process events that are a non-healthy status, and resolution events (the first healthy status event following an incident)
- `not_silenced`: only process events that are not actively silenced
- `has_metrics`: only process events containing Sensu Metrics


## EXERCISE: create a custom event filter

1. Configure a filter to process events from a specific environment.

   Let's create a filter to prevent processing any event that's not part of the "production" environment.
   If you look at the example event filter below, you'll see that it is an _inclusive_ filter (`action: allow`) that will only allow processing for events associated with entities that have the `"environment": "production"` label.

   Copy and paste the following contents to a file named `filter-production-only.yaml`:

   ```yaml
   ---
   type: EventFilter
   api_version: core/v2
   metadata:
     name: production-only
   spec:
     action: allow
     expressions:
     - event.entity.labels["environment"] == "production"
   ```

1. Create the "production-only" filter using `sensuctl`.

   ```shell
   sensuctl create -f filter-production-only.yaml
   ```

   Then verify that the filter was successfully created:

   ```shell
   sensuctl filter list
   ```

**NEXT:** If you see your `production-only` filter, you're ready to move on to the next step.

## EXERCISE: using custom event filters



## Learn more

## Next steps

[Lesson 7: Introduction to Agents & Entities](../07/README.md#readme)
