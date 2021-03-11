# Lesson 5: Introduction to Events

- [Overview](#overview)
- [Events are observations](#events-are-observations)
- [EXERCISE: create an event using curl and the Sensu Events API (no-op)](#exercise-create-an-event-using-curl-and-the-Sensu-Events-API-no-op)
- [EXERCISE: create an event using curl and the Sensu Events API (handled)](#exercise-create-an-event-using-curl-and-the-Sensu-Events-API-handled)
- [Learn more](#learn-more)

## Overview

## Events are Observations

==TODO: In Sensu, every observation is an event.
Events can contain metrics.==

## EXERCISE: create an event using curl and the Sensu Events API (no-op)

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

   ```
   curl -i -X POST -H "Authorization: Key ${SENSU_API_KEY}" \
       -H "Content-Type: application/json" \
       -d '{"entity":{"metadata":{"name":"server-01"}},"check":{"metadata":{"name":"my-app"},"interval":30,"status":2,"output":"ERROR: failed to connect to database."}}' \
       "${SENSU_API_URL:-http://127.0.0.1:8080}/api/core/v2/namespaces/${SENSU_NAMESPACE:-default}/events"
   ```

   > _NOTE: This command and all subsequent curl commands should generate output that starts with `HTTP/1.1 200 OK`, `HTTP/1.1 201 Created`, or `HTTP/1.1 202 Accepted`.
   > If you do not see this output, or if you received an error message, please ensure that you completed all of the steps in [Setup](/docs/SETUP.md), and/or ask your instructor for help._

   What happens when Sensu processes an event?
   We should now be able to see the event in Sensu using `sensuctl` or the Sensu web app.

   ```shell
      Entity         Check                     Output                   Status   Silenced             Timestamp                             UUID
    ──────────────── ──────────── ─────────────────────────────────────── ──────── ────────── ─────────────────────────────── ──────────────────────────────────────
     learn.sensu.io   helloworld   Hello, workshop world.                       1   false      2021-03-09 22:44:28 -0800 PST   8f0dfc70-8730-4b62-8f16-e4d8673f311f
     server-01        my-app       ERROR: failed to connect to database.        2   false      2021-03-10 15:58:25 -0800 PST   0784e60b-96b1-4226-a151-13a645abdf67
   ```

## EXERCISE: create an event using curl and the Sensu Events API (handled)

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

   ```
   curl -i -X POST -H "Authorization: Key ${SENSU_API_KEY}" \
        -H "Content-Type: application/json" \
        -d '{"entity":{"metadata":{"name":"server-01"}},"check":{"metadata":{"name":"my-app"},"interval":30,"status":2,"output":"ERROR: failed to connect to database.","handlers":["slack"]}}' \
        "${SENSU_API_URL:-http://127.0.0.1:8080}/api/core/v2/namespaces/${SENSU_NAMESPACE:-default}/events"
   ```

   Do you notice anything different about the contents of the event we're creating this time?
   There's an additional property called `handlers: []` that provides instructions on which pipeline(s) Sensu should use to process the event.
   If the `handlers` property is omitted from an event, Sensu will simply store the event and no additional processing will be performed.

## Learn more

## Next steps

[Lesson 6: Introduction to Filters](../06/README.md#readme)
