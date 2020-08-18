# Starbound
Simple to set up starbound server.

## Running the server
```bash
docker run --detach --name starbound --publish 27500:27500/udp --publish 27015:27015/udp hetsh/starbound
```

## Stopping the container
```bash
docker stop starbound
```

## Updates
This image contains a specific version of the game and will not update on startup, this decreases starting time and disk space usage. Version number is the manifest id that can also be found on [SteamDB](https://steamdb.info/depot/600762/). This id and therefore the image on docker hub is updated hourly.

## Configuring Maps
Maps (worlds) are configured via environment variables `WORLD_TYPE` and `WORLD_NAME` with default values `Moon` and `Base`.
To create a new world use additional parameters (Mars only example) `--env WORLD_TYPE=Mars --env WORLD_NAME=MarsBase` when launching the container.
If `WORLD_NAME` already exists, the save is loaded instead and `WORLD_TYPE` is ignored.

## Creating persistent storage
```bash
MP="/path/to/storage"
mkdir -p "$MP"
chown -R 1358:1358 "$MP"
```
`1358` is the numerical id of the user running the server (see Dockerfile).
Start the server with the additional mount flag:
```bash
docker run --mount type=bind,source=/path/to/storage,target=/starbound ...
```

## Automate startup and shutdown via systemd
The systemd unit can be found in my GitHub [repository](https://github.com/Hetsh/docker-starbound).
```bash
systemctl enable starbound@<world> --now
```
Individual server instances are distinguished by world.
By default, the systemd service assumes `/apps/starbound/<world>` for persistent storage and `/etc/localtime` for timezone.
Since this is a personal systemd unit file, you might need to adjust some parameters to suit your setup.

## Fork Me!
This is an open project (visit [GitHub](https://github.com/Hetsh/docker-starbound)). Please feel free to ask questions, file an issue or contribute to it.