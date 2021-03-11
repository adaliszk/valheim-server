# Basic Docker setup using Docker managed volumes
By default, docker will take care of many things. One of that is persistent data of your containers. Volumes are the 
preferred mechanism because you don't need to worry about them for most of the time, and you can let Docker manage it 
on its own.

### In TL;DR:
Docker will automatically create folders where containers can store data on the machine where its hosted or use a network 
solution if configured to do so.

To quickly start a server you can just do a `docker run` and pass the Valheim Server 
arguments:
```bash
docker run --detached --publish-all adaliszk/valheim-server -name "My Server" -password "MyPassword"
```
**Note**: This will expose the server on random ports, that you can check in `docker ps`!

To further understand what volumes are, check out Docker's documentation page:  
https://docs.docker.com/storage/volumes

For the full list of possible options for the `docker run` command, refer to Docker's documentation page:  
https://docs.docker.com/engine/reference/run


## How to start the image?
By default, the image includes the volume definitions to persist data, so you do not need to manually set anything, but 
your desired ports to expose:
```bash
docker run --name valheim -p 2456-2457:2456-2457/udp adaliszk/valheim-server
```

This will create volumes for:
- `/data` - the server's data (world files, configs)
- `/scripts` - the server functions like how to start the server, what exactly to do on a backup, etc.
- `/backups` - backups from the world files
- `/logs` - log files for debugging and metrics

The command above will automatically attach your terminal/console window to the container, and you will see the server's 
output. Within this window, you can hit `CTRL+C` to stop the server or `CTRL+D` ( or `CTRL+Q` on windows) to detach 
your window from it, but leave it running. If you add `-d` or `--detached` to the command, it will not attach your 
console to it.

To check if the container is running, you can use `docker ps`:

![docker ps outlook example](basic-Docker-01.png)


## How to use Custom ports?
If you are running multiple servers, or just don't want to use the default ports, you can do a port forward by matching
your desired ports with the container's:
```bash
docker run -p 2456:2456/udp 2457:2457/udp adaliszk/valheim-server
```

This allows you to move the Steam Query (`:2457`) port for example to its default location: `:27015` allowing you to only
require to share your IP address where the server is exposed to.

The way the port definition works is `<HOST-MACHINE>:<CONTAINER>/<PROTOCOL>`



## How to configure the server?
In order to configure your server, you can pass the official arguments strait to the container's default command:
```bash
docker run -p 2456-2457:2456-2457/udp adaliszk/valheim-server -name "My Server" -password "MyPassword"
```
However, since there is no argument for the player list files, I've added them:
- `-admins` - Comma separated list of SteamID64's for admins on your server
- `-permitted` - Comma separated list of SteamID64's for the permitted list who can join
- `-banned` - Comma separated list of SteamID64's for the banned list to shut out people

If you don't want to manage these via arguments you can have alternative options.

The configs - well, the whole server data - live under `/data` so in order to modify them you can:
- Login into the container and edit them there directly
- Mount these somewhere you can edit it outside the container
- Use environment variables prepared to handle them


### Using Environment variables
To use the environment variables, you can just pass them with the `docker run` command like:
```bash
docker run -p 2456-2457:2456-2457/udp -e SERVER_NAME="My Server" -e SERVER_PASSWORD="MyPassword" adaliszk/valheim-server
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
| `TZ`                     | Timezone used within the container                          | Etc/UTC                    |


### Mount the configs to a local folder
If you happened to host multiple servers or just want to have an easy way to edit the configs right after logging into 
your server machine, a viable option is to mount the configuration files on the host machine:
```bash
docker run -p 2456-2457:2456-2457/udp \
  -v /path/to/adminlist.txt:/data/adminlist.txt \
  adaliszk/valheim-server -name "My Server" -password "MyPassword"
```

**Note**: Make sure that the configuration files are readable AND writable, the server does not work with read-only files,
however, you can use the `/config` location to initialize your files in a read-only mode. The downside for that is that 
the changes made by the servers - via the `F5` commands - will not be persisted.
```bash
docker run -p 2456-2457:2456-2457/udp \
  -v /path/to/adminlist.txt:/config/adminlist.txt:ro \
  adaliszk/valheim-server -name "My Server" -password "MyPassword"
```


### Login into the container
Another way to configure your server is by "logging in" into your container. A huge disclaimer here, that if you use ANY
of the previous options, then your changes may be overwritten!

First you need to start the container, for easy access you can use `--name` with `docker run` so you don't need to check
what random name it got via `docker ps`:
```bash
docker run --name "my_server" -p -d adaliszk/valheim-server -name "My Server" -password "MyPassword"
```

You can enter the RUNNING container by getting into a shell within the container:
```bash
docker exec -it my_server bash
```

Once you are in, you can navigate around and edit the files just like a normal Linux environment. The files in the volumes
are persisted, so if your edit needs a restart you can `exit` and then restart the container:
```bash
docker restart my_server
```
