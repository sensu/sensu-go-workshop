# Lesson 10: Introduction to Silencing & Scheduled Maintenance

- [Goals](#goals)
- [Alert Suppression](#alert-suppression)
  - [What is Silencing?](#what-is-silencing)
  - [The `not_silenced` Filter](#the-not-silenced-filter)
  - [EXERCISE 1: Silence an Alert](#exercise-1-silence-an-alert)
- [Bulk Silencing](#bulk-silencing)
  - [Silencing Alerts on Multiple Hosts](#silencing-alerts-on-multiple-hosts)
  - [EXERCISE 2: Bulk Silencing](#exercise-2-bulk-silencing)
- [Scheduled Maintenance](#scheduled-maintenance)
  - [What is a Scheduled Maintenance Window?](#what-is-a-scheduled-maintenance-window)
  - [EXERCISE 3: Configure a Scheduled Maintenance Window](#exercise-3-configure-a-scheduled-maintenance-window)
- [Discussion](#discussion)
  - [Scheduled Maintenance vs Maintenance Mode](#scheduled-maintenance-vs-maintenance-mode)
- [Next steps](#next-steps)

## Goals

In this lesson we will learn about [Silencing][silencing-docs] in Sensu Go.
You will learn how to target individual incidents on a single host, specific incidents spanning multiple hosts, and even bulk silencing all incidents across multiple hosts.
You will also learn some new ways to integrate observability with your existing automation systems.
This lesson is intended for operators of Sensu, and assumes you have [set up a local workshop environment][setup_workshop].

## Alert Suppression

Generating alerts is a critical function of observability systems.
Keeping those alerts in check so as to avoid "alert fatigue" is a top priority
Once Sensu alerts us to an incident that requires further investigation, we can surpress subsequent notifications using [Silences][silencing-docs].

### What is Silencing?

Sensu’s silencing capability allows you to suppress event handler execution on an ad hoc basis so you can plan maintenance and reduce alert fatigue.
Silences are created on an ad hoc basis using `sensuctl`, the Sensu Silenced API, or the Sensu web app.
Some popular use cases for silencing include alert acknowledgement, and overall reduction of alert fatigue.

### The `not_silenced` Filter

Sensu's silencing implementation is intended to a broad variety of use cases.
For this reason, silenced events are not automatically discarded by Sensu.
Sensu compares incoming events against configured silencing rules and annotates matching events with an `is_silenced: true` property.
Event processing can be disabled for silenced events using the built-in [`not_silenced` event filter][not-silenced].

The `not_silenced` filter only allows processing of events that are _not silenced_ (i.e. any event that does not have `event.check.is_silenced` set to `true`).
This filter can be applied to handlers on a case-by-case basis.
Most users typically enable the `not_silenced` filter on all alerting and incident management handlers (e.g. Slack or Pagerduty).
To learn more about event filters in Sensu Go, please review [Lesson 6][lesson-6] of this workshop.

### EXERCISE 1: Silence an Alert

#### Scenario

You are on-call and have received an alert from Sensu regarding an incident that requires attention from an operator.
Since you are the first person to respond to the incident, you want to acknowledge the incident and configure Sensu to disable alerts for the next hour minutes, or until the service is restored (which ever comes first).

#### Solution

To accomplish this we will configure a silence to suppress an alert (i.e. disabling event processing).
We'll use `sensuctl` to configure silencing in this lesson.
You can also configure silences from the Sensu Go web app, which we'll introduce in [Lesson 11][lesson-11].

#### Steps

1. **Configure a service health check to monitor an example application.**

   Copy and paste the following contents to a file named `app.yaml`.
   This will enable HTTP endpoint monitoring of a simple demo app in the workshop environment.

   ```yaml
   ---
   type: CheckConfig
   api_version: core/v2
   metadata:
     name: app-health
   spec:
     command: http-check --url http://workshop_app_1:8080/healthz
     runtime_assets:
     - sensu/http-checks:0.4.0
     publish: true
     proxy_entity_name: workshop_app_1
     subscriptions:
     - workshop
     interval: 30
     timeout: 10
     handlers:
     - mattermost
   ```

1. **Add the `not_silenced` filter to handlers.**

   Let's modify the handler template we created in [Lesson 4][lesson-4] and updated in [Lesson 6][lesson-6].
   Replace the contents of `mattermost.yaml` with the following:

   ```yaml
   ---
   type: Handler
   api_version: core/v2
   metadata:
     name: mattermost
   spec:
     type: pipe
     command: >-
       sensu-slack-handler
       --channel "#alerts"
       --username SensuGo
       --description-template "{{ .Check.Output }}\n\n[namespace:{{.Entity.Namespace}}]"
       --webhook-url ${MATTERMOST_WEBHOOK_URL}
     runtime_assets:
     - sensu/sensu-slack-handler:1.4.0
     timeout: 10
     filters:
     - is_incident
     - not_silenced
     secrets:
     - name: MATTERMOST_WEBHOOK_URL
       secret: mattermost_webhook_url
   ```

   > **Understanding the YAML:**
   > - We added `not_silenced` the `filters:` array.
   > - We _removed_ `filter-repeated` from the filters array so we can better observe the effect of silencing

1. **Trigger an incident**

   The demo app provided in this workshop has a built-in `/healthz` API that we can toggle between healthy (`200 OK`) and unhealthy (`500 Internal Server Error`) states by sending an HTTP POST request.
   Let's trigger a failure in the app that will result in an alert in Mattermost.

   **Mac and Linux:**

   ```shell
   curl -i -X POST http://127.0.0.1:9001/healthz
   curl -i -X GET http://127.0.0.1:9001/healthz
   ```

   **Windows (Powershell):**

   ```shell
   Invoke-RestMethod -Method POST -Uri "http://127.0.0.1:9001/healthz"
   Invoke-RestMethod -Method GET -Uri "http://127.0.0.1:9001/healthz"
   ```

   You should see output like `HTTP/1.1 500 Internal Server Error`.
   _NOTE: If you see an error like `curl: (7) Failed to connect to localhost port 9001: Connection refused` it may be that Docker assigned a different port to your demo app container.
   To obtain the current port mapping number run `sudo docker port workshop_app_1`._

   Within a few moments, Sensu should begin reporting the failure.
   Run the `sensuctl event list` command to see the incident:

   ```shell
   $ sensuctl event list
         Entity         Check                                        Output                                      Status   Silenced             Timestamp
    ───────────────── ──────────── ───────────────────────────────────────────────────────────────────────────── ──────── ────────── ───────────────────────────────
     workshop_app_1    app-health   http-check CRITICAL: HTTP Status 500 for http://workshop_app_1:8080/healthz        2   true       2021-10-23 15:34:11 -0700 PDT
   ```

   If you are seeing alerts in Mattermost, you're ready to move on to the next step.

1. **Create a silence entry.**

   Let's use the `sensuctl silenced create` to create a silencing rule to disable alerts for this incident.
   Since we're just getting started, let's just silence alerts for a few minutes.
   In a typical scenario you might silence alerts for an hour or more while you investigate an incident.

   ```shell
   sensuctl silenced create --interactive
   ? Namespace: default
   ? Subscription: entity:workshop_app_1
   ? Check: app-health
   ? Begin time: now
   ? Expiry in Seconds: 120
   ? Expire on Resolve: No
   ? Reason: My first silence!
   Created
   ```

   As soon as you create this silence, the alerts in Mattermost should be surpressed for 2 minutes.
   Wait until the silence expires – when alerts appear in Mattermost again – then move on to the next exercise.

   > **Understanding the command:**
   > - Setting `Subscription: entity:workshop_app_1` means the silence will only apply to events matching a single entity named `workshop_app_1`.
   > - Providing a check name (`Check: app-health`) means the silence will only apply to events from the app-health check
   > - The "Begin time", "Expiry in seconds", and "Expire on Resolve" settings let us control when Sensu will begin supressing alerts, and when Sensu should resume processing of alerts.
   > - The "Reason" field lets us leave a comment or provide a description for the silence.

## Bulk Silencing

In certain circumstances it can be helpful to silence incidents in bulk.
Sensu supports silencing specific incidents spanning multiple hosts, and even bulk silencing multiple incidents across multiple hosts.

### Silencing Alerts on Multiple Hosts

Sensu silences are applied to events by matching two event properties: subscription (`event.entity.subscriptions` or `event.check.subscriptions`), and the check name (`event.check.metadata.name`).
These configuration parameters offer

- Silencing a specific check on a specific entity:

  ```
  subscription: entity:1-424242
  check: app-health
  ```

- Silencing a specific check on any entity:

  ```
  subscription: *
  check: app-health
  ```

- Silencing any check on a specific subscription:

  ```
  subscription: postgres
  check: *
  ```

### EXERCISE 2: Bulk Silencing

#### Scenario

You are responding to an incident or managing a maintenance operation involving multiple nodes.

#### Solution

To accomplish this we will configure a silence to suppress multiple alerts (i.e. disabling event processing).
We'll use `sensuctl` to configure silencing in this lesson.
You can also configure silences from the Sensu Go web app, which we'll introduce in [Lesson 11].

#### Steps

1. **Create a silence entry.**

   Let's use the `sensuctl silenced create` to create a silencing rule to disable alerts for this incident.

   ```shell
   sensuctl silenced create --interactive
   ? Namespace: default
   ? Subscription: entity:workshop_app_1
   ? Check: app-health
   ? Begin time: now
   ? Expiry in Seconds: 120
   ? Expire on Resolve: No
   ? Reason: My first silence!
   Created
   ```

   As soon as you create this silence, the alerts in Mattermost should be surpressed for 2 minutes.
   Wait until the silence expires – when alerts appear in Mattermost again – then move on to the next exercise.

   > **Understanding the command:**
   > - Setting `Subscription: workshop` means the silence will apply to events on any host that is a member of the `workshop` subscription.
   > - Providing a check name (`Check: app-health`) means the silence will only apply to events from the app-health check
   > - The "Begin time", "Expiry in seconds", and "Expire on Resolve" settings let us control when Sensu will begin supressing alerts, and when Sensu should resume processing of alerts.
   > - The "Reason" field lets us leave a comment or provide a description for the silence.

## Scheduled Maintenance

### What is a Scheduled Maintenance Window?

Scheduled maintenance window is a silence that starts and ends in the future.

### EXERCISE 3: Configure a Scheduled Maintenance Window

#### Scenario

You are planning a maintenance activity

#### Solution

#### Steps

1. **Get the current date and time in RFC3339 format:**

   Get the current time in RFC3339 or RFC8601 format.

   **MacOS:**

   ```
   date +"%Y-%m-%d %H:%M:%S %z"
   date +"%Y-%m-%dT%H:%M:%S%z"
   ```

   **Windows (Powershell):**

   ```
   Get-Date -Format "yyyy-MM-dd HH:mm:ss K"
   Get-Date -Format "yyyy-MM-ddTHH:mm:ssK"
   ```

   **Linux:**

   ```
   date +"%Y-%m-%d %H:%M:%S %:z"
   date +"%Y-%m-%dT%H:%M:%S%:z"
   ```

1. **Create a silence entry.**

   Let's use the `sensuctl silenced create` to create a silencing rule for a scheduled maintenance window.
   _NOTE: Please modify the begin time to be 2-3 minutes in the future; the macOS `time` utility isn't RFC compliant, so you'll need to add a colon to the timezone offset (e.g. `-07:00` instead of `-0700`)._

   ```shell
   sensuctl silenced create --interactive
   ? Namespace: default
   ? Subscription: entity:workshop_app_1
   ? Check: *
   ? Begin time: 2021-12-26 00:00:00 -07:00
   ? Expiry in Seconds: 120
   ? Expire on Resolve: No
   ? Reason: Scheduled maintenance example!
   Created
   ```

   When the configured "Begin time" is reached, the alerts in Mattermost should be surpressed for 2 minutes.
   Wait until the silence expires – when alerts appear in Mattermost again – then move on to the next exercise.

   > **Understanding the command:**
   > - Setting `Subscription: entity:workshop_app_1` means the silence will only apply to events matching a single entity named `workshop_app_1`
   > - Setting `Check: *` or leaving the Check blank means the silence will apply to any event on the configured subscription; in this case we're effectively suppressing all alerts on a specific host.
   > - Setting "Begin time" in the future allows us to configure scheduled maintenance windows!
   > - The "Reason" field lets us leave a comment or provide a description for the silence – very helpful to remind your future self why you created the scheduled maintenance window.

## Discussion

In this lesson we explored different ways to suppress event handling in Sensu Go and covered the popular use cases for [Sensu Silences][silencing-docs].
You learned how to create and manage silences using `sensuctl`, and disable silenced event processing using the built-in `not_silenced` filter.
Keep reading to learn about additional use cases for Sensu Silences.

### Scheduled Maintenance vs Maintenance Mode

Scheduled maintenance is a useful practice when a particular maintenance window requires human interaction because human involvement generally has to be coordinated/scheduled in advance.
In today's world of cloud computing, many maintenance tasks are heavily automated and performed in an unattended manner.
In these scenarios, automation tools can do the work of creating ad-hoc silencing rules that begin immediately and have no expiration.
Once the automated maintenace task is completed, the silence can be deleted.
This practice of integrating automation tools with Sensu is often referred to as "maintenance mode".
Maintenance mode can be configured by scripting `sensuctl` commands, or by direct integration with the [Sensu Silencing API][silencing-api].
Some third-party automation tools such as Rundeck offer [built-in integration with Sensu][rundeck-integration] for easy adoption of automated maintenance mode as a practice.

## Learn More

* [[Documentation] "Silencing Overview" (docs.sensu.io)][silencing-docs]
* [[Documentation] "Silencing API" (docs.sensu.io)][silencing-api]

## Next Steps

[Share your feedback on Lesson 04](https://github.com/sensu/sensu-go-workshop/issues/new?template=lesson_feedback.md&labels=feedback%2Clesson-10&title=Lesson%2010%20Feedback)

[Lesson 5: Introduction to Events][next lesson]

<!-- Docs references -->
[setup_workshop]: ../02/README.md#readme
[silencing-docs]: https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-process/silencing/
[silencing-api]: https://docs.sensu.io/sensu-go/latest/api/silenced/
[not-silenced]: https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-filter/filters/#built-in-filter-not_silenced

<!-- Lesson references-->
[lesson-4]: /lessons/operator/04/README.md#readme
[lesson-6]: /lessons/operator/06/README.md#readme
[lesson-10]: /lessons/operator/10/README.md#readme
[next lesson]: /lessons/operator/11/README.md#readme

<!-- External references -->
[rundeck-integration]: https://docs.rundeck.com/docs/manual/workflow-steps/sensu.html