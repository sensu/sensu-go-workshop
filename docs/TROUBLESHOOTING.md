# Troubleshooting 

- [1. Using the `sensuctl` container as a workstation sandbox][1-0]

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

[1-0]: #1-using-the-sensuctl-container-as-a-workstation-sandbox

[2]: #
[3]: #
[4]: #
[5]: #
[6]: # 
[7]: #
