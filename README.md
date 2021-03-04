# Work in Progress!

While this code works on most cases, I still in progress of adding:

- [ ] Add CI/CD pipeline for GitHub
- [ ] Publish the Chart so you could use it without cloning the repo
- [ ] Collect metrics using MTail
- [ ] Monitor health of the connections and hardware
- [ ] Report errors via Sentry
- [ ] Allow mods to be installed dynamically

Currently, the Chart is deployed to GKE, but want to add support for other setups.
Pull Request are welcomed!

# What has been done?

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
