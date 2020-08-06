# ROADMAP 

The following are planned improvements to the workshop: 

1. Investigate the Docker Compose `DOCKER_CONVERT_WINDOWS_PATHS` environment
   variable to see if this helps improve "cross-platform" support for the 
   workshop. 

1. Automate provisioning of one agent per namespace in instructor-led 
   workshops.

   ```
   $ sudo docker-compose run --no-deps -d --rm -e SENSU_NAMESPACE=lizy sensu-agent
   ```

1. Add alternate docker-compose templates: 

   - Sensu cluster w/ standalone/external etcd
   - Self-signed certificates (documentation and scripts)

1. Add a lesson on backup & restore. 

   - Document recommended `sensuctl dump` command(s) for backing up pipeline
     resources (i.e. assets, checks, filters, mutators, handlers, etc)
   - Include instructions for creating a "production" namespace and restoring 
     pipeline resources in the new namespace
   - Include instructions for instructor-led workshops, for reseting the 
     workshop environment and having trainees restore their configs

1. Investigate `volumes.:volume.external` to create a seamless transition
   from the landing page "quick start" to the workshop. 

   - See: https://docs.docker.com/compose/compose-file/#external 
   
1. Deprecate the Vagrant-based Sensu Go Sandbox in favor of the Sensu Go 
   Workshop. Or turn it into a wrapper for the workshop environment for users
   who can't install Docker on their workstations, but _can_ run a VM? could we
   refactor the workshop to basically just install Docker+Compose, clone the 
   workshop, run it (`docker-compose up -d`) and make sure all the necessary 
   ports are configured for external access (i.e. load the dashboard from  
   the host machine at http://localhost:3000)?  
   
   - See: https://docs.sensu.io/sensu-go/latest/learn/learn-sensu-sandbox/ 
   - See: https://github.com/sensu/sandbox 