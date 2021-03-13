# Basic Docker Compose setup


For a more organized setup, docker provides an easy-to-use Orchestration tool called [Docker-Compose](https://docs.docker.com/compose).
You can install it by following the [official guide](https://docs.docker.com/compose/install), or just use this quick TL;DR:
```bash
curl -fsSL "https://github.com/docker/compose/releases/download/latest/docker-compose-$(uname -s)-$(uname -m)" > /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```
[What does all this mean?](quick-Docker-Compose-install-explanation.md)

## Basic Server
Once you have the `docker-compose` command installed, all you need to do is write a simple YAML file called `docker-compose.yml`:
```yaml
version: "3.6"

services:

  my_server:
    image: adaliszk/valheim-server
    
    # Set the parameters for the server
    environment:
      SERVER_NAME: "My Server"
      SERVER_PASSWORD: "MyPassword"
      SERVER_ADMINS: "76561198017260467,76561198017260467,76561198017260467"
    
    # Port forwards in a format of <HOST-MACHINE>:<CONTAINER>/<PROTOCOL>
    ports:
      - 2456:2456/udp
      - 2457:2457/udp
```

With that you can start the server(s) with:
```bash
docker-compose up
```

Fur the full list of arguments please check out Docker's documentation:  
https://docs.docker.com/compose/reference/overview