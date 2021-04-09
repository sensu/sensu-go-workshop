# Sensu Go Workshop

- [Overview](#overview)
- [Setup](#setup)
- [Lessons](#lessons)
  - [Operator Workshop](#operator-workshop)
  - [Developer Workshop](#developer-workshop)
- [Next Steps](#next-steps)
  - [Join the Sensu Community](#join-the-sensu-community)
  - [Contribute Sensu Community Projects on GitHub](#contribute-to-sensu-community-projects-on-github)

## Overview

This project is intended to provide a simple template for developing training modules for Sensu Go.
The workshop lessons included with this project are designed to help new Sensu users learn the basic concepts of an [Observability Pipeline](#) and help them get started with Sensu Go.

This project has also be designed with both self-guided learning _and_ instructor-led training workshops in mind.
It's easy to deploy the workshop environment on a laptop for personal use, or to a shared server (or cloud provider) for multiple users.
See [SETUP.md](/SETUP.md#readme) for more information on setting up the workshop environment.

## Setup

This workshop is designed to be simple enough for self-guided training, while also providing a tool for trainers to host a workshop for multiple attendees.
See [SETUP.md](/SETUP.md#readme) for more details on setting up the workshop environment.

Once you have deployed a workshop environment, you may proceed with the following local workstation setup instructions which will help you install the Sensu Go CLI (`sensuctl`) and connect to your workshop environment.

## Lessons

### Operator Workshop

- [Lesson 01: Introduction to Monitoring as Code](/lessons/operator/01/README.md#readme)
- [Lesson 02: Introduction to the Observability Data Model](/lessons/operator/02/README.md#readme)
- [Lesson 03: Introduction to Sensu Go](/lessons/operator/03/README.md#readme)
- [Lesson 04: Introduction to Handlers & Handler Sets](/lessons/operator/04/README.md#readme)
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

We hope you enjoyed this workshop and found it helpful for learning more about Sensu Go!
At this point we have covered Sensu's most common concepts, which should give you a much better sense for how Sensu works – but we've only really just scratched the surface.
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

[0-2]: https://docs.sensu.io/sensu-go/latest/operations/deploy-sensu/install-sensu/#install-sensuctl
[0-3]: https://docs.sensu.io/sensu-go/latest/
[0-4]: https://docs.sensu.io/sensu-go/latest/reference/apikeys/

[1-1]: https://docs.sensu.io/sensu-go/latest/reference/handlers/
[1-2]: https://docs.sensu.io/sensu-go/latest/api/events/
[1-3]: https://docs.sensu.io/sensu-go/latest/reference/entities/
[1-4]: https://https://docs.sensu.io/sensu-go/latest/api/entities/
[1-5]: https://docs.sensu.io/sensu-go/latest/reference/filters/

[2-1]: https://docs.sensu.io/sensu-go/latest/reference/agent/
[2-2]: https://docs.sensu.io/sensu-go/latest/reference/agent/#create-monitoring-events-using-the-agent-api
[2-3]: https://docs.sensu.io/sensu-go/latest/reference/checks/
[2-4]: https://docs.sensu.io/sensu-go/latest/reference/events/
[2-5]: https://en.wikipedia.org/wiki/Standard_streams

