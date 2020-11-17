# Starbound
Simple to set up starbound server.

## Building the image
Since it is not possible to download the dedicated server without a copy of the game purchased on steam, this image can't be built automatically by docker hub without leaking credentials. You have to build the image yourself, but can use the included build script:
```bash
git clone --recurse-submodules https://github.com/Hetsh/docker-starbound.git
docker-starbound/build.sh
```

## Running the server
```bash
docker run --detach --name starbound --publish 21025:21025/tcp hetsh/starbound
```

## Stopping the container
```bash
docker stop starbound
```

## Updates
This image contains a specific version of the game and will not update on startup, this decreases starting time and disk space usage. Version number is the manifest id that can also be found on [SteamDB](https://steamdb.info/depot/533833). This id is updated hourly.

## Creating persistent storage
```bash
MP="/path/to/storage"
mkdir -p "$MP"
chown -R 1370:1370 "$MP"
```
`1370` is the numerical id of the user running the server (see Dockerfile).
Start the server with the additional mount flag:
```bash
docker run --mount type=bind,source=/path/to/storage,target=/starbound ...
```

## Automate startup and shutdown via systemd
The systemd unit can be found in my GitHub [repository](https://github.com/Hetsh/docker-starbound).
```bash
systemctl enable starbound@<port> --now
```
Individual server instances are distinguished by host-port.
By default, the systemd service assumes `/apps/starbound/<port>` for persistent storage and `/etc/localtime` for timezone.
Since this is a personal systemd unit file, you might need to adjust some parameters to suit your setup.

## Fork Me!
This is an open project (visit [GitHub](https://github.com/Hetsh/docker-starbound)).
Please feel free to ask questions, file an issue or contribute to it.