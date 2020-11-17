FROM hetsh/steamcmd:1.3-1

# App user
ARG APP_USER="starbound"
ARG APP_UID=1370
RUN useradd --uid "$APP_UID" --user-group --create-home --shell /sbin/nologin "$APP_USER"

# Application & mandatory assets
ARG APP_ID=533830
ARG DEPOT_ID=533833
ARG MANIFEST_ID=4004503843917843549
ARG ASSET_DEPOT_ID=533831
ARG ASSET_MANIFEST_ID=2755498507246012069
ARG APP_DIR="$STEAM_DIR/linux32/steamapps/content/app_$APP_ID"
ARG STEAM_USER="anonymous"
ARG STEAM_PW
ARG STEAM_GUARD
RUN steamcmd.sh \
        +login "$STEAM_USER" "$STEAM_PW" "$STEAM_GUARD" \
        +download_depot "$APP_ID" "$DEPOT_ID" "$MANIFEST_ID" \
        +download_depot "$APP_ID" "$ASSET_DEPOT_ID" "$ASSET_MANIFEST_ID" \
        +quit && \
    mv "$APP_DIR/depot_$ASSET_DEPOT_ID/assets" "$APP_DIR/depot_$DEPOT_ID" && \
    chown -R "$APP_USER":"$APP_USER" "$STEAM_DIR" && \
    rm -r "$APP_DIR/depot_$ASSET_DEPOT_ID" /tmp/dumps /root/.steam /root/Steam

# Volume
ARG DATA_DIR="/starbound"
RUN mkdir "$DATA_DIR" && \
    chown "$APP_USER":"$APP_USER" "$DATA_DIR" && \
    ln -s "$DATA_DIR" "$APP_DIR/depot_$DEPOT_ID/storage"
VOLUME ["$DATA_DIR"]

#      GAME
EXPOSE 21025/tcp

# Launch parameters
USER "$APP_USER"
WORKDIR "$APP_DIR/depot_$DEPOT_ID/linux"
ENTRYPOINT ["./starbound_server"]