# Sensu Go Workshop

- [Overview](#overview)
  - [What is Sensu?](#what-is-sensu)
  - [Observability Pipeline](#observability-pipeline)
- [Workshop](#workshop)
  - [Setup](#setup)
  - [Lesson 1: Introduction to Sensu Go](#lesson-1-introduction-to-sensu-go)
    - Configure a handler to process observability data
    - Publish your first event to the Sensu observability pipeline 
    - Publish resolution events 
    - Introduction to entities 
    - Enriching observations with additional context 
  - [Lesson 2: Introduction to `sensu-agent`](#lesson-2-introduction-to-sensu-agent)

## Overview 

This project is intended to provide a simple template for developing training 
modules for Sensu Go. The workshop lessons outlined below are effectively the 
introductory modules – they are designed to help new Sensu users learn the 
basic concepts of an [Observability Pipeline][0-0] and help them get started 
with Sensu Go. 

This project has also be designed with both self-guided learning _and_ 
instructor-led training workshops in mind. It's easy to deploy the workshop 
environment on a laptop for personal use, or to a shared server (or cloud 
provider) for multiple users. See [SETUP.md][0-1] for more information on 
setting up the workshop environment. 

### What is Sensu?

==COMING SOON==

### Observability Pipeline 

==COMING SOON==

## Workshop

### Setup

This workshop is designed to be simple enough for self-guided training, while 
also providing a tool for trainers to host a workshop for multiple attendees. 
See [SETUP.md][0-1] for more details on setting up the workshop environment. 

Once you have deployed a workshop environment, you may proceed with the 
following local workstation setup instructions which will help you install 
the Sensu Go CLI (`sensuctl`) and connect to your workshop environment.

1. **Clone this repository & configure your local environment.**  

   Self-guided trainees may skip this step, as you should have already 
   downloaded the workshop materials as part of the instructions in 
   [SETUP.md][0-1].

   ```
   $ git clone git@github.com:calebhailey/sensu-go-workshop.git 
   $ cd sensu-go-workshop/ 
   $ export $(cat .env | grep -v "#" | grep =)
   $ echo $WORKSHOP_VERSION
   0.2.0
   ```

   > _NOTE: if you don't see a workshop version number printed out after the 
   > `echo $WORKSHOP_VERSION` command, please check with your instructor._   
   
2. **Visit the Sensu web app!**  

   - **Self guided trainees**: please visit http://127.0.0.1:3000 and login 
     with the default workshop username (`sensu`) and password (`sensu`).  
   - **Instructor-led workshop trainees**: please use the URL, username, and 
     password as provided your instructor.  
     
   You should see a login screen that looks like this: 
   
   ![](docs/img/login.png)
     
   > _TROUBLESHOOTING: no login screen? Please consult with your instructor, or
   > double-check that you complete all of the steps in [SETUP.md][0-1] before 
   > proceding._

3. **Install and configure a local `sensuctl` (the Sensu Go CLI).**  

   Mac users:

   ```
   $ curl -LO "https://s3-us-west-2.amazonaws.com/sensu.io/sensu-go/${SENSU_CLI_VERSION}/sensu-go_${SENSU_CLI_VERSION}_darwin_amd64.tar.gz"
   $ sudo tar -xzf "sensu-go_${SENSU_CLI_VERSION}_darwin_amd64.tar.gz" -C /usr/local/bin/
   ```

   > _NOTE: Linux and Windows users can find [installation instructions][0-2] 
   > in the Sensu [user documentation][0-3]. The complete list of Sensu 
   > downloads is available at https://sensu.io/downloads._

   Configure the Sensu CLI to connect to your backend by running the `sensuctl 
   configure` command. Sensuctl will prompt you to provide a Sensu Backend URL, 
   username, password, namespace, and preferred output format.  
   
   ```
   $ sensuctl configure
     ? Sensu Backend URL: http://127.0.0.1:8080
     ? Username: sensu
     ? Password: *****
     ? Namespace: default
     ? Preferred output format:
     ❯ tabular
       yaml
       wrapped-json
       json
   ```
   
   > _NOTE: self-guided trainees who are running the workshop on their local 
   > workstation should use the default backend URL (`http://127.0.0.1:8080`), 
   > username (`sensu`), and password (`sensu`). Trainees in instructor-led 
   > workshops should use the URL and credentials provided by the instructor._
   
4. **Create an API Key.**  

   To create a [Sensu API Key][0-4], use the `sensuctl api-key grant` command: 
   
   ```
   $ sensuctl api-key grant sensu
   Created: /api/core/v2/apikeys/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
   ```
   
   For our purposes, we want to capture this API key (the 
   `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` part of the output) as an environment
   variable. You can either copy the output from the `sensuctl api-key grant`
   command manually, like this: 
   
   ```
   $ export SENSU_API_KEY=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
   ```
   
   Or run the following command: 
   
   ```
   $ export SENSU_API_KEY=$(sensuctl api-key grant sensu | awk -F "/" '{print $NF}')
   ```
   
   > _NOTE: self-guided trainees should grant an api-key for the `sensu` user,
   > as shown above. Trainees in instructor-led workshops should create an 
   > api-key for their own user, using the username provided by the instructor 
   > (e.g. `sensuctl api-key grant <username>`)._ 
   
### Lesson 1: introduction to Sensu Go

The following guide will walk you through the basic concepts behind the 
observability pipeline, and prepare you to start configuration your own 
monitoring and observability workflows using Sensu. The guide starts with a 
fresh Sensu installation, and assumes certain companion services are available 
(e.g. a data platform such as Prometheus, TimescaleDB, Elasticsearch, or 
Splunk; and a graphing solution such as Grafana, Kibana, or Splunk's built-in 
dashboards). 

Multiple reference architectures will be provided for use with this workshop. 
Please consult [SETUP.md][0-1] for more information. 

1. **Configure an handler to process observability data.**

   The first thing we need to do with a fresh Sensu installation is configure 
   one or more [Sensu event handlers][1-1] to process observability data. 
   Handlers are actions the Sensu backend executes on events, such as sending 
   alerts or routing events and metrics to one or more data platforms.
   
   Handlers are sometimes referred to as "integrations" since they let you 
   connect Sensu to tools like Slack, Pagerduty, ServiceNow, Jira, InfluxDB,
   Prometheus, TimescaleDB, Elasticsearch, Splunk, and many many more. 
   
   To get started, let's configure the Sensu Pagerduty handler using the 
   template provided with this workshop (see 
   `lessons/1/pipelines/pagerduty.yaml`):

   ```
   $ sensuctl create -f lessons/1/pipelines/pagerduty.yaml
   $ sensuctl handler list
       Name      Type   Timeout           Filters            Mutator              Execute              Environment Variables                 Assets
    ─────────── ────── ───────── ────────────────────────── ───────── ─────────────────────────────── ─────────────────────── ─────────────────────────────────────
     pagerduty   pipe         0   is_incident,not_silenced             RUN:  sensu-pagerduty-handler                           sensu/sensu-pagerduty-handler:1.3.2
   ```
   
   Congratulations! You just configured your first Sensu handler! 

2. **Publish an event to the pipeline.** 

   Let's publish our first event to the pipeline using `curl` and the 
   [Sensu Events API][1-2].  

   ```
   $ curl -i -X POST -H "Authorization: Key ${SENSU_API_KEY}" \
          -H "Content-Type: application/json" \
          -d '{"entity":{"metadata":{"name":"server-01"}},"check":{"metadata":{"name":"my-app"},"interval":30,"status":2,"output":"ERROR: failed to connect to database."}}' \
          "http://127.0.0.1:8080/api/core/v2/namespaces/${SENSU_NAMESPACE}/events"
   ```  
   
   > _NOTE: This command and all subsequent `curl` commands should generate 
   > output that starts with `HTTP/1.1 200 OK`, `HTTP/1.1 201 Created`, or 
   > `HTTP/1.1 202 Accepted`. If you do not see this output, or if you 
   > received an error message, please ensure that you completed all of the 
   > steps under [Setup](#setup) (above), and/or ask your instructor for help._
   
   What happens when Sensu processes an event? We should now be able to see the
   event in Sensu using `sensuctl` or the Sensu web app.  

   ```
   $ sensuctl event list
        Entity        Check                                     Output                                   Status   Silenced             Timestamp                             UUID                  
    ────────────── ─────────── ──────────────────────────────────────────────────────────────────────── ──────── ────────── ─────────────────────────────── ────────────────────────────────────── 
     405628f1ce39   keepalive   Keepalive last sent from 405628f1ce39 at 2020-08-06 22:23:02 +0000 UTC        0   false      2020-08-06 15:23:02 -0700 PDT   c88b8116-7196-4052-94c7-546e7e45969a  
     server-01      my-app      ERROR: failed to connect to database.                                         2   false      2020-08-06 15:19:57 -0700 PDT   8434c06f-ed34-4ac6-b0fb-343c1fc492a0  
   ```   
   
   But did we get an alert in Pagerduty? No! Sensu processes each event using 
   one or more event handlers, but since this event didn't reference any 
   handlers there was no action for Sensu to take. To trigger an event handler
   we'll need to modify our event with `"handlers": ["pagerduty"]`. Let's 
   try it again: 
   
   ```
   $ curl -i -X POST -H "Authorization: Key ${SENSU_API_KEY}" \
          -H "Content-Type: application/json" \
          -d '{"entity":{"metadata":{"name":"server-01"}},"check":{"metadata":{"name":"my-app"},"interval":30,"status":2,"output":"ERROR: failed to connect to database.","handlers":["pagerduty"]}}' \
          "http://127.0.0.1:8080/api/core/v2/namespaces/${SENSU_NAMESPACE}/events"
   ``` 
   
   Success! 

3. **Publish a resolution event.**

   All Sensu events are required to indicate an event "status", which is used
   to indicate event severity. Status `0` indicates a "Healthy" or "OK" event, 
   status `1` indicates a "Warning" severity event, and status `2` indicates a
   "Critical" severity event; all other status codes (up to `255`) are treated
   as "Unknown" severity.  
   
   If you inspect the event we sent in our previous step, we created a critical
   severity event (i.e. `"status": 2`). Now let's modify our event payload to 
   indicate that our service has recovered by setting `"status": 0` and 
   updating the `output` field with an appropriate message (e.g. `"output": 
   "200 OK"`).  

   ```
   $ curl -i -X POST -H "Authorization: Key ${SENSU_API_KEY}" \
          -H "Content-Type: application/json" \
          -d '{"entity":{"metadata":{"name":"server-01"}},"check":{"metadata":{"name":"my-app"},"interval":30,"status":0,"output":"200 OK","handlers":["pagerduty"]}}' \
          "http://127.0.0.1:8080/api/core/v2/namespaces/${SENSU_NAMESPACE}/events"
   ```
   
   What happened? Did you notice that the event is now "green" in the Sensu web
   app, and our Pagerduty incident should have been automatically resolved.  
   
4. **Introduction to entities.**

   In Sensu, every event must be associated with an [Entity][1-3]. An Entity 
   represents **anything** that needs to be monitored, such as a physical or 
   virtual "server", cloud compute instance, container (or "pod" of 
   containers), application, function, IoT device, or network switch (or pretty
   much anything else you can imagine). 
   
   If you look at your Sensu entity list you'll note that you already have at 
   least one entity (including one named "server-01"). Sensu automatically 
   created this entity when we published our first event data to the pipeline.

   > _NOTE: to find the Sensu entity list, run the `sensuctl entity list` or
   > `sensuctl entity info server-01` command(s), or select the "Entities" view 
   > in the sidebar of the Sensu web app. Self-guided trainees should find this 
   > view at: http://127.0.0.1:3000/c/~/n/default/entities._ 

   > **PROTIP:** the default output format of the `sensuctl` CLI is a "tabular"
   > style output, intended for display in your terminal. For machine-parsable 
   > output, try using the `--output` flag. The available output formats are 
   > `tabular` (default), `yaml`, `json`, and `wrapped-json`. Give it a try 
   > with the entity list or entity info commands; for example: 
   > 
   > ```
   > $ sensuctl entity list --format json
   > ```
   
   Let's publish another event with a different entity name and see what 
   happens:
   
   ```
   $ curl -i -X POST -H "Authorization: Key ${SENSU_API_KEY}" \
          -H "Content-Type: application/json" \
          -d '{"entity":{"metadata":{"name":"server-02"}},"check":{"metadata":{"name":"my-app"},"status":0,"interval":30,"output":"200 OK","handlers":["pagerduty"]}}' \
          "http://127.0.0.1:8080/api/core/v2/namespaces/${SENSU_NAMESPACE}/events"
   ```
   
   Do you see a new entity in Sensu? When Sensu processes an event that 
   references a new entity name, it will automatically create an entity 
   resource in the API.  

4. **Enrich observations with additional context.**  

   As we learned in step 3, every observation (i.e. every event) in Sensu must 
   be associated with an [Entity][1-3], and if no such entity exists in Sensu 
   when an event is processed, Sensu will automatically an entity for you. When
   an event is processed for an entity that is already registered, Sensu will 
   overwrite the event `"entity"` information with the information from the 
   [Sensu Entities API][1-4]. 

   The [Sensu Entities API][1-4] is effectively a discovery API – you can use 
   it to register entities and provide context about them; e.g. what cloud 
   provider does a compute instance running in, or for IoT devices – what 
   make/model are they and where are they located? Sensu provides it's own 
   built-in discovery solution (i.e. the Sensu Agent, which we'll explore in 
   Lesson 2), so the Entities API is primarily useful for extending Sensu's own
   capabilities – and it's _very easy_ to use. 

   Let's try providing some context about our "server-01" entity by adding some
   label data via the Entities API:

   ```
   $ curl -i -X PUT -H "Authorization: Key ${SENSU_API_KEY}" \
     -H "Content-Type: application/json" \
     -d "{
          \"metadata\": {
            \"name\": \"server-01\",
            \"namespace\": \"${SENSU_NAMESPACE}\",
            \"labels\": {
              \"app\": \"workshop\",
              \"environment\": \"production\"
            }
          },
          \"entity_class\": \"proxy\"                    
        }" \
     "http://127.0.0.1:8080/api/core/v2/namespaces/${SENSU_NAMESPACE}/entities/server-01"
   ```
   
   Alternatively, please modify the file at `lessons/1/entities/server-01.json`
   and run the following command: 

   ```
   $ curl -i -X PUT -H "Authorization: Key ${SENSU_API_KEY}" \
     -H "Content-Type: application/json" \
     -d @lessons/1/entities/server-01.json \
     "http://127.0.0.1:8080/api/core/v2/namespaces/${SENSU_NAMESPACE}/entities/server-01"
   ```

   If you consult the Sensu Entity list again (via the web app or `sensuctl`),
   you should see that "server-01" now has some additional metadata associated 
   with it, and this metadata will now be attached to _every_ event we process 
   for this entity. 

   Try experimenting with adding metadata to your checks as well. For example, 
   you can add labels to the `"check"` data as well:
   
   ```
   $ curl -i -X POST -H "Authorization: Key ${SENSU_API_KEY}" \
          -H "Content-Type: application/json" \
          -d '{"entity":{"metadata":{"name":"server-01"}},"check":{"metadata":{"name":"my-app","labels":{"app":"workshop"}},"interval":30,"status":0,"output":"200 OK","handlers":["pagerduty"]}}' \
          "http://127.0.0.1:8080/api/core/v2/namespaces/${SENSU_NAMESPACE}/events"
   ```

   > **PROTIP:** almost every resource in Sensu offers support for resource 
   > metadata, including a `name`, `labels`, and `annotations`. Labels and 
   > annotations are identical in format (i.e. `"key": "value"` pairs; all 
   > values must be strings), but they serve different purposes. Labels are 
   > used as selectors (e.g. for "filtering" resources), whereas annotations 
   > are not. Annotations are great for storing additional data for processing 
   > in the pipeline, or in third-party systems. 

6. **Event filtering.**  

   By default, Sensu will process every event that is published to the pipeline 
   using one or more event handlers. But not every event should result in an 
   action (e.g. Pagerduty alert or Slack notification)! To help with this, 
   Sensu provides powerful [Event Filters][x-x] that analyze events in 
   real-time and decide whether they should be processed (handled) or not.

   Sensu Event filters can be inclusive (only matching events are processed) or
   exclusive (matching events are not processed). Sensu can evaluate events 
   based on the contents of the event payload alone, or it can compare the 
   event contents with other state information (e.g. don't process events from
   an application if the database it depends on is experiencing an outage). 
   Sensu Event filters can even consult third-party services as part of the 
   analysis.

   Let's create a filter to prevent processing any event that's not part of the
   "production" environment. If you look at the provided example event filter 
   at `lessons/1/production-only.yaml`, you'll see that we're configuring an 
   _inclusive_ filter for events associated with entities that have the 
   `"environment": "production"` label (which we added to "server-01" in step 4
   above). 

   ```
   $ sensuctl create -f lessons/1/shared/production-only.yaml
   ```

   Now let's modify our Pagerduty handler to apply this filter by modifying the
   contents of `lessons/1/pipelines/pagerduty.yaml` as follows: 

   ```
   filters:
   - is_incident
   - not_silenced 
   - production-only
   ```

   Now let's update Sensu with the revised Pagerduty configuration: 

   ```
   $ sensuctl create -f lessons/1/pagerduty.yaml
   ```
   
   Now let's create two new "critical" severity events – one for each of 
   "server-01" and "server-02". 

   ```
   $ curl -i -X POST -H "Authorization: Key ${SENSU_API_KEY}" \
          -H "Content-Type: application/json" \
          -d '{"entity":{"metadata":{"name":"server-01"}},"check":{"metadata":{"name":"my-app"},"interval":30,"status":2,"output":"ERROR: failed to connect to database.","handlers":["pagerduty"]}}' \
          "http://127.0.0.1:8080/api/core/v2/namespaces/${SENSU_NAMESPACE}/events"
   $ curl -i -X POST -H "Authorization: Key ${SENSU_API_KEY}" \
          -H "Content-Type: application/json" \
          -d '{"entity":{"metadata":{"name":"server-02"}},"check":{"metadata":{"name":"my-app"},"interval":30,"status":2,"output":"ERROR: failed to connect to database.","handlers":["pagerduty"]}}' \
          "http://127.0.0.1:8080/api/core/v2/namespaces/${SENSU_NAMESPACE}/events"
   ```

   > **PROTIP:** Sensu filters are Javascript expressions, executed in a 
   > sandboxed Javascript runtime environment. These expressions can be as 
   > simple as basic comparison operations (e.g. "less than" `<` or "greater 
   > than" `>`, "equal to" `==` or "not equal" `!=`), or as complex as a small
   > Javascript program. You can even import Javascript libraries into the 
   > sandbox environment! 

### Lesson 2: introduction to `sensu-agent`

In lesson 1, we introduced some high-level concepts and APIs that are the 
building blocks of the Sensu observability pipeline. In lesson 2, we'll 
introduce the Sensu Agent – a simple yet powerful event producer that works in
concert with the Sensu backend to form a comprehensive observability solution.

1. Install and configure your first agent 

   ```
   $ sudo docker-compose run --no-deps -d --rm \
     -e SENSU_NAMESPACE=${SENSU_NAMESPACE} \
     -e SENSU_LABELS='{"app": "workshop", "environment": "production"}' \
     sensu-agent
   ```   

   ```
   $ sudo docker run -d --rm --network sensu -p :3030 \
     sensu/sensu:${SENSU_AGENT_VERSION} sensu-agent start \
     --backend-url ws://sensu-backend:8081 --deregister \
     --keepalive-interval=5 --keepalive-warning-timeout=10 --subscriptions workshop,linux
   ```

   ```
   C:\> docker.exe run -d --rm --network sensu -p :3030 `
        sensu/sensu:5.21.1 sensu-agent start `
        --backend-url ws://sensu-backend:8081 --deregister `
        --keepalive-interval=5 --keepalive-warning-timeout=10 --subscriptions workshop,linux
   ```
   
2. Publish events to the pipeline via the Agent API 

   ```
   $ curl -i -X POST -d '{"check":{"metadata":{"name":"my-app"},"interval":30,"status":2,"output":"ERROR: failed to connect to database.","handlers":["pagerduty"]}}' \
     "http://127.0.0.1:3031/events"
   ```
   
3. Configure your first check/monitor (automated event collection)

   ==COMING SOON==

4. Output Metric Extraction 

   ==COMING SOON==

5. Agent StatsD Socket 

   ==COMING SOON==



[0-0]:  #observability-pipeline 
[0-1]:  /docs/SETUP.md
[0-2]:  https://docs.sensu.io/sensu-go/latest/operations/deploy-sensu/install-sensu/#install-sensuctl
[0-3]:  https://docs.sensu.io/sensu-go/latest/
[0-4]:  https://docs.sensu.io/sensu-go/latest/reference/apikeys/

[1-1]:  https://docs.sensu.io/sensu-go/latest/reference/handlers/
[1-2]:  https://docs.sensu.io/sensu-go/latest/api/events/
[1-3]:  https://docs.sensu.io/sensu-go/latest/reference/entities/
[1-4]:  https://https://docs.sensu.io/sensu-go/latest/api/entities/
[1-5]:  https://docs.sensu.io/sensu-go/latest/reference/filters/ 

[x-x]: #
