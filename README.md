[![Docker Pulls](https://img.shields.io/docker/pulls/adaliszk/valheim-server?label=Docker%20Pulls)](https://hub.docker.com/r/adaliszk/valheim-server)
[![:latest image size](https://img.shields.io/docker/image-size/adaliszk/valheim-server/latest?label=Image%20Size)](https://hub.docker.com/r/adaliszk/valheim-server)
[![server build](https://github.com/adaliszk/valheim-server/actions/workflows/cd-server.yml/badge.svg?label=Server)](https://github.com/adaliszk/valheim-server/actions/workflows/cd-server.yml)
[![monitoring build](https://github.com/adaliszk/valheim-server/actions/workflows/cd-monitoring.yml/badge.svg?label=Monitoring)](https://github.com/adaliszk/valheim-server/actions/workflows/cd-monitoring.yml)
[![helm build](https://github.com/adaliszk/valheim-server/actions/workflows/cd-helm.yml/badge.svg)](https://github.com/adaliszk/valheim-server/actions/workflows/cd-helm.yml)
[![license](https://img.shields.io/github/license/adaliszk/valheim-server?label=License)](https://github.com/adaliszk/valheim-server/LICENSE.md)

# Valheim Server for Docker, Kubernetes, and Pterodactyl

Clean, fast, and standalone Docker image that can be deployed on various setups with minimal footprint. Designed to be
deployed within single host Docker, multi-host Swarm, Kubernetes, and Pterodactyl server manager with high focus on
server-side capabilities.

## What features are included?

- A fully working Valheim Server **without the need of steam downloading** at runtime.
- Extended arguments for quick configuration with config-file support.
- Using a **non-root user** to mitigate potential vulnerabilities that could harm the host system.
- Custom non-root user support for remapping the IDs to your setup, like NAS servers with container support.
- **Gracefully stops the server** that respects online players before shutdown.
- **Improved server output** with added activity and metric information.
- Health-checks to monitor liveliness of the server.
- **In-Memory world data** for fast save cycles.
- Interactive terminal for issuing commands.

## Additional capabilities:

- Automated updates using [**Watchtower**](https://containrrr.dev/watchtower) for docker-based
  and [**Flux**](https://fluxcd.io) for kubernetes-based environments.
- Companion image for Remote Backups:
  [adaliszk/cloud-helper-images/duplicity-backups](https://hub.docker.com/r/adaliszk/duplicity-backup)
- Companion image for Monitoring:
  [adaliszk/valheim-server-exporter](https://hub.docker.com/r/adaliszk/valheim-server-exporter)
- Helm chart for Kubernetes:
  [https://charts.adaliszk.io/valheim-server](https://charts.adaliszk.io/valheim-server)
- Egg for Pterodactyl deployments:
  [https://eggs.adaliszk.io/valhime-server](https://eggs.adaliszk.io/valheim-server)

## Quick Usage:

```bash
docker run -p 2456-2457:2456-2457/udp adaliszk/valheim-server -name "My Server" -password="super!secret"
```

or

```yaml
version: "3.8"
services:

  valheim:
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

## Configuration



## Contributions

Feel free to open Tickets or Pull-Requests, however, keep in mind that the idea is to keep it simple, and separate the
concerns into multiple small images that are ready without needing to download anything from the internet.

If you have questions, please use the [Discussions](https://github.com/adaliszk/valheim-server/discussions) tab or ping
me on the [Valheim Discord server](https://discord.gg/valheim): `Kicsivazz#2537`
