[![:latest image size](https://img.shields.io/docker/image-size/adaliszk/valheim-server/latest?style=for-the-badge)](https://hub.docker.com/r/adaliszk/valheim-server)
![build status](https://img.shields.io/github/workflow/status/adaliszk/valheim-server/docker-build?style=for-the-badge)

# Valheim Server - Docker & Helm
for a clean, fast, standalone docker or kubernetes helm deployments. 

While there are many other images out there, many does fall into the bad habit of using anti-patterns
like Supervisor and Cron in a single image. The image included here tries to not fall into using bad
habits while still offers a full feature-set for managing and monitoring your Valheim Server.

## What is included?

###### A fully working Valheim Server WITHOUT the need of downloading anything from the internet
Having no dependency on installation is not only a nice thing to do for the Steam Download servers,
but it is also beneficial for you since the image can be ready in seconds after your server or 
cluster pulled it into its cache. Furthermore, you won't have to do maintenance chores like
updating your server, so you'll get a fully working setup out of the box.

###### Using a non-root user for the Container
Running containers as a non-root user is a major security benefit that should not need an explanation.
However, the main reason is that you can be assured that a non-root user will prevent malicious code 
from gaining permission in the container, furthermore, some Kubernetes distributions, such as Openshift, 
don't allow you to run containers as root by default.

###### Gracefully stop and automatic Backup of the world files
Since the world is not synchronized all the time, this will make sure that your progress remains safe, 
and even in-case of a shutdown corruption you'll have a state to roll back to.

###### Examples how to deploy in Docker and Kubernetes environments with minimal effort
When you are tired of the problematic Game-Server providers who just re-skin a Pterodactyl panel and 
ask for a full-price of a dedicated VPS-es, or you just tired their endless laggs and desync issues
you'll find simple, few-step tutorials to guide you through setting up your server.

###### Sanitized server output, you finally can say goodbye to the debug noise that is not important
If you ever seen a server output, you'll know that it splits out a lot of debug information that makes
it hard to see what's going on. This image includes a very simple, tested, prettyfier that will help
you to see what's going on the server's output.

###### Health-checks to monitor the image's liveliness
Testing that the image is healthy is a baseline practice, you'll get some simple and fast checks and
even some advanced ones to track down that your deployment is working properly!

###### Metrics from the logs, Monitoring, Alerting and Error reporting
White-box metrics is a golden mine for information, you can use this to set up alerts or just be able
to tell how is your player-base doing, do they encounter issues, etc. You are also welcomed to Opt-In
to report issues that may help to track down some very specific conditions.

###### Automation templates
Weather you want to customize your server behaviour or just have a daily restart you will be able to
set it up via the templates and guides included in this repo!


## Work in Progress!

While this code works on most cases, I still in progress of adding:

- [x] Add CI/CD pipeline for GitHub
- [ ] Publish the Chart that you could use it without cloning the repo
- [ ] Collect metrics using MTail
- [ ] Monitor health of the connections and hardware
- [ ] Report errors via Sentry
- [ ] Add ModLoader tags so you can install mods for your server

Currently, the Chart is deployed to GKE, but want to add support for other setups.
Pull Request are welcomed!

### What has been done?

- The `/home/steam/.config/unity3d/IronGate/Valheim` stores your server configs, worlds and backups
- The `/tmp/valheim` stores log files like the raw server output and various processed logs
- Whenever the server is killed, it will do a backup before the process is killed into `/home/steam/.config/unity3d/IronGate/Valheim/backups`
- Healthcheck looks for the `:2456` and `:2457` ports being open
- The server will run scripts in `/home/steam/scripts` so you can replace them with whatever is your preference

# How to configure the image?

You can configure the server with the following variables:

| Variable                           | What it does                                   | Default Value                   |
| --------------------------------- |---------------------------------------------- | ---------------------------------- |
| `SERVER_NAME`            | Only used with Helm                    | `Valheim`                       |
| `SERVER_MOTD`            | The full server message in the server window                    | `Valheim v{version}`                       |
| `SERVER_WORLD`         | The Worldfile name                     | `Dedicated` |
| `SERVER_PASSWORD` | The password that is at least 5 characters | `12345` | 
