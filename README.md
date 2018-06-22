# Monitoring Event Pipeline Demo

## Overview

- Configure one or more handlers
- Publish some events
  - First publish an event that does not get processed (no `"handler"` attribute)
  - Then publish the same event with a `"handlers"` attribute
  - Then modify the event `"source"` attribute
  - Then publish a discovery event
  - Then publish some telemetry events
- Configure a filter
  - Publish some events, demonstrating filtering capabilities
  - Send a discovery event to update sever-01 metadata
  - Send some more events from server-01
- Done

## Demo

1. **Configure one or more handlers**.

   Copy the following configuration to a file located at
   `/etc/sensu/conf.d/handlers/slack.json`:

   ```
   {
     "slack": {
       "webhook_url": "https://hooks.slack.com/services/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",
       "username": "Sensu",
       "icon_url": "http://www.gravatar.com/avatar/9b37917076cee4e2d331a785f3426640",
       "channel": "#demo",
       "timeout": 10
     }
   }
   ```

   Let's create a second handler for sending telemetry data to InfluxDB. Copy
   the following configuration to a file located at
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

   Restart the Sensu server.

2. **Publish some events to the pipeline**.

   Let's publish an event to the pipeline, via the Sensu Results API.

   ```
   $ curl -s -XPOST -H 'Content-Type: application/json' \
   -d '{"source": "web-server-01", "name": "web_service", "output": "error!", "refresh": 1, "status": 1}' \
   http://127.0.0.1:4567/results
   ```

   Notice, nothing happened when we published our event, because we didn't
   indicate how we wanted the event to be handled.

   Now let's add the `"handlers"` attribute and provide one or more handlers to
   tell our pipeline how to process our event:

   ```
   $ curl -s -XPOST -H 'Content-Type: application/json' \
   -d '{"source": "web-server-01", "name": "web_service", "output": "error!", "refresh": 1, "status": 1, "handlers": ["slack"]}' \
   http://127.0.0.1:4567/results
   ```

   Voila! A Slack notification!

   Now let's see what other behaviors we can modify. Let's send another event
   that is associated with a different host using the `"source"` attribute.

   ```
   $ curl -s -XPOST -H 'Content-Type: application/json' \
   -d '{"source": "web-server-02", "name": "web_service", "output": "error!", "refresh": 1, "status": 1, "handlers": ["slack"]}' \
   http://127.0.0.1:4567/results
   ```

   Notice that Sensu has created another "client" and associated our event with
   this agent. However, Sensu doesn't know anything about our hosts other than
   the name we've provided. Let's provide some "client" (host) metadata using
   the Clients API. This is effectively a "discovery event" (everything is an
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

   Now let's send some events to indicate that both of our services have
   restored and are now healthy, before we move on.

   ```
   $ curl -s -XPOST -H 'Content-Type: application/json' \
   -d '{"source": "web-server-01", "name": "web_service", "output": "ok!", "refresh": 1, "status": 0, "handlers": ["slack"]}' \
   http://127.0.0.1:4567/results
   ```

   ```
   $ curl -s -XPOST -H 'Content-Type: application/json' \
   -d '{"source": "web-server-02", "name": "web_service", "output": "ok!", "refresh": 1, "status": 0, "handlers": ["slack"]}' \
   http://127.0.0.1:4567/results
   ```

   Now let's send some metric data using the InfluxDB Data Format:

   ```
   $ curl -s -XPOST -H 'Content-Type: application/json' \
   -d '{"source": "web-server-02", "name": "web_service_response", "output": "web_service value='`echo $RANDOM`' '`date +%s`'", "refresh": 1, "status": 0, "type": "metric", "output_format": "influxdb_line", "handlers": ["influxdb"]}' \
   http://127.0.0.1:4567/results
   ```

   Let's see what happens if we send data in the wrong format (e.g. Nagios
   PerfData).

   ```
   $ curl -s -XPOST -H 'Content-Type: application/json' \
   -d '{"source": "web-server-02", "name": "web_service_response", "output": "web_service value='`echo $RANDOM`' '`date +%s`'", "refresh": 1, "status": 0, "handlers": ["influxdb"]}' \
   http://127.0.0.1:4567/results
   ```

3. **Modify the behavior of the pipeline with Event Filters**. Copy the
   following configuration to a file located at: `/etc/sensu/conf.d/filters/production_only.json`:

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

   Now we must tell our handler to use this filter. Update your handler
   configuration file as follows:

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

   ...publish some events...

   ```
   $ curl -s -XPOST -H 'Content-Type: application/json' \
   -d '{"source": "web-server-01", "name": "web_service", "output": "error!", "refresh": 1, "status": 1, "handlers": ["slack"]}' \
   http://127.0.0.1:4567/results
   ```

   ...no slack notification because the event was filtered!

   ```
   $ curl -s -XPOST -H 'Content-Type: application/json' \
   -d '{"source": "web-server-02", "name": "web_service", "output": "error!", "refresh": 1, "status": 1, "handlers": ["slack"]}' \
   http://127.0.0.1:4567/results
   ```

   Voila! A slack notification!

   Now let's update "server-01" with the `"environment": "production"` attribute
   and again get alerts for this host:

   ```
   $ curl -s -XPOST -H 'Content-Type: application/json' \
   -d '{"name": "web-server-01", "address": "10.0.2.101", "subscriptions": ["demo"], "environment": "production"}' \
   http://127.0.0.1:4567/clients
   ```

   ```
   $ curl -s -XPOST -H 'Content-Type: application/json' \
   -d '{"source": "web-server-01", "name": "web_service", "output": "error!", "refresh": 1, "status": 1, "handlers": ["slack"]}' \
   http://127.0.0.1:4567/results
   ```

4. Introduce the Sensu agent. The Sensu agent (`sensu-client`) is an automated
   event producer; it takes care for things like automated discovery, scheduling
   monitoring check executions, and converting outputs of popular monitoring
   tools into events. It also provides a local endpoint for routing events back
   to the event pipeline.

   Let's install the open source Sensu agent:

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

   Let's start the Sensu client...

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
   -d '{"name": "web_service", "output": "'`/usr/lib64/nagios/plugins/check_http -H localhost -N`'", "refresh": 1, "status": '`echo $?`', "handlers": ["slack"]}' \
   http://127.0.0.1:4567/results
   ```   

   Now let's use Sensu to schedule this check to run every ten seconds, and

   ```
   $ curl -s -XPOST -H 'Content-Type: application/json' \
   -d '{"source": "web-server-01", "name": "web_service", "output": "'`/usr/lib64/nagios/plugins/check_http -H localhost -N`'", "refresh": 1, "status": '`echo $?`', "handlers": ["slack"]}' \
   http://127.0.0.1:4567/results
   ```

   Let's use the Sensu server and agent together to solve this problem. Copy the
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
