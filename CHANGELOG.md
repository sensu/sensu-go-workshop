# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog][changelog] and this project adheres 
to [Semantic Versioning][semver].

## Unreleased

- Added this changelog & documented the original project goals, for posterity
- Replaced InfluxDB with TimescaleDB, a simpler reference architecture
- Add a docker-compose `.env` file for easy configuration 
- Exposed as much configuration in docker-compose.yaml as possible (as opposed 
  to volume mounting configuration files; e.g. agent.yaml)
- Moved setup instructions to a separate SETUP.md, since some workshops may be
  hosted by instructors and trainees won't have anything to setup (other than 
  installing the `sensuctl` CLI)
- Documented `--config-dir` oriented trainee setup; added default/example 
  `sensuctl` configs
- Added `sensuctl` wrapper script (needs documents); which can be used as a 
  workaround for [sensu/sensu-go#2316][2316]
- Outlined the observability pipeline workshop lessons 1-2 
- Added an issue tracker document (WIP)
- Next: 
  - Start developing the "Observability Pipeline" workshop
  - Add new Sensu templates (deprecate `/manifests` in favor of `/templates`)

## [0.1.0] - 2019-12-03

- Final commit of the initial iteration of this project
- This demo repo was largely unmaintained since February 2019 (with only a few 
  minor updates to keep pace with recent releases)
- This project was originally created to show how to quickly setup a local 
  Sensu Go environment using Docker Compose. It includes an Asset server and 
  telemetry pipeline for a more complete development workflow.

  _NOTE: Since the time this project was started (during the beta and initial 
  GA releases of Sensu Go) the [Sensu website][homepage] has been updated with 
  a simpler "quick start" guide, which is a better place to get started for 
  most users._
  

[changelog]: http://keepachangelog.com/en/1.0.0/
[semver]: http://semver.org/spec/v2.0.0.html
[homepage]: https://sensu.io/#getting-started 
[2316]: https://github.com/sensu/sensu-go/issues/2316 
