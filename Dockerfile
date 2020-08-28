FROM hetsh/steamcmd:1.1-14

# App user
ARG APP_USER="starbound"
ARG APP_UID=1370
ARG DATA_DIR="/starbound"
RUN useradd --uid "$APP_UID" --user-group --create-home --home "$DATA_DIR" --shell /sbin/nologin "$APP_USER"

# Application
ARG APP_ID=533830
ARG DEPOT_ID=533833
ARG MANIFEST_ID=4004503843917843549
ARG APP_DIR="$STEAM_DIR/linux32/steamapps/content/app_$APP_ID/depot_$DEPOT_ID"
RUN steamcmd.sh +login anonymous +download_depot "$APP_ID" "$DEPOT_ID" "$MANIFEST_ID" +quit && \
    chown -R "$APP_USER":"$APP_USER" "$APP_DIR"

# Volume
ARG LOG_DIR="/var/log/starbound"
RUN mkdir -p "$LOG_DIR" && \
    chown -R "$APP_USER":"$APP_USER" "$LOG_DIR"
VOLUME ["$DATA_DIR", "$LOG_DIR"]

#      GAME      RCON      QUERY
EXPOSE 27500/udp 27500/tcp 27015/udp

# Launch parameters
USER "$APP_USER"
WORKDIR "$DATA_DIR"
ENV APP_DIR="$APP_DIR"
ENTRYPOINT exec "$APP_DIR/linux/starbound_server" \
    1> "$LOG_DIR/info.log" \
    2> "$LOG_DIR/error.log"
