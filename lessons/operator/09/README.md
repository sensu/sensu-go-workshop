# Lesson 9: Introduction to Check Hooks

- [Overview](#overview)
- [Use cases](#use-cases)
- [Advanced topics](#advanced-topics)
- [EXERCISE: configure a check hook](#exercise-configure-a-check-hook)
- [Learn more](#learn-more)

## Overview

==TODO: check hooks are for "automated diagnosis";
SRE automation...==

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
```

## Use cases

==TODO: check hooks are for collecting additional context (event enrichment), and should not be used for remediation.==

## Advanced topics

### Check Hook reuse

==TODO: hooks are resources too, can be referenced via multiple checks.==

## EXERCISE: configure a check hook

1. Configure a Hook to evaluate the process tree.

   Copy the following contents to a file named `ntp-hooks.yaml`

   ```yaml
   ---
   type: HookConfig
   api_version: core/v2
   metadata:
     name: ntp-config
   spec:
     command: cat /etc/ntp.conf
     timeout: 30
     stdin: false
     runtime_assets: []
   ---
   type: HookConfig
   api_version: core/v2
   metadata:
     name: ntp-peer-verification
   spec:
     command: ntpq -d
     timeout: 30
     stdin: false
     runtime_assets: []
   ```

1. Create the Hook using `sensuctl create -f`.

   ```shell
   sensuctl create -f ntp-config.yaml
   ```

   Verify that the hook was created:

   ```
   sensuctl hook list
   ```

1. Update the check configuration template to use the new Hook(s).

   Let's modify the check template we created in [Lesson 8](/lessons/operator/08/README.md#readme) (e.g. `ntp.yaml`), and replace the `check_hooks: []` line with the following:

   ```yaml
   check_hooks:
   - non-zero:
     - ntp-config
     - ntp-peer-verification
   ```

   In practice you may find it appropriate to bundle certain check hooks alongside the corresponding checks (e.g. add the check hook configuration to the check template file).

1. Update the check using `sensuctl create -f`.

   ```shell
   sensuctl create -f ntp.yaml
   ```

   Now verify that the check was updated using `sensuctl` or the Sensu web app.

   ```shell
   sensuctl check info ntp --format yaml
   ```

## Learn more

## Next steps

[Lesson 10: Introduction to Assets](../10/README.md#readme)
