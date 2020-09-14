# Troubleshooting 

- [1. Using the `sensuctl` container as a workstation sandbox][1-0]
- [2. Copy files into running containers][2-0]

## 1. Using the `sensuctl` container as a workstation sandbox

This workshop includes a Docker container image with `sensuctl` and some 
additional helper utilities pre-installed. This Docker image can be used as a
"clean" workstation environment to avoid conflicts on your local workstation.

```
$ cd sensu-go-workshop
$ sudo docker-compose run --entrypoint="" sensuctl /bin/ash
~ # sensuctl version
sensuctl version 5.21.0+ee, enterprise edition, build 081a854d483d7881bbcf4cb60c44f87ea5fdf425, built 2020-06-11T19:49:27Z, built with go1.13.7
~ #
```

## 2. Copy files into running containers 

In some cases it may be useful for troubleshooting and/or one-off customization
of the workshop environment to copy files into a running container. In a Docker
environment this can be accomplished via the `docker cp` command, which is very
similar to how you might use `scp` in a traditional virtualization environment.

```
$ sudo docker cp example.json workshop_sensu-backend_1:/tmp/example.json
```

The `docker cp` utility can also be used to _extract_ files from a running 
container. 

```
$ sudo docker cp workshop_sensu-backend_1:/tmp/example.json example.json
```

[1-0]: #1-using-the-sensuctl-container-as-a-workstation-sandbox
[2-0]: #2-copy-files-into-running-containers
[3]: #
[4]: #
[5]: #
[6]: # 
[7]: #
