# ROADMAP 

The following are planned improvements to the workshop: 

1. Investigate the Docker Compose `DOCKER_CONVERT_WINDOWS_PATHS` environment
   variable to see if this helps improve "cross-platform" support for the 
   workshop. 

1. Automate provisioning of one agent per namespace in instructor-led 
   workshops.

   ```
   $ sudo docker-compose run -d --rm -e SENSU_NAMESPACE=lizy sensu-agent
   ```

1. Add alternate docker-compose templates: 

   - Sensu cluster w/ standalone/external etcd
   - Self-signed certificates (documentation and scripts)

1. Add a lesson on backup & restore

   - Document recommended `sensuctl dump` command(s) for backing up pipeline
     resources (i.e. assets, checks, filters, mutators, handlers, etc)
   - Include instructions for creating a "production" namespace and restoring 
     pipeline resources in the new namespace
   - Include instructions for instructor-led workshops, for reseting the 
     workshop environment and having trainees restore their configs
