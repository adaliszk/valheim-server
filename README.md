[![Docker Pulls](https://img.shields.io/docker/pulls/adaliszk/valheim-server?label=pulls&style=for-the-badge)](https://hub.docker.com/r/adaliszk/valheim-server)
[![:latest image size](https://img.shields.io/docker/image-size/adaliszk/valheim-server/latest?style=for-the-badge)](https://hub.docker.com/r/adaliszk/valheim-server)
[![build status](https://img.shields.io/github/workflow/status/adaliszk/valheim-server/docker-build/develop?style=for-the-badge)](https://github.com/adaliszk/valheim-server/actions/workflows/docker-build.yml)

# Valheim Docker Server & Helm Chart
for a clean, fast, standalone docker or kubernetes helm deployments. 

While there are many other images out there, many does fall into the bad habit of using anti-patterns
like Supervisor and Cron in a single image. The images included here tries to not fall into using bad
habits while still offer a full feature-set for managing and monitoring your Valheim Server.

### TL;DR:
```bash
docker run -d --publish adaliszk/valheim-server -name "My Server" -password="super!secret"
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
helm repo add adaliszk https://charts.adaliszk.dev
helm repo update
helm upgrade --install --create-namespace --wait my-valheim-server adaliszk/valheim-server
```


## What is included?
- A fully working Valheim Server WITHOUT the need of downloading anything from the internet
- Using a non-root user for secure Container
- Graceful Stop and automatic Backup of the world files
- Sanitized server output, you finally can say goodbye to the debug noise that is not important
- Health-checks to monitor the image's liveliness
<!--
- Metrics from the logs for Monitoring, Alerting and Error reporting
- Examples how to deploy in Docker and Kubernetes environments with minimal effort
- Automation templates for deployment and backups
-->

## How does the image work?
The image has a very slim wrapper script - the docker entrypoint - that will allow you to execute any 
sort of custom scripts under `/scripts`. The following are available out of the box:
- `noop` - does nothing, it's used for development
- `backup [name]` - take a named backup, using `auto` as default
- `restore [name]` - restore the latest backup with the name, using `auto` as default
- `health` - will return the status of the server, it's used for Health-checks
- `start` - boots up the server, this is pretty much the same as the official start script

By default, the `start` script will be executed, that actually accepts the same arguments as the 
official server executable: `-name`, `-world`, `-password`, `-public`. It will prevent you to overwrite 
the `-port` however, and will add a couple new arguments, `-admins`, `-permitted`, `-banned` that are 
comma separated list of SteamID64's for configuring the server.

The server's data is located under `/data`, this is the place where your live configs, and the world 
can be found. The backups from this location are made into `/backups`. In kubernetes, the ConfigMaps
are mounted into `/configs` as read-only and copied into the `/data` when running any of the commands.

## Prerequisites
At a bare minimum, to use this image - or any other - you will need to set up `Docker`. This can be 
done fairly simply on linux:
```bash
curl -fsSL https://get.docker.com | sudo bash
sudo usermod -aG docker $USER
```
[What does this all mean?](docs/Quick-Docker-Install-Explanation.md)

For other environments, please refer to Docker's documentation:  
https://docs.docker.com/get-docker

## Examples 

- [Docker managed volume setup (recommended)](docs/examples/Docker-managed-Volumes.md)
- [Host folders as persisted data](docs/examples/Host-folder-Volumes.md)



###Super simple setup by relying on Docker to keep the data persisted:
```bash
docker run -d --publish adaliszk/valheim-server
```
this is great for testing the server deployment out, and in many cases it will work just fine. The data
is persisted using volumes, just keep in mind that those might be removed via `docker volume prune` if 
your container happened to be down at the time.

### Using a local folder for persisted data:
```bash
docker run -d --publish -v ./path/to/data:/data -v ./path/to/backups:/backups adaliszk/valheim-server
```
this will ensure that the files are not deleted, and generally good practice for VPS-es that run Docker,
you would need about 300-500M of space for the data while the backups may take several times of that.

### Configuring the variables in `my-config.env`:

```dotenv
SERVER_MOTD="My custom message in the server list"
SERVER_PASSWORD="super!secret"
```

```bash
docker run -d --publish --env-file my-config.env adaliszk/valheim-server
```

Using 

```yaml
version: "3.6"
services:
  valheim:
    image: adaliszk/valheim-server
    environment:
      SERVER_MOTD: "My custom message in the server list"
      SERVER_PASSWORD: "super!secret"
    volumes:
      - /path/to/data:/data
      - /path/to/backups:/backups
    ports:
      - 2456:2456/udp
      - 2457:2457/udp
```
