# Lesson 12: Introduction to Assets

- [Goals](#goals)
- [What is a Sensu Asset?](#what-is-a-sensu-asset)
  - [Cross-Platform Packaging Solution](#cross-platform-packaging-solution)
  - [Assets are optional](#assets-are-optional)
  - [EXERCISE 1: Register an Asset](#exercise-1-register-an-asset)
- [How are Sensu Assets Distributed?](#how-are-sensu-assets-distributed)
  - [Bonsai: The Sensu Asset Index](#bonsai-the-sensu-asset-index)
  - [HTTP + GNU Tarballs + SHA512 Verification](##http--gnu-tarballs--sha-verification)
  - [EXERCISE 2: Mirroring Assets](#exercise-2-mirroring-assets)
- [Packaging Custom Assets](#packaging-custom-assets)
  - [Sensu Asset Packaging Format](#sensu-asset-packaging-format)
  - [EXERCISE 3: Package a Custom Script as a Sensu Asset](#exercise-3-package-a-custom-script-as-a-sensu-asset)
- [Discussion](#discussion)
  - [Why Not OCI-compliant Containers](#why-not-oci-compliant-containers)
  - [Sensu Assets Support All Programming Languages](#sensu-assets-support-all-programming-languages)
  - [Sensu Asset Tooling and Resources](#sensu-asset-tooling-and-resources)
- [Learn More](#learn-more)
- [Next Steps](#next-steps)

## Goals

In this lesson we will learn about [Sensu Assets], a lightweight packaging and distribution solution for cloud native observability.
You learn how to register new assets, mirror assets for use in secured production environments, and package custom assets for use with Sensu Go.

## What is a Sensu Asset?

[Sensu Assets], or Dynamic Runtime Assets, are [plugins] for the Sensu monitoring platform.
Sensu provides built-in support for real-time distribution of Sensu Assets to agents, enabling on-demand observability.
In fact, you may have already noticed that this workshop environment is pre-configured with dozens of assets.
Take a look at the various YAML files you've already created during this workshop – many of them include references to `runtime_assets`.
To see a list of assets in this workshop environment, run the `sensuctl asset list` command.

### Cross-Platform Packaging Solution

Sensu Assets are a cross-platform packaging solution, with support for Linux, Windows, FreeBSD, Solaris, AIX, and MacOS.
This broad compatibility is possible thanks a simple design based on features that are common across all modern operating systems (e.g. `PATH` environment variables).

Sensu Asset resources contain information used to determine which is the correct "build" of an asset to download for a given system.
This multi-build asset system works in tandem with the Sensu agent's built-in platform discovery, which detects operating system platform and version info, as well as CPU architectures.
Sensu Assets provide a seamless solution for distribution of plugins that have been cross-compiled for multiple operating systems and architectures.

**Example multi-build Sensu Asset**

```yaml
type: Asset
api_version: core/v2
metadata:
  name: example
spec:
  builds:
  - url: https://artifactory.yourcompany.com/sensu/example-asset_0.1.0_linux_amd64.tar.gz
    filters:
    - entity.system.os == 'linux'
    - entity.system.arch == 'amd64'
    sha512: 1db73a874282a34941254780e1a6eb0e4341588defddfd1af994ffb37c15deb9205306e02a0527c616d5301f51e9d2f279d6066c3781b9823de6018d84aa8ace
  - url: https://artifactory.yourcompany.com/sensu/example-asset_0.1.0_windows_amd64.tar.gz
    sha512: 52ae075c14acac1b8dd3885ea14b810a27c7642ea73185c93a31c173346934aee650cc613774c2a2787b29d14d806020fcb3db1580d0e9d6ad6d91a0c90b4827
    filters:
    - entity.system.os == 'windows'
    - entity.system.arch == 'amd64'
  - url: https://artifactory.yourcompany.com/sensu/example-asset_0.1.0_darwin_amd64.tar.gz
    filters:
    - entity.system.os == 'darwin'
    - entity.system.arch == 'amd64'
    sha512: 72d0f155d12cbf3b834e8dde1c105de7c4571dbba43b90ab43fced8f5496311c30e6e55cb7a638a7eb505236a956fec1305f4318f0e011dd982d6eb9cb0432dd
```

### Assets Are Optional

Various Sensu components support execution of external programs.
For example, Sensu checks and pipe handlers execute `command`s (see [Lesson 4] and [Lesson 7] for more information about checks and handlers).
Sensu doesn't have any hard requirements about how these executable programs are installed.
Plugins can be installed by a traditional configuration management system, or via Sensu Assets.

Sensu Assets can also be used in tandem with alternate installation methods, making it easy to adopt Sensu Assets over time (i.e. there's no need for a wholesale migration to Sensu Assets).

### EXERCISE 1: Register an Asset

#### Scenario

Your team is preparing to launch a new infrastructure service.
An open source plugin is available for monitoring the service, and you need to deploy it to all of the hosts where the service will run.

#### Solution

We'll register a new Sensu Asset, and configure a check to use the asset.

#### Steps

1. **Configure a service health check to monitoring NGINX.**

   Copy and paste the following contents to a file named sensu-assets.yaml.
   This will enable HTTP endpoint monitoring of a simple Sensu asset server in the workshop environment.

   ```yaml
   ---
   type: CheckConfig
   api_version: core/v2
   metadata:
     name: service-health
   spec:
     command: http-check --url http://sensu-assets:80
     runtime_assets:
     - sensu/http-checks
     publish: true
     proxy_entity_name: sensu-assets
     subscriptions:
     - workshop
     interval: 30
     timeout: 10
     handlers:
     - mattermost
   ```

1. **Observe the service health check failure.**

   Check the Sensu event list to see the misconfigured check output.

   ```shell
   sensuctl event list
   ```

   You should see a `check-nginx` event reporting a "command not found" error with a message like `sh: http-check: not found`.

1. **Add the missing asset.**

   Use the `sensuctl asset add` command to add the missing asset.

   ```
   sensuctl asset add sensu/http-checks
   ```

   The output should look like the following:

   ```
   no version specified, using latest: 0.4.0
   fetching bonsai asset: sensu/http-checks:0.4.0
   added asset: sensu/http-checks:0.4.0

   You have successfully added the Sensu asset resource, but the asset will not get downloaded until
   it's invoked by another Sensu resource (ex. check). To add this runtime asset to the appropriate
   resource, populate the "runtime_assets" field with ["sensu/http-checks"].
   ```

   The `sensuctl asset add` command is a direct integration between `sensuctl` and Bonsai that automates the process of downloading and registering Sensu Asset definitions.
   Bonsai assets can also be registered by downloading Asset definitions and saving them as YAML files.

   To manually download and register a Bonsai asset, please note the following steps:

   - Visit an asset page in Bonsai (e.g. https://bonsai.sensu.io/assets/sensu/http-checks)
   - Navigate to the "Asset Definition" tab
   - Copy the YAML contents to a file (e.g. `asset.yaml`)
   - Use `sensuctl` to register the asset:

     ```
     sensuctl create -f asset.yaml
     ```

1. **Observe the service health check result.**

   Check the Sensu event list again to see the check result.

   ```
   sensuctl event list
   ```

   You should see a `check-nginx` event reporting a service status with a message like `http-check OK: HTTP Status 200 for http://sensu-assets:80`.

## How are Sensu Assets distributed?

Sensu backends and Sensu agents download assets via HTTP.
Sensu Assets are initially downloaded into a temp directory.
Once downloaded, Sensu performs a [checksum verification][checksums] to ensure the downloaded asset matches the provided [SHA512] value.
Once verified, Sensu extracts the asset into a local cache directory (configurable via `--cache-dir`).

### Bonsai: The Sensu Asset Index

[Bonsai] is a centralized hub for discovering and sharing Sensu assets, backed by a CDN for fast downloads from globally-distributed infrastructure.
Sensu assets are published to Bonsai via GitHub repositories that are configured with a `.bonsai.yml` file.
Please visit the Sensu documentation to learn more about [publishing assets to Bonsai][bonsai-publishing].

### HTTP + GNU Tarballs + SHA Verification

Bonsai is a fantastic resource for the [Sensu Community] to discover and share open source Sensu plugins, but Sensu users with security hardening requierments or operate air-gapped infrastructure will need to host their own Sensu assets.
Thanks to the simplicity of the Sensu Asset implementation – it's just HTTP + GNU Tarballs + SHA512 – hosting your own Sensu Assets is easy.

### EXERCISE 2: Mirroring Assets

#### Scenario

After a successful proof-of-value evaluation, you are ready to rollout Sensu in your production environment.
Your organization's security policy requires that all production software artifacts be hosted on-premises using an approved artifact repository like [Artifactory].

#### Solution

We will mirror a Sensu Asset downloaded from Bonsai and host it via a simple HTTP server ([NGINX]).

#### Steps

1. **Download a Sensu Asset**

   Download 64-bit Linux, Windows, and MacOS builds of the Sensu Go [check-disk-usage] asset into the `assets` directory.

   **MacOS or Linux:**

   ```
   cd assets
   curl -LO https://assets.bonsai.sensu.io/c06ba5a541026092d685e4d54b76c490801b9919/check-disk-usage_0.6.0_linux_amd64.tar.gz
   curl -LO https://assets.bonsai.sensu.io/c06ba5a541026092d685e4d54b76c490801b9919/check-disk-usage_0.6.0_windows_amd64.tar.gz
   curl -LO https://assets.bonsai.sensu.io/c06ba5a541026092d685e4d54b76c490801b9919/check-disk-usage_0.6.0_darwin_amd64.tar.gz
   ```

   **Windows (Powershell):**

   ```
   cd assets
   Invoke-WebRequest `
     -Uri "https://assets.bonsai.sensu.io/c06ba5a541026092d685e4d54b76c490801b9919/check-disk-usage_0.6.0_linux_amd64.tar.gz" `
     -OutFile "check-disk-usage_0.6.0_linux_amd64.tar.gz"
   Invoke-WebRequest `
     -Uri "https://assets.bonsai.sensu.io/c06ba5a541026092d685e4d54b76c490801b9919/check-disk-usage_0.6.0_windows_amd64.tar.gz" `
     -OutFile "check-disk-usage_0.6.0_windows_amd64.tar.gz"
   Invoke-WebRequest `
     -Uri "https://assets.bonsai.sensu.io/c06ba5a541026092d685e4d54b76c490801b9919/check-disk-usage_0.6.0_darwin_amd64.tar.gz" `
     -OutFile "check-disk-usage_0.6.0_darwin_amd64.tar.gz"
   ```

1. **Create a YAML File Containing the Asset Configuration.**

   Copy the following contents into a file called `check-disk-assets.yaml`.

   ```yaml
   ---
   type: Asset
   api_version: core/v2
   metadata:
     name: workshop/check-disk-usage:0.6.0
   spec:
     builds:
     - url: http://sensu-assets/assets/check-disk-usage_0.6.0_windows_amd64.tar.gz
       sha512: 0b1df35dc409f7dc8ea849c828036983a5759b6c6ed5940ff1a491b17eb60ca73349dfa9dada73acde0f653a8267c119853771f03b729fd4a95c81e817f9cedb
       filters:
       - entity.system.os == 'windows'
       - entity.system.arch == 'amd64'
     - url: http://sensu-assets/assets/check-disk-usage_0.6.0_darwin_amd64.tar.gz
       sha512: dcbe19998d1804c8708836c3ec0a7568442ed8f9b33d7d430dc4e1ef59e37f516648b3147344e79c6deb2ad095f588971e37de1f9f9ef1fac558eacc21c184c7
       filters:
       - entity.system.os == 'darwin'
       - entity.system.arch == 'amd64'
     - url: http://sensu-assets/assets/check-disk-usage_0.6.0_linux_amd64.tar.gz
       sha512: fa25e317ba8aa3e23d9e3d3c54081ca4529aeba2e7ee437a2bf1ed8cfb3fbf70cd0380eb8cc427a9be17515e437f6346949381cc7ce47f37493e32eb8372ded8
       filters:
       - entity.system.os == 'linux'
       - entity.system.arch == 'amd64'
   ```

   > **Understanding the YAML:**
   > - The `Asset.Spec.builds` field allows us to define multiple builds for a given asset - one per platform.
   > - Each asset build is configured with a `url`, `sha512`, and `filters`.
   > - When a Sensu backend or Sensu agent downloads an asset, it will evaluate the asset build filters and fetch the first build that matches.
   > - The `sensu-assets` hostname defined in this asset (i.e. `http://sensu-assets`) is resolvable inside of the Sensu workshop Docker network _only_; the agent you installed in [Lesson 7] may be able to resolve this hostname with additional configuation (e.g. by editing `/etc/hosts` or equivalent), but such DNS configuration is out of scope for this workshop.
   > - The workshop `assets` directory on your local workstation is volume mounted inside of the `sensu-assets` container, which is running NXINX to serve the assets locally over HTTP.

1. **Register the mirrored asset in Sensu.**

   Register the mirrored asset in Sensu using the `sensuctl create -f` command.

   ```shell
   sensuctl create -f check-disk-assets.yaml
   ```

   Verify that the asset was successfully created in Sensu using the `sensuctl asset info` command:

   ```shell
   sensuctl asset info workshop/check-disk-usage:0.6.0
   ```

## Packaging custom assets

### Sensu Asset Packaging Format

A Sensu Asset is a tarball containing a `bin/`, `lib/`, and `include/` directories.
When Sensu Assets are used by a Sensu backend or Sensu agent, the execution environment is temporarily modified as follows:

- `{PATH_TO_ASSET}/bin` is injected into the `PATH` environment variable
- `{PATH_TO_ASSET}/lib` is injected into the `LD_LIBRARY_PATH` environment variable (or equivalent)
- `{PATH_TO_ASSET}/include` is injected into the CPATH environment variable (or equivalent)

When Sensu modifies these environment variables, it gives the corresponding asset path the priority (e.g. `PATH=/path/to/asset/bin:$PATH`).

### EXERCISE 3: Package a Custom Script as a Sensu Asset

#### Scenario

You have developed a custom monitoring check script that you wish to deploy across your fleet using Sensu Assets.

#### Solution

You can package the script as a Sensu Asset using built-in tooling (`tar` and `shasum` or `Get-FileHash`) and register it with Sensu using `sensuctl`.

#### Steps

1. **Create subdirectories for your custom plugin.**

   **Mac and Linux:**

   ```
   mkdir -p plugin/sh/bin/
   mkdir -p plugin/ps/bin/
   ```

   **Windows (Powershell):**

   ```
   New-Item -Path . -Name plugin\sh\bin -ItemType "directory"
   New-Item -Path . -Name plugin\ps\bin -ItemType "directory"
   ```

1. **Create a custom `helloworld` script.**

   Copy the following shell script to a file named `plugin/sh/bin/helloworld`:

   ```shell
   #!/bin/sh
   if [ $# -eq 0 ]; then
     echo "Hello, computer world!"
     exit 1
   else
     echo "Hello, ${0} world!"
     exit 0
   fi
   ```

   Copy the following Powershell script to a file named `plugin/ps/bin/helloworld.ps1`:

   ```powershell
   # Powershell
   if ( $args.Count -eq 0 ) {
     echo "Hello, computer world!"
     exit 1
   } else {
     echo "Hello, $args world!"
     exit 0
   }
   ```

1. **Package the custom script.**

   Generate Sensu Asset tarballs, then verify the contents.

   **MacOS or Linux:**

   ```
   chmod +x plugin/sh/bin/helloworld
   tar -czf helloworld_shell_0.1.0.tar.gz -C plugin/sh/ .
   tar --list -f helloworld_shell_0.1.0.tar.gz
   tar -czf helloworld_powershell_0.1.0.tar.gz -C plugin/ps/ .
   tar --list -f helloworld_powershell_0.1.0.tar.gz
   mv helloworld_*.tar.gz assets/
   ```

   **Windows (Powershell):**

   ```
   ICACLS .\plugin\sh\bin\helloworld /grant:r "users:(RX)" /C
   tar -czf helloworld_shell_0.1.0.tar.gz -C plugin/sh/ .
   tar --list -f helloworld_shell_0.1.0.tar.gz
   tar -czf helloworld_powershell_0.1.0.tar.gz -C plugin/ps/ .
   tar --list -f helloworld_powershell_0.1.0.tar.gz
   mv helloworld_*.tar.gz .\assets\
   ```

   You should see output from the two `tar --list` commands indicating that the `helloworld` and `helloworld.ps1` scripts are in a `bin` subdirectory; it should look something like this:

   ```
   ./
   ./bin/
   ./bin/helloworld
   ```

   _NOTE: if the tarballs were created without the `bin` subdirectory, please delete the `.tar.gz` files and repeat this step from the beginning._

1. **Obtain the SHA512 digests for your custom assets.**

   **Mac or Linux:**

   ```
   shasum -a 512 assets/helloworld_*.tar.gz
   ```

   The output should look like this:

   ```
   b999482ec1c11b930d07545ea3c83d48b31c0d64a6576e41634f5c89abaa81dcca271fc6f3c359a31f0f67b1cb07ae6a07af173bc915ea9ba417adbccc57f170  assets/helloworld_powershell_0.1.0.tar.gz
   3c5675a3bdbad6f0a51adb2186001ef3073057ce665f7015ee9583260fe2ca056df120b2b91c3f60a0abbad7420c27f236eda9aca180a6d674e5bd37133f7cac  assets/helloworld_shell_0.1.0.tar.gz
   ```

   **Windows (Powershell):**

   ```
   Get-FileHash -Path .\assets\helloworld_*.tar.gz -Algorithm SHA512 | Format-List
   ```

   The output should like like this:

   ```
   Algorithm : SHA512
   Hash      : b999482ec1c11b930d07545ea3c83d48b31c0d64a6576e41634f5c89abaa81dcca271fc6f3c359a31f0f67b1cb07ae6a07af173bc915ea9ba417adbccc57f170
   Path      : C:\Users\calebhailey\workshop\assets\helloworld_powershell_0.1.0.tar.gz

   Algorithm : SHA512
   Hash      : 3c5675a3bdbad6f0a51adb2186001ef3073057ce665f7015ee9583260fe2ca056df120b2b91c3f60a0abbad7420c27f236eda9aca180a6d674e5bd37133f7cac
   Path      : C:\Users\calebhailey\workshop\assets\helloworld_shell_0.1.0.tar.gz
   ```

1. **Create a YAML File Containing the Asset + Example Check Configuration.**

   Copy the following contents to a file named `helloworld.yaml`:

   _NOTE: you will need to replace **all three** `sha512` values in this example with the digests from step 4 (above).
   Take care to use the correct value for the corresponding asset tarball (i.e. `helloworld_shell_0.1.0.tar.gz` and `helloworld_powershell_0.1.0.tar.gz`)._

   ```yaml
   ---
   type: CheckConfig
   api_version: core/v2
   metadata:
     name: helloworld
   spec:
     command: helloworld {{ .system.os | default "workshop" }}
     runtime_assets:
     - workshop/helloworld:0.1.0
     interval: 30
     timeout: 10
     publish: true
     subscriptions:
     - workshop
     - linux
     - windows
     - darwin
   ---
   type: Asset
   api_version: core/v2
   metadata:
     name: workshop/helloworld:0.1.0
   spec:
     builds:
     - url: http://sensu-assets/assets/helloworld_shell_0.1.0.tar.gz
       sha512: 3c5675a3bdbad6f0a51adb2186001ef3073057ce665f7015ee9583260fe2ca056df120b2b91c3f60a0abbad7420c27f236eda9aca180a6d674e5bd37133f7cac
       filters:
       - entity.system.os == 'linux'
     - url: http://sensu-assets/assets/helloworld_shell_0.1.0.tar.gz
       sha512: 3c5675a3bdbad6f0a51adb2186001ef3073057ce665f7015ee9583260fe2ca056df120b2b91c3f60a0abbad7420c27f236eda9aca180a6d674e5bd37133f7cac
       filters:
       - entity.system.os == 'darwin'
     - url: http://sensu-assets/assets/helloworld_powershell_0.1.0.tar.gz
       sha512: b999482ec1c11b930d07545ea3c83d48b31c0d64a6576e41634f5c89abaa81dcca271fc6f3c359a31f0f67b1cb07ae6a07af173bc915ea9ba417adbccc57f170
       filters:
       - entity.system.os == 'windows'
   ```

   > **Understanding the YAML:**
   > - This template contains two Sensu resources in a single file: a Sensu Asset, and a Sensu Check which references this asset.
   > - This template references the `helloworld_shell_0.1.0.tar.gz` asset build twice – once for Linux and once for Mac (`darwin`).
   > - The `sensu-assets` hostname defined in this asset (i.e. `http://sensu-assets`) is resolvable inside of the Sensu workshop Docker network _only_; the agent you installed in [Lesson 7] may be able to resolve this hostname with additional configuation (e.g. by editing `/etc/hosts` or equivalent), but such DNS configuration is out of scope for this workshop.

1. **Register the `helloworld` asset and an example check using the `sensuctl create -f` command**

   ```
   sensuctl create -f helloworld.yaml
   ```

   If you see one or more `helloworld` events in Sensu then you're ready to move on to the next lesson!


## Discussion

In this lesson

### Why Not OCI-compliant Containers?

Many Sensu users have inquired about the reasoning behing Sensu Assets as a packaging format in place of something like [OCI-compliant container images][oci images] (e.g. Docker images).
The short answer is that container images require a runtime to be installed, which is a heavy external dependency.
Furthermore, container support on non-Linux platforms is somewhat limited.
In contrast, Sensu Assets can be supported by any ["mostly POSIX-compliant" operating system][posix] with zero external dependencies.

### Sensu Assets Support All Programming Languages

Some Sensu users have asked if plugins have to be written in Ruby or Golang.
Sensu plugins can be written in any programming language, including Bash and Powershell.
Because the original Sensu open source software project was written in Ruby, the early Sensu Community contributions were mostly Ruby plugins.
There are over 200 open source [Sensu plugins] written in Ruby, all of which are compatible with Sensu Go.

Although it is possible to leverage Sensu Assets to package language runtimes (e.g. [the Ruby runtime]), this is a complex use case.
Conversely, statically compiled binaries are quite complementary to the Sensu Assets solution.
Programming languages like [Go] that provide comprehensive support for cross-compiling programs for multiple operating systems and system architectures are a great fit for Sensu Assets.

In case it's not already obvious: [we really love Go][gopher]!

![](img/gopher.png)

### Sensu Asset Tooling and Resources

Coming soon.

## Learn More

- [[Documentation] "Sensu Assets Reference" (docs.sensu.io)][sensu assets]
- [[Documentation] "Sensu Assets Specification" (docs.sensu.io)][asset spec]
- [[Documentation] "Sensu Plugins" (docs.sensu.io)][plugins]
- [[Asset Index] Bonsai (bonsai.sensu.io)][bonsai]

## Next Steps

[Share your feedback on Lesson 12](https://github.com/sensu/sensu-go-workshop/issues/new?template=lesson_feedback.md&labels=feedback%2Clesson-12&title=Lesson%2012%20Feedback)

[Lesson 13: Introduction to Sensu Entities][next lesson]

<!-- Workshop links -->
[Lesson 4]: /lessons/operator/04/README.md#readme
[lesson 7]: /lessons/operator/07/README.md#readme
[next lesson]: /lessons/operator/13/README.md#readme

<!-- Sensu links-->
[Sensu assets]: https://docs.sensu.io/sensu-go/latest/plugins/assets/
[asset spec]: https://docs.sensu.io/sensu-go/latest/plugins/assets/#dynamic-runtime-asset-format-specification
[plugins]: https://docs.sensu.io/sensu-go/latest/plugins/
[sensu plugins]: https://github.com/sensu-plugins
[bonsai]: https://bonsai.sensu.io
[bonsai-publishing]: https://docs.sensu.io/sensu-go/latest/plugins/assets/#share-an-asset-on-bonsai
[sensu community]: https://discourse.sensu.io/signup
[the Ruby runtime]: https://bonsai.sensu.io/assets/sensu/sensu-ruby-runtime
[go]: https://golang.org
[gopher]: img/gopher.png

<!-- External links -->
[checksums]: https://en.wikipedia.org/wiki/Checksum
[sha512]: https://en.wikipedia.org/wiki/SHA-2
[artifactory]: https://jfrog.com/artifactory/
[nginx]: https://www.nginx.com
[container runtime]: https://kubernetes.io/docs/setup/production-environment/container-runtimes/
[oci images]: https://opencontainers.org
[posix]: https://en.wikipedia.org/wiki/POSIX#POSIX-oriented_operating_systems