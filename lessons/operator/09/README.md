# Lesson 9: Introduction to Hooks

- [Goals](#goals)
- [What are Hooks?](#what-are-hooks)
  - [Exercise 1: Capture Check Context Using a Hook](#exercise-1-capture-check-context-using-a-hook)
- [Discussion](#discussion)
- [Learn More](#learn-more)

## Goals

In this lesson we will introduce _check hooks_. 
You will learn how to use hooks to provide additional context to your check output. 

This lesson is intended for operators of Sensu and assumes you have [set up a local workshop environment][setup_workshop].

## What are Hooks? 

In Sensu a _hook_ is a command that an agent executes in response to a check result.
Because hooks are executed before the event is sent to the backend, they are great for enriching events with additional context.

We refer to this practice as  _automated diagnosis_. 
Hooks automate the actions an SRE or operations engineer might take to triage an incident (e.g. tail a log file or check the process table).
By automating these actions, Sensu makes it easier to differentiate between a false-positive alert and a priority incident.

### EXERCISE 1: Capture Check Context Using a Hook

#### Scenario

The `disk-usage` check is reporting an error because the disk is becoming full.
It would be helpful to include a list of files in the temp directory to see if there is a large temp file that we could delete.
Instead of shelling into the machine directly to get this information, you'd rather have Sensu capture it for you.

#### Solution

A check hook can be used to execute an additional command conditionally, based on the status of the check.
We can create a hook to list the files in the temp directory, and include that output alongside the regular check output.

#### Steps

1. **Create a Hook to List Files in the Temp Directory**
   
   Copy and paste the following contents to a file named `ls-temp.yaml`.
   
   ```yaml
   ---
   type: HookConfig
   api_version: core/v2
   metadata:
     name: ls-temp
   spec:
     command: ls -alh /var/tmp
     timeout: 10
     stdin: false
     runtime_assets: []
    
   ```

   Then create the hook using `sensuctl create`:

   ```shell
   sensuctl create -f ls-temp.yaml
   ```

1. **Add the Hook to the Check Configuration**

   Modify the check template we created in [Lesson 8](/lessons/operator/08/README.md#readme) (e.g. `disk.yaml`), and replace the `check_hooks: []` line with the following:
   
   ```yaml
   check_hooks:
   - non-zero:
     - ls-temp
   ```

   Then update the check using `sensuctl create`:

   ```shell
   sensuctl create -f disk.yaml
   ```
   
   > **PROTIP:** In practice, it is often convenient to bundle check hooks alongside the corresponding checks, by including both configurations in the same YAML file.

1. **Verify the Configuration**

   Verify that the check was updated using `sensuctl check info`.

   ```shell
   sensuctl check info disk-usage --format yaml
   ```

1. **Verify the Output**

   Verify that the hook output was included, by inspecting the event created by the `disk-usage` check:

   ```shell
   sensuctl event info workshop disk-usage --format json
   ```

   In the event JSON, the property `.check.hooks` should look something like this:

   **Example Output**
   
   ```json
   "hooks": [
      {
        "metadata": {
          "name": "ls-temp",
          "namespace": "default",
          "labels": {
            "sensu.io/managed_by": "sensuctl"
          },
          "created_by": "sensu"
        },
        "command": "ls -alh /var/tmp",
        "timeout": 10,
        "stdin": false,
        "runtime_assets": null,
        "duration": 0.021055335,
        "executed": 1634953321,
        "issued": 0,
        "output": "total 0\ndrwxrwxrwt   5 root     wheel   160B Oct 22 17:35 .\ndrwxr-xr-x  32 root     wheel   1.0K Oct 19 10:24 ..\ndrwxr-xr-x   3 root     wheel    96B Sep 15 10:52 aud\nsrw-r--r--   1 thoward  wheel     0B Sep 30 10:32 filesystemui.socket\ndrwxr-xr-x   2 root     wheel    64B Sep 15 10:52 kernel_panics\n",
        "status": 0
      }
   ]
   ```

## Discussion

In this lesson you learned how to create a hook that added some additional context to a check.

Hooks are reusable resources that can enrich your data and save a lot of time when debugging.

### Hooks are Not Remediations

It may seem like hooks would also be a perfect tool for automatic remediations.
However, we strongly discourge using hooks for this.

Remediations are best done using handlers, like the [`sensu-remediation-handler`][sensu-remediation-handler], or the product-specific handlers for [Ansible Tower][sensu-ansible-handler], [Rundeck][sensu-rundeck-handler], and [SaltStack][sensu-saltstack-handler].

The main difference is that handlers are run by the backend, so logging, secret injection, auditing, and access via the dashboard are available.
A hook is a simple command, run on the agent, without the rest of the infrastructure that the backend and pipeline provide.

Learn more about automated remediations in our [Patterns and Workflows](#) section  _(coming soon!)_.

### Uses Cases

So, now that we know how you should *not* use hooks, here are some examples of use cases we *do* suggest:

- Tail a log file
- Check the system process table
- Validate configuration files
- Check file system metadata (e.g. last accessed or modified dates)
- Inspect processes (e.g. use `lsof` to see what files or ports a process is accessing)
- Check installed package version information
- Check kernel version and platform information
- Literally any action you might perform as an operator to get additional context about an alert

For full details, read the [hooks reference documentation](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-schedule/hooks/). 

### Hook Assets 

Like checks, hooks are able to specify assets that they need to run.
If your hook needs more complex behavior than a simple one-line shell action, consider packaging it as an asset instead of in-line in the YAML configuration.

## Learn More
- [[Documentation] "Sensu Hooks Reference" (docs.sensu.io)](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-schedule/hooks/)
- [[Blog Post] "Using Check Hooks" (sensu.io)](https://sensu.io/blog/using-check-hooks-a739a362961f)
- [[Blog Post] "Alert fatigue, part 3: automating triage & remediation with check hooks & handlers" (sensu.io)](https://sensu.io/blog/alert-fatigue-part-3-automating-triage-remediation-with-checks-hooks-handlers)

## Next Steps

[Next - Lesson 10: Introduction to Silencing & Scheduled Maintenance](../10/README.md#readme)

[Previous - Lesson 8: Introduction to Checks](../08/README.md#readme)

[Feedback - Share your feedback on Lesson 9](https://github.com/sensu/sensu-go-workshop/issues/new?template=lesson_feedback.md&labels=feedback%2Clesson-09&title=Lesson%209%20Feedback)

<!-- Some Commonly Used Named Links -->
[setup_workshop]: ../02/README.md#readme
[sensu_api_docs]: https://docs.sensu.io/sensu-go/latest/api/
[sensu-remediation-handler]: https://github.com/sensu/sensu-remediation-handler 
[sensu-ansible-handler]: https://bonsai.sensu.io/assets/sensu/sensu-ansible-handler
[sensu-rundeck-handler]: https://bonsai.sensu.io/assets/sensu/sensu-rundeck-handler
[sensu-saltstack-handler]: https://bonsai.sensu.io/assets/sensu/sensu-saltstack-handler

