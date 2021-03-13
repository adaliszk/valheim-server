# What does the following do?

```bash
curl -fsSL https://get.docker.com | sudo bash
sudo usermod -aG docker $USER
```

## Quick explanation:

- `curl ` is a CLI tool to transfer data from or to URL addresses, it is usually installed out of the box
- `-fsSL` makes the output clean and print out errors if there is one
- `https://get.docker.com` is an automated script to install Docker on most linux distributions
- `| sudo bash` means we grab the output and execute it with bash
- `sudo` we need to escalate the normal users rights to install or modify system level things,
  if you run the snippet in root, then you don't need this
- `usermod -aG docker $USER` by default, you will have no access to the docker commands, so we need 
  to assign your user to the right group, this will allow you to use `docker` commands.

## Long explanation:
https://docs.docker.com/engine/install