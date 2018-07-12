# Monitoring Event Pipeline Demo

## What is Sensu?

Sensu is _the_ cloud native infrastructure and application monitoring event
pipeline. Get complete visibility from bare metal to kubernetes &ndash; **every
system, every protocol, every time**. Sensu is the solution to the monitoring
problems facing modern enterprises today, and the right foundation for your
organization tomorrow.

### What is a monitoring event pipeline?

![](docs/images/sensu-server.png)

### What can you do with a monitoring event pipeline?

Sensu is a framework for hybrid cloud infrastructure and application _monitoring
workflow automation_.

- **Consolidate monitoring tools** (Nagios, synthetics, etc)
- Automate system reliability & **improve SRE retention**
- Automated **compliance monitoring** (inspec, osquery)
- Enterprise monitoring **governance solution**

Here are just a few example workflows:

![](docs/images/sensu-server-example-pipelines.png)

### What are monitoring events?

Monitoring events are an abstraction for service health information, telemetry
data, discovery, and alerts.

```
{
  "source": "web-server-01",
  "name": "web_service",
  "environment": "production",
  "region": "us-west-1",
  "status": 2,
  "output": "HTTP/1.1 404 Not Found",
  "handlers": ["pagerduty","influxdb"],
  "contacts": ["web_team"]
}
```

### The Sensu Agent &ndash; a powerful event producer

The Sensu Agent provides compatibility with popular and standards-based
interfaces, and converts their outputs into monitoring events that can be
processed by the Sensu backend.

Some example interfaces include Nagios/Icinga/Zabbix plugins, Prometheus
endpoints (exporting Prometheus metrics), StatsD, SNMP, and more.

![](docs/images/monitoring-event-pipeline.png)

## Demo

Enough talk, let's walk through a hands-on demo. Clone this repository, and
follow along this guide to get started automating your monitoring workflows
today!

### Setup

1. **Provision the Vagrant box**. The first thing we'll need is a running
   Sensu installation. Replace the `REPLACEME` strings below with your Sensu
   Enterprise repository username and password, and then run `vagrant up`.

   ```
   $ export VAGRANT_DEFAULT_PROVIDER=vmware_fusion
   $ export SE_USER=REPLACEME
   $ export SE_PASS=REPLACEME
   $ vagrant up
   ```

   That's it! You should now have a complete Sensu server installation running
   locally, with Sensu's API and other ports mapped to you localhost address
   space for further testing beyond this guide. This Vagrant VM also has a few
   extras installed, including [InfluxDB][1] and [Grafana][2], which we will use during
   this guide.

   _NOTE: installing Vagrant is left as an exercise for the reader; please
   visit [vagrantup.com](vagrantup.com) for more information._

   [1]: https://influxdata.com
   [2]: https://grafana.com

