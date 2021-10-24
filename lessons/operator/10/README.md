# Lesson 10: Introduction to Silencing & Scheduled Maintenance

## Goals

In this lesson we will learn about [Silencing][silencing-docs] in Sensu Go.
You will learn how to target individual incidents on a single host, specific incidents spanning multiple hosts, and even bulk silencing all incidents across multiple hosts.
You will also learn some new ways to integrate monitoring with your existing automation systems.
This lesson is intended for operators of Sensu, and assumes you have [set up a local workshop environment][setup_workshop].

## Alert Supression

Generating alerts is a critical function of monitoring systems.
Keeping those alerts in check so as to avoid "alert fatigue" is a top priority
Once Sensu alerts us to an incident that requires further investigation, we can surpress subsequent notifications using [Silences][silencing-docs].

### What is Silencing?

Sensu’s silencing capability allows you to suppress event handler execution on an ad hoc basis so you can plan maintenance and reduce alert fatigue.
Silences are created on an ad hoc basis using `sensuctl`, the Sensu Silenced API, or the Sensu web app.
Some popular use cases for silencing include alert acknowledgement, and overall reduction of alert fatigue.

### EXERCISE 1: Silence an Alert

#### Scenario

You are on-call and have received an alert from Sensu regarding an incident that requires attention from an operator.
Since you are the first person to respond to the incident, you want to acknowledge the incident and configure Sensu to disable alerts for the next hour minutes, or until the service is restored (which ever comes first).

#### Solution

To accomplish this we will configure a silence to suppress an alert (i.e. disabling event processing).
We'll use `sensuctl` to configure silencing in this lesson.
You can also configure silences from the Sensu Go web app, which we'll introduce in [Lesson 11].

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

   Let's modify the handler template we created in [Lesson 4](/lessons/operator/04/README.md#readme) and updated in [Lesson 6](/lessons/operator/06/README.md#readme).
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
   To obtain the current port mapping number run `sudo docker-compose port app 8080`._
   
   Within a few moments, Sensu should begin reporting the failure. 
   Run the `sensuctl event list` command to see the incident:
   
   ```shell
   $ sensuctl event list
         Entity         Check                                        Output                                      Status   Silenced             Timestamp           
    ───────────────── ──────────── ───────────────────────────────────────────────────────────────────────────── ──────── ────────── ───────────────────────────────
     workshop_app_1    app-health   http-check CRITICAL: HTTP Status 500 for http://workshop_app_1:8080/healthz        2   true       2021-10-23 15:34:11 -0700 PDT
   ```

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
   
   > **Understanding the command:**
   > - Setting `Subscription:*` or leaving the Subscription field blank means the silence will apply to events matching any subscription.
   > - Providing a check name (`Check: app-health`) means the silence will only apply to events from the app-health check
   > - The "Begin time", "Expiry in seconds", and "Expire on Resolve" settings let us control when Sensu will begin supressing alerts, and when Sensu should resume processing of alerts. 
   > - The "Reason" field lets us leave a comment or provide a description for the silence.


1. **Restore demo app to healthy status (curl -XPOST localhost:9000/healthz)**

   **Mac and Linux users:**
   
   ```shell
   curl -i -X POST http://127.0.0.1:9000/healthz
   curl -i -X GET http://127.0.0.1:9000/healthz
   ```
   
   **Windows users:**
   
   ```shell
   TODO
   ```
   

## Bulk Silencing

### Silencing all alerts on multiple hosts

### Silencing alerts from a specific service across multiple hosts

### EXERCISE 2: Bulk Silencing

## Scheduled Maintenance

### What is a scheduled maintenance window?

Scheduled maintenance window is a silence that starts and ends in the future. 

## EXERCISE 3: Configure a scheduled maintenance window

TODO

## Discussion

TODO: recap lesson.

### Maintenance Mode vs Scheduled Maintenance

Scheduled maintenance is a useful practice when a particular maintenance window requires human interaction (which inevitably requires coordination/scheduling of humans).
Maintenance mode is a useful practice when an automated system is performing automated maintenance... Sensu Silenced API allows automated systems to put a host in "maintenance mode" at the beginning of an automated maintenance, and then remove the silence when the automated maintenance task is completed.

[setup_workshop]: ../02/README.md#readme
[silencing-docs]: https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-process/silencing/
