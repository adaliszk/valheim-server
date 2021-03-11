[![Docker Pulls](https://img.shields.io/docker/pulls/adaliszk/valheim-server?label=pulls&style=for-the-badge)](https://hub.docker.com/r/adaliszk/valheim-server)
[![:latest image size](https://img.shields.io/docker/image-size/adaliszk/valheim-server/latest?style=for-the-badge)](https://hub.docker.com/r/adaliszk/valheim-server)
[![docker status](https://img.shields.io/github/workflow/status/adaliszk/valheim-server/docker-build/develop?style=for-the-badge&label=BUILD)](https://github.com/adaliszk/valheim-server/actions/workflows/docker-build.yml)
[![helm status](https://img.shields.io/github/workflow/status/adaliszk/valheim-server/helm-build/develop?style=for-the-badge&label=HELM)](https://github.com/adaliszk/valheim-server/actions/workflows/helm-build.yml)
[![license](https://img.shields.io/github/license/adaliszk/valheim-server?style=for-the-badge)](https://github.com/adaliszk/valheim-server/LICENSE.md)


# Valheim Docker Server & Helm Chart
Clean, fast and standalone Docker & Kubernetes helm deployments.

While there are many other images out there, they tend to fall into the bad habit of using anti-patterns, like using 
Supervisor and Cron in a single image. The images included here aim to avoid these bad habits, while still offering a 
full feature-set for managing and monitoring your Valheim Server.


### TL;DR:
```bash
docker run -d --publish-all adaliszk/valheim-server -name "My Server" -password="super!secret"
```
or
```yaml
version: "3.6"
services:
  server:
    image: adaliszk/valheim-server
    environment:
      SERVER_NAME: "My custom message in the server list"
      SERVER_PASSWORD: "super!secret"
    ports:
      - 2456:2456/udp
      - 2457:2457/udp
```
or
```bash
helm repo add adaliszk https://charts.adaliszk.io
helm upgrade --install --create-namespace --wait my-valheim-server adaliszk/valheim-server
```

## Are you new to Docker or Kubernetes?
- [What is Docker?](https://opensource.com/resources/what-docker)
- [What is Docker-Compose?](https://hackernoon.com/practical-introduction-to-docker-compose-d34e79c4c2b6)  
- [What is Kubernetes?](https://opensource.com/resources/what-is-kubernetes)
- [How to install and use Docker on Ubuntu 20.04?](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04)
- [How to create a Kubernetes Cluster using Kubeadm on Ubuntu 18.04?](https://www.digitalocean.com/community/tutorials/how-to-create-a-kubernetes-cluster-using-kubeadm-on-ubuntu-18-04)
- [What is Rancher?](https://rancher.com/why-rancher)

## Prerequisites
At a bare minimum, to use this image - or any other - you will need to set up `Docker`. This can be done fairly simply 
on linux:
```bash
curl -fsSL https://get.docker.com | sudo bash
sudo usermod -aG docker $USER
```
[What does this all mean?](docs/quick-Docker-install-explanation.md)

For other environments, please refer to [Docker's documentation](https://docs.docker.com/get-docker), in general you 
would need to install an App that does all the details behind the scenes and gives you a GUI to overview containers.


## What features does the images have?
- A fully working Valheim Server WITHOUT the need of downloading anything from the internet.
- Using a non-root user to mitigate potential vulnerabilities.
- Gracefully stops the server; enables proper saving before shutdown to avoid world corruption.
- Automatic Backup of the world files on save, and easy guide to set up regular backups.
- Sanitized server output; say goodbye to the debug noise that is not important!
- Health-checks to monitor the image's liveliness
<!--
@TODO:
- Metrics from the logs for Monitoring, Alerting and Error reporting
- Examples how to deploy in Docker and Kubernetes environments with minimal effort
- Automation templates for deployment and backups
-->


## How does the server image work?
The server upon starting runs a very slim wrapper script, the *[entry-point](https://docs.docker.com/engine/reference/builder/#entrypoint)*, 
that will allow you to execute custom scripts under `/scripts`. 

The entry-point will run a script from the container's *[input](https://docs.docker.com/engine/reference/builder/#cmd)*, 
without directly executing it. This way, the entry-point will monitor the script; so in-case of a failure or improper 
shutdown of the server, it can automatically make or restore a backup.

Out of the box, the available commands are:
- `noop` - no operation, it's used for development or to force update configurations
- `backup [name]` - take a named backup, using `auto` as default
- `health` - will return the status of the server, it's used for Health-checks
- `start` - boots up the server, this is pretty much the same as the official start script
<!--  
@TODO:
- `restore [name]` - restore the latest backup with the name, using `auto` as default
-->

By default, the `start` script will be executed, which accepts the same arguments as the official server executable: 
`-name`, `-world`, `-password`, `-public`. However, it will prevent you from overwriting the `-port` while adding a few 
new arguments; `-admins`, `-permitted`, `-banned` that are a comma separated list of `SteamID64 (dec)`'s for configuring 
the server.

> **Note**: The prevention for `-port` is there because to expose different server ports, you should use Docker to 
> map your host machine's port to the default ports!

The server's data is located under `/data`, this is the place where your active configs live, and the world can be found. 
The backups from this location are made into `/backups` so make sure that location has enough space allocated to it.


## Examples 
- [Basic Docker setup using Docker managed volumes](docs/basic-Docker-setup.md)
- [Basic Docker-Compose setup](docs/basic-Docker-Compose-setup.md)
<!--  
@TODO:
- [Host folders as persisted data](docs/Host-folder-Volumes.md)
- [Using a Domain with a Landing Page](docs/Domain-name-with-Landing-page.md)
- [Debug Deployment with a helper image](docs/Debug-Deployment.md)  
- [Deploy into Kubernetes](docs/Kubernetes.md)
- [Metric data](docs/Show-Metrics-data.md)  
-->


## Contributions
Feel free to open Tickets or Pull-Requests, however, keep in mind that the idea is to keep it simple, and separate the
concerns into multiple small images that are ready without needing to download anything from the internet.