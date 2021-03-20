# Lesson 10: Introduction to Assets

- [Overview](#overview)
- [Why not containers?](#why-not-containers?)
- [How it works](#how-it-works)
- [Advanced topics](#advanced-topics)
  - [CLI command plugins](#cli-command-plugins)
  - [Plugin SDK](#plugin-sdk)
- [EXERCISE: register an asset](#exercise-register-an-asset)
- [EXERCISE: configure a custom asset](#exercise-configure-a-custom-asset)
- [EXERCISE: package a shell script as an asset](#exercise-package-a-shell-script-as-an-asset)
- [Learn more](#learn-more)

## Overview

==TODO: on-demand monitoring instrumentation.
We've already been using Assets so far in our training, but they were pre-configured.==

## Why not containers?

==TODO: because cross-platform (Windows);
lower-level implementation (PATH, LD_LIBRARY_PATH, etc) that doesn't require a pre-installed runtime (CRI).==

## How it works

==TODO: packaging, hosting, configuration (builds, url, sha512, filters);
Bonsai (the "Docker Hub" for Sensu Go).==

## Advanced topics

### CLI command plugins

### Plugin SDK

==TODO: awareness;
developer training (coming soon).==

## EXERCISE: register an asset

==TODO: `sensuctl asset add`, and `sensuctl create -f` (with downloaded asset yaml from Bonsai).==

## EXERCISE: configure a custom asset

## EXERCISE: package a shell script as an asset

1. Create a simple shell script.

   Create a file named `helloworld.sh` and make it executable:

   ```
   touch helloworld.sh
   chmod +x helloworld.sh
   ```

   Edit `helloworld.sh` with the following contents:

   ```sh
   #!/bin/sh
   echo "Hello, ${1:-workshop} world!"
   if [ $? -eq 0 ]; then
     exit 0
   else
     exit 2
   fi
   ```

   To test this script try executing it with and without an argument:

   ```shell
   sh helloworld.sh
   sh helloworld.sh Sensu
   ```

   The output should look like this:

   ```shell
   Hello, workshop world!
   Hello, Sensu world!
   ```

**NEXT:** if you have a working `helloworld.sh` script, you're ready to move on to the next exercise!

1. Package the shell script in a g-zip compressed tarball.

   ```
   mkdir -p helloworld-0.1/bin
   mv helloworld.sh helloworld-0.1/bin/
   tar -czf helloworld-0.1.tar.gz -C helloworld-0.1/ .
   export SENSU_ASSET_SHA512=$(sha512sum helloworld-0.1.tar.gz | cut -d' ' -f1)
   ```

   Verify the contents of the asset using the `tar --list` command:

   ```shell
   tar --list -f helloworld-0.1.tar.gz
   ```

   The output should look like this:

   ```shell
   ./
   ./bin/
   ./bin/helloworld.sh
   ```

**NEXT:** if you have successfully packaged your `helloworld.sh` script in a g-zip compressed tarball, then you're ready to move on to the next exercise!

1. Upload the asset to a private asset server (e.g. Artifactory).

   Visit the workshop Artifactory service (see http://127.0.0.1:8882 for self-guided users) and login with the default adminstrator credentials (username: `admin`, password: `password`).

   TODO: upload an asset to Artifactory.

1. Configure a Check + Asset template.

   Copy the following contents to a file called `helloworld.yaml`:

   ```yaml
   ---
   # Example check configuration
   type: CheckConfig
   api_version: core/v2
   metadata:
     name: helloworld
   spec:
     command: sh helloworld.sh {{ .system.os }}
     runtime_assets:
     - helloworld:0.1
     publish: true
     subscriptions:
     - linux
     interval: 30
     timeout: 10
     check_hooks: []

   ---
   # Custom asset definition
   type: Asset
   api_version: core/v2
   metadata:
     name: helloworld:0.1
   spec:
     builds:
     - url: "http://artifactory:8082/artifactory/sensu/helloworld-0.1.tar.gz"
       sha512: "${SENSU_ASSET_SHA512}"
       headers:
       - "Authorization: Bearer ${ARTIFACTORY_TOKEN}"
       filters:
       - "entity.system.os == 'linux'"
   ```

**NEXT:** if you have created a configuration `helloworld.yaml` template, then you're ready to move on to the next step.

1. Create the Check and Asset resources using `sensuctl create -f`.

   ```shell
   sensuctl create -f helloworld.yaml
   ```

   Verify that your check and asset resource were created using `senscutl` or the Sensu web app.

   ```
   sensuctl check info helloworld --format yaml
   sensuctl asset info helloworld:0.1 --format yaml
   ```

## Learn more

## Next steps

[Lesson 11: Introduction to Mutators](../11/README.md#readme)



