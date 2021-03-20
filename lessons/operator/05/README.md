# Lesson 5: Introduction to Events

- [Overview](#overview)
- [Events are observations](#events-are-observations)
- [EXERCISE: create an event using curl and the Sensu Events API](#exercise-create-an-event-using-curl-and-the-Sensu-Events-API-no-op)
- [EXERCISE: create an event that triggers an alert](#exercise-create-an-event-that-triggers-an-alert)
- [Learn more](#learn-more)
- [Next steps](#next-steps)
- [Troubleshooting](#troubleshooting)

## Overview

## Events are Observations

==TODO: In Sensu, every observation is an event.
Events can contain metrics.==

## EXERCISE: create an event using curl and the Sensu Events API

1. Configure environment variables

   Verify the contents of `.envrc` to ensure that `SENSU_API_URL`, `SENSU_NAMESPACE`, and `SENSU_API_KEY` are set to the correct values, then run the following command:

   ```
   source .envrc
   ```

   - **Self-guided workshop users:** use the default values for `SENSU_API_URL` (`http://127.0.0.1:8080`) and `SENSU_NAMESPACE` (`default`).
   - **Instructor-led workshop users:** use the values provided by your instructor for `SENSU_API_URL` and `SENSU_NAMESPACE`.

   To verify that your environment is correctly configured, please run the following command:

   ```
   env | grep SENSU
   ```

   Do you see the expected values for `SENSU_API_URL`,`SENSU_NAMESPACE`, and `SENSU_API_KEY`?
   If so, you're ready to move on to the next step!

1. Create an event using `curl` and the Sensu Events API

   ```
   curl -i -X POST -H "Authorization: Key ${SENSU_API_KEY}" \
        -H "Content-Type: application/json" \
        -d '{"entity":{"metadata":{"name":"server-01"}},"check":{"metadata":{"name":"my-app"},"interval":30,"status":2,"output":"ERROR: failed to connect to database."}}' \
        "${SENSU_API_URL:-http://127.0.0.1:8080}/api/core/v2/namespaces/${SENSU_NAMESPACE:-default}/events"
   ```

   What happens when Sensu processes an event?
   At minimum, Sensu will store the event, so we can inspect it via `sensuctl` or the Sensu web app.

   ```shell
      Entity         Check                     Output                   Status   Silenced             Timestamp                             UUID
    ──────────────── ──────────── ─────────────────────────────────────── ──────── ────────── ─────────────────────────────── ──────────────────────────────────────
     learn.sensu.io   helloworld   Hello, workshop world.                       1   false      2021-03-09 22:44:28 -0800 PST   8f0dfc70-8730-4b62-8f16-e4d8673f311f
     server-01        my-app       ERROR: failed to connect to database.        2   false      2021-03-10 15:58:25 -0800 PST   0784e60b-96b1-4226-a151-13a645abdf67
   ```

   But what about the handler we configured in [Lesson 4](/lessons/04/README.md#readme)?
   If you expected that Sensu would process this event using that handler, you might have noticed that nothing happened.

**NEXT:** Let's move on to the next exercise to see how event handling works in practice.

## EXERCISE: create an event that triggers an alert

Sensu matches incoming events with the corresponding event pipelines using an event attribute called `handlers` (e.g. `handlers:["slack","pagerduty"]`).
Let's create an event that will be processed using the handler we configured in [Lesson 4](/lessons/04/README.md#readme).

1. Configure environment variables

   Verify the contents of `.envrc` to ensure that `SENSU_API_URL`, `SENSU_NAMESPACE`, and `SENSU_API_KEY` are set to the correct values, then run the following command:

   ```
   source .envrc
   ```

   - **Self-guided workshop users:** use the default values for `SENSU_API_URL` (`http://127.0.0.1:8080`) and `SENSU_NAMESPACE` (`default`).
   - **Instructor-led workshop users:** use the values provided by your instructor for `SENSU_API_URL` and `SENSU_NAMESPACE`.

   To verify that your environment is correctly configured, please run the following command:

   ```
   env | grep SENSU
   ```

   The output should include the expected values for `SENSU_API_URL`,`SENSU_NAMESPACE`, and `SENSU_API_KEY`.

   > _NOTE: if you need help creating an API Key, please refer to the [Lesson 3 EXERCISE: create an API Key for personal use](/lessons/operator/03/README.md#exercise-create-an-api-key-for-personal-use)._

1. Create an event using `curl` and the Sensu Events API

   Do you notice anything different about the contents of the event in the next step?
   There's an additional property called `handlers: ["slack"]` that provides instructions on which pipeline(s) Sensu should use to process the event (in this case, the Slack handler we configured in Lesson 4).
   If the `handlers` property is omitted from an event, Sensu will simply store the event and no additional processing will be performed.
   Run the following command to create an event that will be processed using our Slack handler.

   ```
   curl -i -X POST -H "Authorization: Key ${SENSU_API_KEY}" \
        -H "Content-Type: application/json" \
        -d '{"entity":{"metadata":{"name":"server-01"}},"check":{"metadata":{"name":"my-app"},"interval":30,"status":2,"output":"ERROR: failed to connect to database.","handlers":["slack"]}}' \
        "${SENSU_API_URL:-http://127.0.0.1:8080}/api/core/v2/namespaces/${SENSU_NAMESPACE:-default}/events"
   ```

1. Create a resolution event using `curl` and the Sensu Events API

   Let's send one more event to indicate that our imaginary app is now restored to a functional state:

   ```shell
   curl -i -X POST -H "Authorization: Key ${SENSU_API_KEY}" \
        -H "Content-Type: application/json" \
        -d '{"entity":{"metadata":{"name":"server-01"}},"check":{"metadata":{"name":"my-app"},"interval":30,"status":0,"output":"200 OK","handlers":["slack"]}}' \
        "${SENSU_API_URL:-http://127.0.0.1:8080}/api/core/v2/namespaces/${SENSU_NAMESPACE:-default}/events"
   ```

**NEXT:** Did Sensu create messages in Slack?
If so you're ready to move on to the next step!

## Learn more

- [Sensu Events (reference documentation)](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-events/events/)
- [Sensu Events API (reference documentation)](https://docs.sensu.io/sensu-go/latest/api/events/)
- [Sensu Agent Event API (reference documentation)](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-schedule/agent/#create-observability-events-using-the-agent-api)

## Next steps

[Lesson 6: Introduction to Filters](../06/README.md#readme)

-----

## Troubleshooting

### Sensu API Keys

If you need help creating an API Key for Sensu Go, please refer to the [Lesson 3 EXERCISE: create an API Key for personal use](/lessons/operator/03/README.md#exercise-create-an-api-key-for-personal-use)._

### `curl`

This `curl` commands included in this lesson should generate output that starts with `HTTP/1.1 200 OK`, `HTTP/1.1 201 Created`, or `HTTP/1.1 202 Accepted`.
If you do not see this output, or if you received an error message, please ensure that you completed all of the steps in [Setup](/docs/SETUP.md), and/or ask your instructor for help.

### Slack

If Sensu is not generating Slack messages, please ask your instructor for help, or try the following troubleshooting steps:

1. Verify that you have a valid Slack Webhook URL

   ```shell
   curl -X POST -H 'Content-type: application/json' --data '{"text":"This is a test message to verify that I have a valid Slack Webhook URL"}' YOUR_WEBHOOK_URL
   ```

   Reference: https://api.slack.com/tutorials/slack-apps-hello-world

1. Check the `sensu-backend` log for errors

   ==TODO==
