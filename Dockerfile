FROM hetsh/steamcmd:1.3-1

# App user
ARG APP_USER="starbound"
ARG APP_UID=1370
ARG DATA_DIR="/starbound"
RUN useradd --uid "$APP_UID" --user-group --create-home --home "$DATA_DIR" --shell /sbin/nologin "$APP_USER"
VOLUME ["$DATA_DIR"]

# Application
ARG STEAM_USER="anonymous"
ARG STEAM_PW=""
ARG STEAM_GUARD=""
ARG APP_ID=533830
ARG DEPOT_ID=533833
ARG MANIFEST_ID=4004503843917843549
ARG APP_DIR="$STEAM_DIR/linux32/steamapps/content/app_$APP_ID/depot_$DEPOT_ID"
RUN steamcmd.sh +login "$STEAM_USER" "$STEAM_PW" "$STEAM_GUARD" +download_depot "$APP_ID" "$DEPOT_ID" "$MANIFEST_ID" +quit && \
    chown -R "$APP_USER":"$APP_USER" "$APP_DIR" && \
    rm -r /tmp/dumps /root/.steam /root/Steam

#Ports GAME
EXPOSE 21025/tcp

# Launch parameters
USER "$APP_USER"
WORKDIR "$DATA_DIR"
ENV APP_DIR="$APP_DIR"
#ENTRYPOINT exec "$APP_DIR/linux/starbound_server"