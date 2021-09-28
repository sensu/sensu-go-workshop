# Sensu Go Workshop

- [Overview](#overview)
- [Lessons](#lessons)
  - [Operator Workshop](#operator-workshop)
  - [Developer Workshop](#developer-workshop)
- [Next Steps](#next-steps)
  - [Join the Sensu Community](#join-the-sensu-community)
  - [Contribute Sensu Community Projects on GitHub](#contribute-to-sensu-community-projects-on-github)

## Overview

The Sensu Go Workshop is a collection of learning resources designed to help new users learn Sensu.
The project includes the following resources:

1. Interactive lessons designed for self-guided learning
2. Detailed instructions for Mac, Windows, and Linux workstations
3. A local sandbox environment for use with the workshop (via Docker Compose or Vagrant)

Additional workshop materials are also available for advanced use cases, including instructor-led workshops (with multi-tenant sandbox environment), and alternative sandbox environments based on popular Sensu reference architectures (e.g. Sensu w/ [InfluxDB][influxdb], [TimescaleDB][timescaledb], [Elasticsearch][elasticsearch], [Prometheus][prometheus], and more).

## Lessons

The Sensu Go Workshop aims to provide learning resources for every Sensu user, including:

- **Operators** and other end-users who rely on Sensu for infrastructure and application monitoring.
- **Developers** and other engineers who want to build integrations using Sensu APIs.

See below for the complete list of lesson plans.

### Operator Workshop

- [Lesson 01: Introduction to Sensu](/lessons/operator/01/README.md#readme)
- [Lesson 02: Setup the Workshop Environment](/lessons/operator/02/README.md#readme)
- [Lesson 03: Using the Sensu CLI](/lessons/operator/03/README.md#readme)
- [Lesson 04: Introduction to Handlers](/lessons/operator/04/README.md#readme)
- [Lesson 05: Introduction to Events](/lessons/operator/05/README.md#readme)
- [Lesson 06: Introduction to Filters](/lessons/operator/06/README.md#readme)
- [Lesson 07: Introduction to Agents & Entities](/lessons/operator/07/README.md#readme)
- [Lesson 08: Introduction to Checks](/lessons/operator/08/README.md#readme)
- [Lesson 09: Introduction to Check Hooks](/lessons/operator/09/README.md#readme)
- [Lesson 10: Introduction to Assets](/lessons/operator/10/README.md#readme) (in progress)
- [Lesson 11: Introduction to Silencing & Scheduled Maintenance](/lessons/operator/11/README.md#readme) (coming soon)
- [Lesson 12: Introduction to Mutators](/lessons/operator/12/README.md#readme) (coming soon)
- [Lesson 13: Introduction to Proxy Entities & Proxy Checks](/lessons/operator/13/README.md#readme) (coming soon)
- [Lesson 14: Introduction to Namespaces & RBAC](/lessons/operator/14/README.md#readme) (coming soon)
- [Lesson 15: Introduction to Secrets Management](/lessons/operator/15/README.md#readme) (coming soon)
- [Lesson 16: Advanced Topics](/lessons/operator/16/README.md#readme) (coming soon)

### Developer Workshop

The Sensu Developer Workshop is coming soon!
When it arrives it will cover the following topics:

- **Sensu Data Model**
  - Endpoint specification (Entities)
  - Event data specification
  - Metrics specification
- **Sensu API overview**
- **Sensu API authentication**
- **Sensu configuration APIs (basic CRUD functions)**
  - Auth (Authentication API, APIKeys API)
  - RBAC (Roles API, RoleBindings API, ClusterRoles API, ClusterRoleBindings API, Users API)
  - Namespaces API
  - Assets API
  - Checks API
  - Filters API
  - Handlers API
  - Secrets API
  - Prune API
- **Sensu observability APIs**
  - Events API
  - Entities API
  - Silencing API
- **Sensu automation APIs**
  - Execute API
  - Entity PATCH API
- **Sensu Agent APIs**
  - Events HTTP API
  - Events TCP/UDP Socket
  - StatsD API
- **Sensu Plugins overview**
- **Sensu Plugins SDK**
- **Advanced Topics**

## Next Steps

We hope you enjoy this workshop and find it helpful for learning more about Sensu!
At this point we have covered Sensu's most common concepts, which should give you a much better sense for how Sensu works – but we've barely scratched the surface.
If you're interest in learning more, pleaes consider the following resources:

### Join the Sensu Community

The primary home of the Sensu Community is the [Sensu Community Forums](https://discourse.sensu.io/signup).
Sign up to get notified about upcoming events (e.g. webinars and virtual
meetups), and new releases.

https://discourse.sensu.io/signup

### Contribute to Sensu Community Projects on GitHub

The [Sensu GitHub org](https://github.com/sensu) is home to a number of open source projects that will help you get the most out of Sensu, including:

- [sensu/catalog (Sensu monitoring code templates)](https://github.com/sensu/catalog)
- [sensu/sensu-plugin-sdk](https://github.com/sensu/sensu-plugin-sdk)
- [sensu/check-plugin-template](https://github.com/sensu/check-plugin-template)
- Last but not least: [sensu/sensu-go](https://github.com/sensu/sensu-go) (_the_ Sensu Go OSS project)

<!-- Links -->
[influxdb]: docker-compose-influx.yaml
[timescaledb]: docker-compose-timescaledb.yaml
[elasticsearch]: docker-compose-elasticsearch.yaml
[prometheus]: docker-compose-prometheus.yaml
