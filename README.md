[![server build](https://github.com/adaliszk/valheim-server/actions/workflows/cd-server.yml/badge.svg?label=Server)](https://github.com/adaliszk/valheim-server/actions/workflows/cd-server.yml)
[![monitoring build](https://github.com/adaliszk/valheim-server/actions/workflows/cd-monitoring.yml/badge.svg?label=Monitoring)](https://github.com/adaliszk/valheim-server/actions/workflows/cd-monitoring.yml)
[![helm build](https://github.com/adaliszk/valheim-server/actions/workflows/cd-helm.yml/badge.svg)](https://github.com/adaliszk/valheim-server/actions/workflows/cd-helm.yml)
[![license](https://img.shields.io/github/license/adaliszk/valheim-server?label=License)](https://github.com/adaliszk/valheim-server/LICENSE.md)

# Valheim Docker Server & Helm Chart
Secure Kubernetes-ready Valheim Server with Mod support, Automatic backups, Alpine.

While there are many other images out there, they tend to fall into the bad habit of using anti-patterns, like using 
Supervisor and Cron in a single image. The images included here aim to avoid these bad habits, while still offering a 
full feature-set for managing and monitoring your Valheim Server.

The server image is based on **[frolvlad's alpine with glibc](https://hub.docker.com/r/frolvlad/alpine-glibc)**, 
it has very few packages (<50) and all of them **[without or very few security vulnerabilities](https://quay.io/repository/adaliszk/valheim-server?tab=tags)**.


## What features are included?
- A fully working Valheim Server **without the need of steam downloading** anything from the internet.
- **Keep it simple**; the wrapper is very small and does not do much, this allows the server to be ready in ~15-30s.
- Using a **non-root user** (`1001:1001`) to mitigate potential vulnerabilities.
- **Gracefully stops the server**; enables proper saving before shutdown to avoid world corruption.
- **Automatic Backup** of the world files when the server saves them onto the disk.
- **Sanitized server output**; say goodbye to the debug noise that is not important!
- Health-checks to monitor the image's basic status
- Companion image for monitoring: [adaliszk/valheim-server-monitoring](https://hub.docker.com/r/adaliszk/valheim-server-monitoring)
- Helm chart for Kubernetes: [https://charts.adaliszk.io](https://charts.adaliszk.io/chart/?name=valheim-server)


## Valheim Server
[![:latest pulls](https://img.shields.io/docker/pulls/adaliszk/valheim-server?label=Docker%20Pulls)](https://hub.docker.com/r/adaliszk/valheim-server)
[![:latest size](https://img.shields.io/docker/image-size/adaliszk/valheim-server/latest?label=Image%20Size)](https://hub.docker.com/r/adaliszk/valheim-server)

### Repositories to pull from
- [`adaliszk/valheim-server`](https://hub.docker.com/r/adaliszk/valheim-server)  
- [`ghcr.io/adaliszk/valheim-server`](https://ghcr.io/adaliszk/valheim-server)
- [`quay.io/adaliszk/valheim-server`](https://quay.io/adaliszk/valheim-server)

### Tags
- `vanilla` `latest` - always the latest stable build of the server
- `0.148.7` `0.148` - the server version released on 29/03/2021  
- `0.148.6` - the server version released on 23/03/2021
- `bepinex-5.4.901` `bepinex-5.4.9` `bepinex-5.4` `bepinex` - latest server using [denkinson's BepInEx](https://valheim.thunderstore.io/package/denikson/BepInExPack_Valheim) mod loader  
- `bepinex-5.4.900` - old version of [denkinson's BepInEx](https://valheim.thunderstore.io/package/denikson/BepInExPack_Valheim) mod loader
- `bepinex-full-1.0.5` `bepinex-full-1.0` `bepinex-full` - latest server using [1F31A's BepInEx](https://valheim.thunderstore.io/package/1F31A/BepInEx_Valheim_Full) mod loader
- `plus-0.9.6` `plus-0.9` `plus` - latest server using [Valheim Plus](https://github.com/valheimPlus/ValheimPlus) modpack
- `develop` - build from any actively testing branch

additionally, there are version prefixed tags so you could take any combination!  

### How to use it?

#### barebone docker
```bash
docker run -p 2456-2457:2456-2457/udp adaliszk/valheim-server -name "My Server" -password="super!secret"
```

#### docker-compose
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

#### helm & kubernetes

1. Create your values.yml based on the [full list of values](chart/values.yaml)
2. Add the chart to your repos:

```bash
helm repo add adaliszk https://charts.adaliszk.io
```

3. Deploy it via the `helm upgrade` command:

```bash
helm upgrade --install --create-namespace --wait -f my-values.yml my-valheim-server adaliszk/valheim-server
```

#### [full documentation](docs/vanilla/README.md)
for more in-depth usage information check out the [full documentation](docs/vanilla/README.md)!


## Monitoring companion Image
[![:latest pulls](https://img.shields.io/docker/pulls/adaliszk/valheim-server-monitoring?label=Docker%20Pulls)](https://hub.docker.com/r/adaliszk/valheim-server)
[![:latest size](https://img.shields.io/docker/image-size/adaliszk/valheim-server-monitoring/metrics?label=Image%20Size)](https://hub.docker.com/r/adaliszk/valheim-server-monitoring)


### Repositories to pull from
- [`adaliszk/valheim-server-monitoring`](https://hub.docker.com/r/adaliszk/valheim-server-monitoring)
- [`ghcr.io/adaliszk/valheim-server-monitoring`](https://ghcr.io/adaliszk/valheim-server-monitoring)
- [`quay.io/adaliszk/valheim-server-monitoring`](https://quay.io/adaliszk/valheim-server-monitoring)

### Tags
- `metrics` - mtail metrics from the latest server version
- `metrics-0.148.7` `metrics-0.148` - mtail metrics from the 0.148.6 released on 29/03/2021  
- `metrics-0.148.6` - mtail metrics from the 0.148.6 released on 23/03/2021
- `metrics-0.147.3` `metrics-0.147` - mtail metrics from the 0.147.3 released on 02/03/2021
- `prometheus` - a pre-configured prometheus for docker environments

### How to use it?

#### barebone docker
```bash
docker run --name my_server -d -p 2456-2457:2456-2457/udp adaliszk/valheim-server
docker run -d --volumes-from my_server:ro -d -p 3903:3903 adaliszk/valheim-server-monitoring:metrics
```

#### docker-compose
```yaml
version: "3.8"
volumes:
  - logs: {}
services:

  valheim:
    image: adaliszk/valheim-server
    environment:
      SERVER_NAME: "My custom message in the server list"
      SERVER_PASSWORD: "super!secret"
    volumes:
      - logs:/logs
    ports:
      - 2456:2456/udp
      - 2457:2457/udp
  
  metrics:
    image: adaliszk/valheim-server-monitoring:metrics
    volumes:
      - logs:/logs:ro
    ports:
      - 3903:3903
```

## Examples 
- [Basic Docker setup using Docker managed volumes](docs/basic-Docker-setup.md)
- [Basic Docker-Compose setup](docs/basic-Docker-Compose-setup.md)
- [Basic Docker-Compose setup (docker-compose.yml)](docs/examples/compose-simple.yml)  
- [Basic Compose with Modded server (docker-compose.yml)](docs/examples/compose-modded.yml)
- [Export Metrics with MTail](docs/export-metrics-with-MTail.md)
- [Export Metrics with MTail (docker-compose.yml)](docs/examples/compose-with-metrics.yml)


## Contributions
Feel free to open Tickets or Pull-Requests, however, keep in mind that the idea is to keep it simple, and separate the
concerns into multiple small images that are ready without needing to download anything from the internet.

If you have questions, please use the [Discussions](https://github.com/adaliszk/valheim-server/discussions) tab or ping 
me on the [Valheim Discord server](https://discord.gg/valheim): `Kicsivazz#2537`