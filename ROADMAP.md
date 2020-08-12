# ROADMAP 

The following are planned improvements to the workshop: 

1. Add instructions for changing your password. 

   ```shell
   $ sensuctl user change-password --interactive
   ```

1. Add instructions for backing up workshop data and migrating to a local 
   environment.
   
   Create a backup folder. 

   ```shell
   $ mkdir backup
   ```
   
   Backup pipeline resources only (stripping namespaces for portability/reuse)... 
   
   ```shell
   $ sensuctl dump assets,checks,hooks,filters,mutators,handlers,silenced,secrets/v1.Secret \
     --format yaml | grep -v "^\s*namespace:" > backup/pipelines.yaml
   ```
   
   Make a namespaced backup of the entire cluster (sans entities, events, apikeys)...
   
   ```shell 
   $ sensuctl dump all \
     --omit entities,events,apikeys \
     --format yaml > backup/config.yaml
   ```
   
   Backup RBAC resources only... 
   
   ```shell
   $ sensuctl dump apikeys,users,roles,rolebindings,clusterroles,clusterrolebindings
     --format yaml > backup/system-rbac.yaml
   ```
   
   Optionally backup entity resources? 
     
   ```shell
   $ sensuctl dump entities \
     --format yaml | grep -v "^\s*namespace:" > backup/inventory.yaml
   ```
   
   Restore everything, or a subset of things: 
   
   ```shell
   $ sensuctl create -r -f backup/
   $ sensuctl create -f backup/pipelines.yaml
   ```

1. Investigate the Docker Compose `DOCKER_CONVERT_WINDOWS_PATHS` environment
   variable to see if this helps improve "cross-platform" support for the 
   workshop. 

1. Automate provisioning of one agent per namespace in instructor-led 
   workshops.

   ```shell
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