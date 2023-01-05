FROM hetsh/steamcmd:20221219-1

# App user
ARG APP_USER="starbound"
ARG APP_UID=1370
RUN useradd --uid "$APP_UID" --user-group --create-home --shell /sbin/nologin "$APP_USER"

# Application & mandatory assets
ARG APP_ID=533830
ARG SRV_DEPOT_ID=533833
ARG SRV_MANIFEST_ID=4004503843917843549
ARG ASSET_DEPOT_ID=533831
ARG ASSET_MANIFEST_ID=2755498507246012069
ARG APP_DIR="$STEAM_DIR/linux32/steamapps/content/app_$APP_ID"
RUN apt update && \
    apt install --assume-yes \
        netcat-openbsd && \
    STEAM_AUTH=$(netcat -d 172.17.0.1 21025) && \
    apt purge --assume-yes --auto-remove \
        netcat-openbsd && \
    rm -r /var/lib/apt/lists /var/cache/apt && \
    steamcmd.sh \
        +login $STEAM_AUTH \
        +download_depot "$APP_ID" "$SRV_DEPOT_ID" "$SRV_MANIFEST_ID" \
        +download_depot "$APP_ID" "$ASSET_DEPOT_ID" "$ASSET_MANIFEST_ID" \
        +quit && \
    mv "$APP_DIR/depot_$ASSET_DEPOT_ID/assets" "$APP_DIR/depot_$SRV_DEPOT_ID" && \
    chown -R "$APP_USER":"$APP_USER" "$STEAM_DIR" && \
    rm -r \
        "$STEAM_DIR"/package/steamcmd_bins_linux.zip* \
        "$STEAM_DIR"/package/steamcmd_linux.zip* \
        "$STEAM_DIR"/package/steamcmd_public_all.zip* \
        "$STEAM_DIR"/package/steamcmd_siteserverui_linux.zip* \
        "$APP_DIR/depot_$ASSET_DEPOT_ID" \
        /tmp/dumps \
        /root/.steam \
        /root/Steam

# Volume
ARG DATA_DIR="/starbound"
RUN mkdir "$DATA_DIR" && \
    chown "$APP_USER":"$APP_USER" "$DATA_DIR" && \
    ln -s "$DATA_DIR" "$APP_DIR/depot_$SRV_DEPOT_ID/storage"
VOLUME ["$DATA_DIR"]

#      GAME
EXPOSE 21025/tcp

# Launch parameters
USER "$APP_USER"
WORKDIR "$APP_DIR/depot_$SRV_DEPOT_ID/linux"
ENTRYPOINT ["./starbound_server"]