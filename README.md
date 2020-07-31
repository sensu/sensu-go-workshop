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
   ```
   
2. Configure `sensuctl`. 

   This workshop includes multiple configuration examples: 
   
   a. `.sensu/default/` should be used for self-guided workshops
   b. `.sensu/example/` should be modifed and used in instructor-led workshops

   Edit the contents of `.sensu/default/cluster` and `.sensu/default/profile` 
   as needed (e.g. you may need to edit the `"api-url"` field of the 
   `.sensu/default/cluster` file to point at a remote Sensu cluster). 
   
   _NOTE: if you're participating in an instructor-led workshop, please copy 
   the example configs (e.g. `cp -r .sensu/example .sensu/workshop`) and 
   modify them as needed._

   Run the following command with the corresponding `--config-dir` (either 
   `.sensu/default/`, or `.sensu/workshop`) to configure the Sensu CLI: 
   
   ```
   $ sensuctl configure --config-dir .sensu/default/ 
   ```

   Sensuctl will prompt you to provide a Sensu Backend URL, username, password,
   namespace, and preferred output format. The backend URL, namespace, and 
   output format fields will be pre-populated with defaults based on the 
   contents of `.sensu/default/cluster` and `.sensu/default/profile` (or 
   `.sensu/workshop/cluster` and `.sensu/workshop/profile` for instructor-led
   workshops). 
   
   ```
   $ sensuctl configure --config-dir .sensu/default/
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

   _NOTE: the default username and password for this workshop environment are 
   username: `sensu` and password: `sensu`. Trainees in instructor-led 
   workshops may need to login with individual credentials provided by the 
   instructor._
   
3. Create an API Key. 

   ```
   $ sensuctl api-key grant sensu
   Created: /api/core/v2/apikeys/1390f2cf-e31b-450e-b38c-e3fc09b52d07
   ```
   
   _NOTE: self-guided users should create an api-key for the `sensu` user (the 
   default user for this workshop). Trainees in instructor-led workshops may 
   need to login with individual credentials provided by the instructor._ 
   

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





[0]:  #observability-pipeline 
[1]:  /docs/SETUP.md
[2]:  #
[3]:  #
[4]:  #
[5]:  #
[6]:  #
[7]:  #
[8]:  #
[9]:  #
[10]: #
[11]: #
