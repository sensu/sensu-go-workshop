# Sensu Go Workshop

- [Overview](#overview)
  - [What is Sensu?](#what-is-sensu)
  - [Observability Pipeline](#observability-pipeline)
- [Workshop](#workshop)
  - [Setup](#setup)
  - [Lesson 1: Introduction to Sensu Go](#lesson-1-introduction-to-sensu-go)
  - [Lesson 2: Introduction to `sensu-agent`](#lesson-2-introduction-to-sensu-agent)

## Overview 

This project is intended to provide a simple template for developing training 
modules for Sensu Go. The workshop lessons outlined below are effectively the 
introductory modules – they are designed to help new Sensu users learn the 
basic concepts of an [Observability Pipeline][0] and help them get started 
with Sensu Go. 

This project has also be designed with both self-guided learning _and_ 
instructor-led training workshops in mind. It's easy to deploy the workshop 
environment on a laptop for personal use, or to a shared server (or cloud 
provider) for multiple users. See [SETUP.md][1] for more information on 
setting up the workshop environment. 

### What is Sensu?

==COMING SOON==

### Observability Pipeline 

==COMING SOON==

## Workshop

### Setup

This workshop is designed to be simple enough for self-guided training, while 
also providing a tool for trainers to host a workshop for multiple attendees. 
See [SETUP.md][1] for more details on setting up the workshop environment. 

Once you have deployed a workshop environment, you may proceed with the 
following local workstation setup instructions which will help you install 
the Sensu Go CLI (`sensuctl`) and connect to your workshop environment.

1. Clone this repository & configure your local environment.  

   ```
   $ git clone git@github.com:calebhailey/sensu-go-workshop.git 
   $ cd sensu-go-workshop/ 
   $ export $(cat .env | grep -v "#" | grep =)
   ```
   
2. Install and configure a local `sensuctl` (the Sensu Go CLI).

   Mac users:

   ```
   $ curl -LO https://s3-us-west-2.amazonaws.com/sensu.io/sensu-go/${SENSU_CLI_VERSION}/sensu-go_${SENSU_CLI_VERSION}_darwin_amd64.tar.gz
   $ sudo tar -xzf sensu-go_${SENSU_CLI_VERSION}_darwin_amd64.tar.gz -C /usr/local/bin/
   ```

   > NOTE: Linux and Windows users can find [installation instructions][2] in the 
     Sensu [user documentation][3]. The complete list of Sensu downloads is 
     available at https://sensu.io/downloads

   Configure the Sensu CLI to connect to your backend:
   
   ```
   $ sensuctl configure
   ```

   Sensuctl will prompt you to provide a Sensu Backend URL, username, password,
   namespace, and preferred output format. 
   
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
     workstation should use the default backend URL (`http://127.0.0.1:8080`), 
     username (`sensu`), and password (`sensu`). Trainees in instructor-led 
     workshops should use the URL and credentials provided by the instructor._
   
3. Create an API Key. 

   To create an API Key, use the `sensuctl api-key grant` command: 
   
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
     as shown above. Trainees in instructor-led workshops should create an 
     api-key for their own user, using the username provided by the instructor 
     (e.g. `sensuctl api-key grant <username>`)._ 
   
### Lesson 1: introduction to Sensu Go

1. Configure a handler to process observability data

   ==COMING SOON==

2. Publish an event to the pipeline 

   ==COMING SOON==

3. Enrich observations with additional context, and modify pipeline behaviors

   ==COMING SOON==

4. Discovery & inventory 

   ==COMING SOON==

5. Create & resolve incidents  

   ==COMING SOON==
   
6. Collect & process metrics 

   ==COMING SOON==
   
7. Pipeline filtering 

   ==COMING SOON==

### Lesson 2: introduction to `sensu-agent`

1. Install and configure your first agent 

   ==COMING SOON==
   
2. Publish events to the pipeline via the Agent API 

   ==COMING SOON==
   
3. Configure your first check/monitor (automated event collection)

   ==COMING SOON==

4. Output Metric Extraction 

   ==COMING SOON==

5. Agent StatsD Socket 

   ==COMING SOON==



[0]:  #observability-pipeline 
[1]:  /docs/SETUP.md
[2]:  https://docs.sensu.io/sensu-go/latest/operations/deploy-sensu/install-sensu/#install-sensuctl
[3]:  https://docs.sensu.io/sensu-go/latest/
[4]:  #
[5]:  #
[6]:  #
[7]:  #
[8]:  #
[9]:  #
[10]: #
[11]: #
