# Lesson 9: Introduction to Check Hooks

- [Overview](#overview)
- [Use cases](#use-cases)
- [Advanced topics](#advanced-topics)
- [EXERCISE 1: configure a check hook](#exercise-1-configure-a-check-hook)
- [Learn more](#learn-more)
- [Next steps](#next-steps)


## Overview

Sensu Check Hooks are commands the Sensu Agent executes in response to a monitoring job (check) result.
Because these hooks are executed before event data is sent to the Sensu observabilty pipeline, they are great for enriching events with valuable context.
Sensu Check Hooks are designed for a form of SRE automation that we refer to as "automated diagnosis" – a codification of the actions an SRE or operations engineer might take to triage a monitoring incident (e.g. tail a log file or check the process table).
By automating diagnosis, Sensu can produce alerts and incidents full of context that can help IT Operations reduce mean time to recovery (MTTR).

**Example**

```yaml
---
type: HookConfig
api_version: core/v2
metadata:
  name: nginx-config-validation
  annotations:
    description: |
      Validate NGINX configuration to ensure that service interruption isn't
      the result of invalid configuration.
spec:
  command: sudo nginx -t
  timeout: 10

---
type: CheckConfig
api_version: core/v2
metadata:
  name: nginx-status
spec:
  command: >-
    check-nginx-status.rb
    --url {{ .annotations.check_nginx_status_url | default "http://127.0.0.1:80/nginx_status" }}
  runtime_assets:
    - sensu-plugins/sensu-plugins-nginx:3.1.2
    - sensu/sensu-ruby-runtime:0.0.10
  publish: true
  interval: 30
  subscriptions:
    - nginx
  timeout: 10
  check_hooks:
    - warning:
        - nginx-config-validation
    - critical:
        - nginx-config-validation
    - unknown:
        - nginx-config-validation
  handlers:
    - slack
```

In this example, we have configured a check hook to test NGINX configuration (`nginx -t`) to ensure the configuration is still valid.

## Use cases

Sensu Check Hooks are for collecting additional context (event enrichment), and should not be used for remediation purposes.

Some example Check Hook use cases include:

- Tail a log file (e.g. collect the last 30 seconds of log output)
- Check the system process table
- Validate configuration files
- Check file system metadata (e.g. last accessed or modified dates)
- Inspect processes (e.g. use `lsof` to see what files or ports a process is accessing)
- Check installed package version information

Many of the best check hook use cases make use of native system commands (e.g. `ps`, `tail`, `lsof`, `traceroute`, `nslookup`, `curl`, etc), but Check Hooks can also execute custom scripts.

## Advanced topics

### Check Hook reuse

Sensu Go Check Hooks are first-class API resources, which offers several benefits:

- Hooks can be reused across multiple monitoring jobs (checks)
- Access controls can be configured to restrict certain users from creating or modifying Hooks (e.g. end-users can be granted read-only access to authorized Hooks that are managed by Sensu administrators)
- Hook resource templates that automate common actions can be shared between teams, or even between organizations (i.e. in the Sensu Community)

## EXERCISE: configure a check hook

1. **Configure a Hook to evaluate the process tree.**

   Copy the following contents to a file named `ps.yaml`

   ```yaml
   ---
   type: HookConfig
   api_version: core/v2
   metadata:
     name: process-table
   spec:
     command: ps -aux
     timeout: 10
     stdin: false
     runtime_assets: []
   ---
   type: HookConfig
   api_version: core/v2
   metadata:
     name: process-table-windows
   spec:
     command: tasklist /svc
     timeout: 10
     stdin: false
     runtime_assets: []
   ```

1. **Create the Hook using `sensuctl create -f`.**

   ```shell
   sensuctl create -f ps.yaml
   ```

   Verify that the hook was created:

   ```
   sensuctl hook info process-table --format yaml
   ```

1. **Update the check configuration template to use the new Hook(s).**

   Let's modify the check template we created in [Lesson 8](/lessons/operator/08/README.md#readme) (e.g. `disk.yaml`), and replace the `check_hooks: []` line with the following:

   **Mac and Linux users:**

   ```yaml
   check_hooks:
   - non-zero:
     - process-table
   ```

   **Windows users:**

   ```yaml
   check_hooks:
   - non-zero:
     - process-table-windows
   ```

   In practice you may find it appropriate to bundle certain check hooks alongside the corresponding checks (e.g. add the check hook configuration to the check template file).

1. **Update the check using `sensuctl create -f`.**

   ```shell
   sensuctl create -f disk.yaml
   ```

   Now verify that the check was updated using `sensuctl` or the Sensu web app.

   ```shell
   sensuctl check info disk-usage --format yaml
   ```

## Learn more

- [[Documentation] "Sensu Hooks Reference" (docs.sensu.io)](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-schedule/hooks/)
- [[Blog Post] "Using Check Hooks" (sensu.io)](https://sensu.io/blog/using-check-hooks-a739a362961f)
- [[Blog Post] "Alert fatigue, part 3: automating triage & remediation with check hooks & handlers" (sensu.io)](https://sensu.io/blog/alert-fatigue-part-3-automating-triage-remediation-with-checks-hooks-handlers)

## Next steps

[Share your feedback on Lesson 09](https://github.com/sensu/sensu-go-workshop/issues/new?template=lesson_feedback.md&labels=feedback%2Clesson-09&title=Lesson%2009%20Feedback)

[Lesson 10: Introduction to Assets](../10/README.md#readme)
