[![Docker Pulls](https://img.shields.io/docker/pulls/adaliszk/valheim-server?label=Docker%20Pulls)](https://hub.docker.com/r/adaliszk/valheim-server)
[![:latest image size](https://img.shields.io/docker/image-size/adaliszk/valheim-server/latest?label=Image%20Size)](https://hub.docker.com/r/adaliszk/valheim-server)
[![docker status](https://github.com/adaliszk/valheim-server/actions/workflows/docker-build.yml/badge.svg)](https://github.com/adaliszk/valheim-server/actions/workflows/docker-build.yml)
[![helm status](https://github.com/adaliszk/valheim-server/actions/workflows/helm-build.yml/badge.svg)](https://github.com/adaliszk/valheim-server/actions/workflows/helm-build.yml)
[![license](https://img.shields.io/github/license/adaliszk/valheim-server?label=License)](https://github.com/adaliszk/valheim-server/LICENSE.md)

# Valheim Docker Server & Helm Chart
An image for clean, fast and secure Docker & Kubernetes Helm deployments.

While there are many other images out there, they tend to fall into the bad habit of using anti-patterns, like using 
Supervisor and Cron in a single image. The images included here aim to avoid these bad habits, while still offering a 
full feature-set for managing and monitoring your Valheim Server.


### TL;DR:
```bash
# Command Line / Terminal:
docker run adaliszk/valheim-server -name "My Server" -password "super!secret"
```
or
```yaml
# Docker-Compose:
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

## Image Repositories
This image is available in multiple repositories, so you can choose the one you prefer, or perhaps your provider has good
connection with.

- [adaliszk/valheim-server](https://hub.docker.com/r/adaliszk/valheim-server)
- [ghcr.io/adaliszk/valheim-server](https://ghcr.io/adaliszk/valheim-server)
- [quay.io/adaliszk/valheim-server](https://quay.io/adaliszk/valheim-server)

## Supported Architectures
At the moment, the image only supports `linux/amd64`, however, in the future we may support others and then use docker's 
manifest for multi-platform awareness. More information is available from docker [here](https://github.com/docker/distribution/blob/master/docs/spec/manifest-v2-2.md#manifest-list).

Simply pulling `adaliszk/valheim-server` should retrieve the correct image for your arch.


## Version Tags
This image provides various versions that are available via tags. `latest` tag usually provides the latest stable version. 
Others are considered under development and caution must be exercised when using them.

| Tag | Description |
| :----: | --- |
| `latest` | Always the latest build of the server |
| `0.147.3` | The server version v0.147.3 released on 2021-03-02 |
| `dos2unix` | Little helper for windows development, subject for *deprecation* |
| `develop` | Automatic build from develop branch, mainly for synchronizing the README |


## What features does the images have?
- A fully working Valheim Server WITHOUT the need of downloading anything from the internet.
- Using a non-root user to mitigate potential vulnerabilities.
- Gracefully stops the server; enables proper saving before shutdown to avoid world corruption.
- Automatic Backup of the world files on save, and easy guide to set up regular backups.
- Sanitized server output; say goodbye to the debug noise that is not important!
- Health-checks to monitor the image's liveliness


## Usage Examples
- [Basic Docker setup using Docker managed volumes](docs/basic-Docker-setup.md)
- [Basic Docker-Compose setup](docs/basic-Docker-Compose-setup.md)


## How does the server image work?
The server upon starting runs a very slim wrapper script, the *[entry-point](https://docs.docker.com/engine/reference/builder/#entrypoint)*, 
that will allow you to execute custom scripts under `/scripts` via a non-root user.

The entry-point will run a script from the container's *[input](https://docs.docker.com/engine/reference/builder/#cmd)*, 
without directly executing it. This way, the entry-point will monitor the script; so in-case of a failure or improper 
shutdown of the server, it can automatically make or restore a backup.

The user who executes the scripts is called `container` with a primary group on the same name and the id of `1001:1001`. 
When you mount folders you need to use the same IDs to avoid permission problems! Alternatively, you can specify a `PUID` 
and `PGID` environment variable to overwrite the IDs to your system!

Out of the box, the available commands are:
- `noop` - no operation, it's used for development or to force update configurations
- `backup [name]` - take a named backup, using `auto` as default
- `health` - will return the status of the server, it's used for Health-checks
- `start` - boots up the server, this is pretty much the same as the official start script

By default, the `start` script will be executed, which accepts the same arguments as the official server executable: 
`-name`, `-world`, `-password`, `-public`. However, it will prevent you from overwriting the `-port` while adding a few 
new arguments; `-admins`, `-permitted`, `-banned` that are a comma separated list of `SteamID64 (dec)`'s for configuring 
the server.

> **Note**: The prevention for `-port` is there because to expose different server ports, you should use Docker to 
> map your host machine's port to the default ports!

The server's data is located under `/data`, this is the place where your active configs live, and the world can be found. 
The backups from this location are made into `/backups` so make sure that location has enough space allocated to it.


## Contributions
Feel free to open Tickets or Pull-Requests, however, keep in mind that the idea is to keep it simple, and separate the
concerns into multiple small images that are ready without needing to download anything from the internet.

If you have questions, please use the [Discussions](https://github.com/adaliszk/valheim-server/discussions) tab or ping 
me on the [Valheim Discord server](https://discord.gg/valheim): `Kicsivazz#2537`