1. **Connect to the virtual machine**. The remainder of this guide assumes you
   are editing files and executing commands from the Sensu Vagrant VM.

   ```
   $ vagrant ssh
   ```

   References to viewing dashboards (including Sensu and Grafana dashboards;
   e.g. http://localhost:3000) should be accessible from your host system due to
   the above stated port mappings.

   OK &ndash; LET'S HAVE SOME FUN!

### Workshops

#### Introducing the Monitoring Event Pipeline

The following guide will walk you through the basic monitoring event pipeline
concepts and prepare you to start configuration your own monitoring workflow
automations using Sensu. The guide starts with a fresh Sensu installation, and
assumes some extra niceties are installed (e.g. the `jq` utility), as provided
for in the Sensu Vagrant VM and installation guide, above.

1. **Configure one or more handlers**. The first thing we need to do with a
   fresh Sensu installation is configure the handlers that will perform the
   actions in our workflows (e.g. sending an email or slack notification).

   For this workshop, we're going to use the Sensu Slack hander. Copy the
   following configuration to a file located at
   `/etc/sensu/conf.d/handlers/slack.json`:

   ```
   {
     "slack": {
       "webhook_url": "REPLACEME",
       "username": "Sensu",
       "icon_url": "http://www.gravatar.com/avatar/9b37917076cee4e2d331a785f3426640",
       "channel": "#demo",
       "timeout": 10
     }
   }
   ```

   _**NOTE**: this might be obvious, but you'll need to replace the text `REPLACEME`
   with a Slack ["Incoming Webhook"][incoming-webhook] URL._  

   Let's also create a second handler for sending telemetry data to InfluxDB.
   Copy the following configuration to a file located at
   `/etc/sensu/conf.d/handlers/influxdb.json`:

   ```
   {
    "influxdb": {
      "host": "127.0.0.1",
      "port": 8086,
      "database": "sensu",
      "username": "admin",
      "password": "admin",
      "api_version": "0.9",
      "tags": {
        "dc": "us-central-1"
      }
    }
   }
   ```

   Since we're hand editing JSON configuration files, it's usually a good idea
   to make sure our files are valid JSON (i.e. no syntax errors). We can do this
   pretty easily with a handy little utility called `jq`:

   ```
   $ cat /etc/sensu/conf.d/influxdb.json | jq .
   {
    "influxdb": {
      "host": "127.0.0.1",
      "port": 8086,
      "database": "sensu",
      "username": "admin",
      "password": "admin",
      "api_version": "0.9",
      "tags": {
        "dc": "us-central-1"
      }
    }
   }
   ```

   If you see nicely formatted JSON output, you're all set! However, if you see \
   a message like `parse error: Expected separator between values at line 7,
   column 13` you have an invalid JSON file (e.g. you could be missing a
   quotation mark or a comma, etc); compare your file with the examples we
   provided above and try again.  

   Do this for both of the `slack.json` and `influxdb.json` files to make sure
   we get things off to a good start. We won't remind you to do this for the
   rest of this tutorial, but it's a pretty good habit to get into. Once you're
   ready to start deploying Sensu into a production environment, you'll probably
   want to use a configuration management solution like [Puppet][puppet],
   [Chef][chef], or [Ansible][ansible] to manage these files automatically.

   Once you have confirmed your JSON files are valid, let's go ahead and reload
   or restart the Sensu server. You now have a pipeline with two workflows,
   ready to accept incoming events!

   ```
   $ sudo systemctl reload sensu-enterprise
   ```

1. **Publish your first event to the pipeline**. Let's publish our first events
   to the pipeline, using `curl` and the [Sensu Results API][results-api].

   ```
   $ curl -s -XPOST -H 'Content-Type: application/json' \
   -d '{"source": "web-server-01", "name": "web_service", "output": "error!", "refresh": 1, "status": 1}' \
   http://127.0.0.1:4567/results
   ```

   Did you notice? Nothing happened when we published our event, because we
   didn't indicate which workflow we wanted to use to process, or "handle" the
   event!

   Now let's add the `"handlers"` attribute to our event payload and provide one
   or more handlers (i.e. "workflows") to tell our pipeline how to process our
   event:

   ```
   $ curl -s -XPOST -H 'Content-Type: application/json' \
   -d '{"source": "web-server-01", "name": "web_service", "output": "error!", "refresh": 1, "status": 1, "handlers": ["slack"]}' \
   http://127.0.0.1:4567/results
   ```

   Voila! A Slack notification!

1. **Modify behaviors using event attributes**. Let's see what other behaviors
   we can modify. If you take a look at your Sensu dashboard right now (by
   visiting http://localhost:3000/#/clients in your browser), you'll see that
   you have a single entity called `"web-server-01"` in your client registry.
   Let's make things more interesting by sending another event that is
   associated with a different device/system/service, using the `"source"`
   attribute.

   ```
   $ curl -s -XPOST -H 'Content-Type: application/json' \
   -d '{"source": "web-server-02", "name": "web_service", "output": "error!", "refresh": 1, "status": 1, "handlers": ["slack"]}' \
   http://127.0.0.1:4567/results
   ```

   Notice in your dashboard that Sensu has created another "client" (which could
   represent a device, host, compute instance, etc) and associated our event
   with it. However, have you noticed that Sensu doesn't know anything about our
   clients other than the name we've provided? Let's fix that!

1. **Provide context about the systems you're monitoring using discovery
   events**. Let's provide some "client" (host) metadata using the [Clients
   API][clients-api]. This is effectively a "discovery event" (everything is an
   event!).

   ```
   $ curl -s -XPOST -H 'Content-Type: application/json' \
   -d '{"name": "web-server-02", "address": "10.0.2.102", "subscriptions": ["demo"]}' \
   http://127.0.0.1:4567/clients
   ```

   Now see that Sensu has updated our client with the IP address we've provided.
   Because Sensu events are just JSON data, we can decorate our client with as
   much metadata as we want. It is important to note that there are no
   dependencies here that would prevent an event from being processed due to a
   lack of client metadata.

   To further demonstrate the flexibility here, let's add a custom metadata
   property called `"environment"`:

   ```
   $ curl -s -XPOST -H 'Content-Type: application/json' \
   -d '{"name": "web-server-02", "address": "10.0.2.102", "subscriptions": ["demo"], "environment": "production"}' \
   http://127.0.0.1:4567/clients
   ```

   Go ahead and send a few more discovery events to add more details to our
   `"web-server-02"` client to emulate some data you would like to see about
   systems you'll use Sensu to monitor (e.g. `"store-id": 1234`, or how about
   `"manufacturer": "arista"` and `"model": "7516R"`).

   _NOTE: please do not send any discovery events for `"web-server-01"` at this
   time. Later on in this tutorial we will expect for `"web-server-01"` to be
   **missing** the `"environment": "production"` attribute. Spoiler alert!_

1. **Publish service recovery events**. Now let's send some events to indicate
   that both of our services have restored and are now healthy.

   ```
   $ curl -s -XPOST -H 'Content-Type: application/json' \
   -d '{"source": "web-server-01", "name": "web_service", "output": "ok!", "refresh": 1, "status": 0, "handlers": ["slack"]}' \
   http://127.0.0.1:4567/results
   $ curl -s -XPOST -H 'Content-Type: application/json' \
   -d '{"source": "web-server-02", "name": "web_service", "output": "ok!", "refresh": 1, "status": 0, "handlers": ["slack"]}' \
   http://127.0.0.1:4567/results
   ```

   _NOTE: Sensu events conform to the familiar and proven convention introduced
   by Nagios: `0` = "Healthy", `1` = Warning, and `2` = Critical._

1. **Publish telemetry events**. Let's try sending some performance data (i.e.
   "metrics") in an event, and let's process this data using our "influxdb"
   handler (to send the metrics to the InfluxDB time series database, or
   "TSDB"). To start, let's send the metric data using the [InfluxDB Line
   Protocol][influxd-line-protocol].

   Almost all TSDB formats expect metric data points in plain text strings. For
   the InfluxDB Line Protocol that string contains a measurement name (e.g.
   `weather`), followed by a space, then any number of "field=value" pairs,
   separated by commas (e.g. `temperature=82,humidity=0.65`), followed by
   another space, then finally a timestamp in seconds since Unix epoch (e.g.
   `1531371504`).  

   ```
   weather temperature=82,humidity=0.65 1531371504
   ```

   ```
   $ curl -s -XPOST -H 'Content-Type: application/json' \
   -d '{"source": "web-server-02", "name": "web_service_response", "output": "web_service value='`echo $RANDOM`' '`date +%s`'", "refresh": 1, "status": 0, "type": "metric", "output_format": "influxdb_line", "handlers": ["influxdb"]}' \
   http://127.0.0.1:4567/results
   ```

   > **HUH?**: in case you are looking at this event and scratching your head,
   this sidebar is for you. For our tutorial, we're using a few basic Bash shell
   tricks to generate an InfluxDB Line Protocol compatible metric, and wrapping
   it in a Sensu Event compatible JSON data payload. For our demo, we're
   creating a metric with the measurement name `web_service` and a value called
   `value`. To generate dynamic results we'll use the [`$RANDOM` environment
   variable][random] to return a random value between 0 and 32767. Finally, to
   generate our timestamp we'll use the [`date` command][date], with the `%s`
   format (i.e. `date +%s`, which outputs "seconds since 1970-01-01 00:00:00
   UTC"). You can recreate this output by running this command on basically any
   linux system in the world:
   >
   > ```
   > $ echo 'web_service value='`echo $RANDOM`' '`date +%s`
   > web_service value=7835 1531372345
   > ```
   >
   > In the real world you probably won't and/or shouldn't be sending metrics
   from a bash script, but in case you ever do, **it will totally work**! It
   will just need to look something like this. :)  


1. **Modify the behavior of the pipeline with Event Filters**. In the real world
   you wouldn't expect to handle every single event in the same way. For
   example, you wouldn't expect to get repeat notifications every 10 seconds
   letting you know a service is down.  

   Copy the following configuration to a file located at:
   `/etc/sensu/conf.d/filters/production_only.json`:

   ```
   {
     "filters": {
       "production_only": {
         "negate": false,
         "attributes": {
           "client": {
             "environment": "production"
           }
         }
       }
     }
   }
   ```

   Now we must configure our handler to use this filter. Update your handler
   configuration file as follows (adding the `"filters": ["production_only"]`
   line; and be sure to check that your file is valid JSON!):

   ```
   {
     "slack": {
       "webhook_url": "https://hooks.slack.com/services/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",
       "username": "Sensu",
       "icon_url": "http://www.gravatar.com/avatar/9b37917076cee4e2d331a785f3426640",
       "channel": "#demo",
       "timeout": 10,
       "filters": ["production_only"]
     }
   }
   ```

   Reload or restart the Sensu server to pick up the updated configuration:

   ```
   $ sudo systemctl reload sensu-enterprise
   ```

   Now let's publish those same events we published at the beginning of our
   tutorial (for `"web-server-01"` and `"web-server-02"`). Notice that these are
   identical events, but only one of them will get handled/processed (i.e. only
   one of them will result in a Slack notification):

   ```
   $ curl -s -XPOST -H 'Content-Type: application/json' \
   -d '{"source": "web-server-01", "name": "web_service", "output": "error!", "refresh": 1, "status": 1, "handlers": ["slack"]}' \
   http://127.0.0.1:4567/results
   $ curl -s -XPOST -H 'Content-Type: application/json' \
   -d '{"source": "web-server-02", "name": "web_service", "output": "error!", "refresh": 1, "status": 1, "handlers": ["slack"]}' \
   http://127.0.0.1:4567/results
   ```

   Did you notice? You should have received a Slack notification for
   `"web-server-02"`, but not for `"web-server-01"`. This means our filter
   worked! From now on, you'll only receive Slack notifications for events
   coming from the production environment.

   > PROTIP: The coolest thing about this is that this `"environment"` attribute
   isn't part of the Sensu event specification &ndash; in other words it's not a
   built-in attribute that Sensu expects; it's just a custom JSON
   attribute &ndsah; so we can leverage any number of custom attributes in
   filters.  

   Now let's update `"server-01"` with the `"environment": "production"`
   attribute using a discovery event, so that we can get alerts from this client
   again:

   ```
   $ curl -s -XPOST -H 'Content-Type: application/json' \
   -d '{"name": "web-server-01", "address": "10.0.2.101", "subscriptions": ["demo"], "environment": "production"}' \
   http://127.0.0.1:4567/clients
   ```

   Now when we publish events for `"web-server-01"` we should get notified in
   Slack:

   ```
   $ curl -s -XPOST -H 'Content-Type: application/json' \
   -d '{"source": "web-server-01", "name": "web_service", "output": "error!", "refresh": 1, "status": 1, "handlers": ["slack"]}' \
   http://127.0.0.1:4567/results
   ```

   Success!

Congratulations! You have completed our simple Monitoring Event Pipeline
tutorial. So far we've just covered the basics: events, filters, and handlers.
To learn more &ndash; including primitives like mutators and aggregates &ndash;
please visit the Sensu reference documentation.

Now let's continue to learn about how we can automate many of the steps we
worked through in our tutorial by using the Sensu Agent.

#### Introducing the Sensu agent (`sensu-client`)

The Sensu agent is an automated event producer. It takes care for things like
automated discovery, scheduling monitoring check executions, and converting
outputs of popular monitoring tools into events. It also provides a local
endpoint for routing events back to the event pipeline.

1. **Install and configure your first Sensu agent**. Let's install the open
   source Sensu agent:

   ```
   $ sudo yum install -y sensu
   ```

   Let's configure our client by copying the following configuration to a file
   located at `/etc/sensu/conf.d/client.json`:

   ```
   {
     "client": {
       "name": "web-server-01",
       "environment": "production",
       "socket": {
         "bind": "0.0.0.0",
         "port": 3030
       },
       "subscriptions": [
         "demo",
         "webserver"
       ]
     },
     "transport": {
       "name": "redis",
       "reconnect_on_error": true
     },
     "redis": {
       "host": "127.0.0.1",
       "port": 6379
     }
   }
   ```

   Now we just need to start the agent:

   ```
   $ sudo systemctl start sensu-client
   ```

   Notice that the Sensu client is now sending discovery events for us! Now if
   we want to update metadata about our hosts, we can manage it with a
   configuration file instead of sending data to the HTTP API.

5. Publishing events to the agent socket. Let's send that same/original event
   payload from step 1 to our pipeline using the Sensu agent socket:

   ```
   $ echo '{"source": "web-server-01", "name": "web_service", "output": "error!", "refresh": 1, "status": 1}' | nc localhost 3030
   ```

   ...now let's remove the `"source"` attribute and see what happens. The Sensu
   agent automatically decorates our events with its local metadata.

   ```
   $ echo '{"name": "web_service", "output": "hello world!", "refresh": 0, "status": 1}' | nc localhost 3030
   ```

   Using the Sensu agent means your applications don't need to know where they
   are running - they can just publish events to a local socket!

6. Configuring our first automated event producer. Let's install a service and
   a plugin to monitor this service, and have Sensu monitor it on a 10 second interval.

   ```
   $ sudo yum install -y nginx nagios-plugins-all
   ```

   Let's start Nginx and make sure it is up and running.

   ```
   $ sudo systemctl start nginx
   $ curl -I http://localhost:80
   ```

   Now let's use the Nagios check_http plugin to check our local web service:

   ```
   $ /usr/lib64/nagios/plugins/check_http -H localhost -N
   ```

   At this point, if we really wanted to, we could write a little wrapper to
   run this check as a cron job, and send the result to Sensu. It could look
   something like this:

   ```
   $ curl -s -XPOST -H 'Content-Type: application/json' \
   -d '{"source": "web-server-01", "name": "web_service", "output": "'`/usr/lib64/nagios/plugins/check_http -H localhost -N`", "refresh": 1, "status": 0, "handlers": ["slack"]}' \
   http://127.0.0.1:4567/results
   ```

   But then we'd have to solve for updating the status... techincally, this
   would do the trick:

   ```
   $ curl -s -XPOST -H 'Content-Type: application/json' \
   -d '{"source": "web-server-01", "name": "web_service", "output": "'`/usr/lib64/nagios/plugins/check_http -H localhost -N`'", "refresh": 1, "status": '`echo $?`', "handlers": ["slack"]}' \
   http://127.0.0.1:4567/results
   ```

   Now let's use Sensu to schedule this check to run every ten seconds. We'll
   use the Sensu server and agent together to solve this problem. Copy the
   following configuration to a file located at
   `/etc/sensu/conf.d/checks/check_http.json`:

   ```
   {
     "checks": {
       "web_service": {
         "command": "/usr/lib64/nagios/plugins/check_http -H localhost -N",
         "interval": 10,
         "subscribers": ["webserver"],
         "type": "metric",
         "handlers": ["slack","influxdb"],
         "output_format": "nagios_perfdata"
       }
     }
   }
   ```

   Now let's reload our configuration and let Sensu do the rest:

   ```
   $ sudo systemctl reload sensu-enterprise
   ```


[incoming-webhook]: https://slack.com/apps/A0F7XDUAZ-incoming-webhooks
[puppet]: https://puppet.com
[chef]: https://chef.io
[ansible]: https://ansible.com  
[results-api]: https://docs.sensu.io/sensu-core/latest/api/results/
[clients-api]: https://docs.sensu.io/sensu-core/latest/api/clients/
[influx-line-protocol]: https://docs.influxdata.com/influxdb/v1.6/write_protocols/line_protocol_tutorial/
[random]: http://tldp.org/LDP/abs/html/randomvar.html
[date]: http://man7.org/linux/man-pages/man1/date.1.html
