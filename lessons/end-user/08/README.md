# Lesson 8: Introduction to Checks 

- [Overview](#overview)
- [Scheduling](#scheduling)
- [Subscriptions](#subscriptions)
- [Metrics collection](#metrics-collection)
  - [Output Metric Extraction](#output-metric-extraction)
  - [Output Metric Handlers](#output-metric-handlers)
  - [Output Metric Tags](#output-metric-tags)
- [Check templates](#check-templates)
- [Advanced Topics](#advanced-topics)
  - [TTLs (Dead Man Switches)](#ttls-dead-man-switches)
  - [Proxy requests (pollers)](#proxy-requests-pollers)
  - [Execution environment & environment variables](#execution-environment--environment-variables)
- [EXERCISE: configure a check](#exercise-configure-a-check)
- [EXERCISE: modify a check configuration using tokens](#exercise-modify-a-check-using-tokens)
- [Learn more](#learn-more)


## Overview 

==TODO: service checks are "monitoring jobs". 
Popularized by Nagios...
Simple specification...
Extensibility (any programming language in the world)...==

## Scheduling 

## Subscriptions 

## Metrics collection 

### Output Metric Extraction 

### Output Metric Handlers 

==TODO: explain how metrics are processed in the pipeline (i.e. metrics not persisted to Sensu data store)==

### Output Metric Tags 

==TODO: enrich PerfData metrics with `output_metric_tags` and check tokens!==

## Check Templates

==TODO: templating "monitoring jobs" with tokens...== 

## Advanced Topics 

### TTLs (Dead Man Switches)

### Proxy Requests (Pollers)

==TODO: reference lesson 12...== 

### Execution environment & environment variables 

## EXERCISE: configure a check 

## EXERCISE: modify check configuration using tokens 

==TODO: show alternative check configuration workflows (e.g. `sensuctl create -f`, `sensuctl edit`, and the web app).==

## Learn more

