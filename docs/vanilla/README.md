The image is based on **[Frolvlad's Alpine with glibc included](https://hub.docker.com/r/frolvlad/alpine-glibc)**, so it has very few packages (<50) and all of them up to date **[without or very few security vulnerabilities](https://quay.io/repository/adaliszk/valheim-server?tab=tags)**. The Valheim server is **pre-installed**, so you should only experience bandwidth usage that the server strictly needs! Note that, in order to update your server, you only need to pull the image!

## Tags
- `vanilla` `latest` - always the latest stable build of the server
- `0.148.6` `0.148` - the server version released on 23/03/2021
- `0.147.3` `0.147` - the server version released on 02/03/2021
- `bepinex-5.4.901` `bepinex-5.4.9` `bepinex-5.4` `bepinex` - latest server using [denkinson's BepInEx](https://valheim.thunderstore.io/package/denikson/BepInExPack_Valheim) mod loader
- `bepinex-5.4.900` - old version of [denkinson's BepInEx](https://valheim.thunderstore.io/package/denikson/BepInExPack_Valheim) mod loader
- `bepinex-5.4.800` `bepinex-5.4.8` - old version of [denkinson's BepInEx](https://valheim.thunderstore.io/package/denikson/BepInExPack_Valheim) mod loader
- `bepinex-full-1.0.5` `bepinex-full-1.0` `bepinex-full` - server using [1F31A's BepInEx](https://valheim.thunderstore.io/package/1F31A/BepInEx_Valheim_Full) mod loader
- `plus-0.9.5-hotfix1` `plus-0.9.5` `plus-0.9` `plus` - server using Valheim Plus mod
- `develop` - build any actively testing branch


## What features do the images have?
- A fully working Valheim Server **without the need of steam downloading** anything from the internet.
- Using a **non-root user** to mitigate potential vulnerabilities.
- **Gracefully stops the server**; enables proper saving before shutdown to avoid world corruption.
- **Automatic Backup** of the world files when the server saves them onto the disk.
- **Sanitized server output**; say goodbye to the debug noise that is not important!
- Health-checks to monitor the image's basic status
- Companion image for monitoring: [adaliszk/valheim-server-monitoring](https://hub.docker.com/r/adaliszk/valheim-server-monitoring)


## How does the server image work?
The server upon starting runs a very slim wrapper script, the *[entry-point](https://docs.docker.com/engine/reference/builder/#entrypoint)*,
that will allow you to execute custom scripts under `/scripts`.

The entry-point will run a script from the container's *[input](https://docs.docker.com/engine/reference/builder/#cmd)*,
without directly executing it. This way, the entry-point will monitor the given command; so in-case of a failure or improper
shutdown of the server, it can automatically make a backup or report the incident.


## How to use it?

Run it via basic commands:
```bash
docker run -p 2456-2457:2456-2457/udp adaliszk/valheim-server -name "My Server" -password="super!secret"
```

Use it with Docker-Compose:
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

The image has a very thin wrapper that allows you to run a few pre-defined commands:
- `noop` - no operation, it's used for development
- `backup [name]` - take a named backup, using `auto` as default
- `health` - will return the status of the server, it's used for Health-checks
- `start [args...]` - boots up the server (default), this is pretty much the same as the official start script


## How to configure the server?
In order to configure your server, you can pass the [official arguments](https://cdn.discordapp.com/attachments/806216652742983700/816608737422344192/Valheim_Dedicated_Server_Manual.pdf) strait to the container's default command:
```bash
docker run -p 2456-2457:2456-2457/udp adaliszk/valheim-server -name "My Server" -password "MyPassword"
```
However, since there is no argument for moderation, I've added them:
- `-admins` - Comma separated list of `SteamID64 (dec)`'s for admins on your server
- `-permitted` - Comma separated list of `SteamID64 (dec)`'s for the permitted list who can join
- `-banned` - Comma separated list of `SteamID64 (dec)`'s for the banned list to shut out people

If you don't want to manage these via arguments you can have alternative options.

The configs - well, the whole server data - live under `/data` so in order to modify them you can:
- Login into the container and edit them there directly
- Mount these somewhere you can edit them outside the container
- Use environment variables prepared to handle them


### Using Environment variables
To use the environment variables, you can just pass them with the `docker run` command like:
```bash
docker run -e SERVER_NAME="My Server" -e SERVER_PASSWORD="MyPassword" adaliszk/valheim-server
```
Please note that the arguments shown in the previous section will Overwrite the environment variables!

The available variables are:

| Variable                 | What is it for?                                             | Default value              |         
| ------------------------ | ----------------------------------------------------------- | -------------------------- | 
| `SERVER_NAME`            | The message in the Server Browser for players               | Valheim v{version}         |
| `SERVER_PASSWORD`        | The password of the server, minimum 5 characters!           | p4ssw0rd                   |
| `SERVER_WORLD`           | The world-file name                                         | Dedicated                  |
| `SERVER_PUBLIC`          | Steam Server Query used or not                              | 1                          |
| `SERVER_ADMINS`          | Comma separated list of SteamID64's for admin access        | (empty)                    |
| `SERVER_PERMITTED`       | Comma separated list of SteamID64's for the permitted list  | (empty)                    |
| `SERVER_BANNED`          | Comma separated list of SteamID64's for the banned list     | (empty)                    |
| `BACKUP_RETENTION`       | The number of backups to keep from a particular `[name]`    | 6                          |
| `TZ`                     | Timezone used within the container                          | Etc/UTC                    |


### Mount the configs to a local folder
If you happened to host multiple servers or just want to have an easy way to edit the configs right after logging into
your server machine, a viable option is to mount the configuration files on the host machine:
```bash
docker run -p 2456-2457:2456-2457/udp -v /path/to/adminlist.txt:/data/adminlist.txt \
  adaliszk/valheim-server -name "My Server" -password "MyPassword"
```

**Note**: Make sure that the configuration files are readable AND writable, the server does not work with read-only files,
however, you can use the `/config` location to initialize your files in a read-only mode. The downside for that is that the changes made by the servers - via the `F5` commands - will not be persisted.
```bash
docker run -p 2456-2457:2456-2457/udp -v /path/to/adminlist.txt:/config/adminlist.txt:ro \
  adaliszk/valheim-server -name "My Server" -password "MyPassword"
```

## Volumes

When you run the image, docker will create persistent storage for multiple locations inside the container. You can mount these into your host machine if you want, but in general you can just let docker manage it. The locations are:

- `/data`: the server's data (world files, configs)
- `/backups`: backups from the world files
- `/config`: configuration files to load on start (typically Read-Only files (ConfigMaps))
- `/plugins`: the desired server-side mod DLLs for `bepinex` and `plus`
- `/logs`: log files for debugging and metrics
