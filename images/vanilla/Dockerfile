
# Install Vanilla Server
# =================================================================================================
FROM steamcmd/steamcmd:ubuntu as steam
ENV APP_ID="896660" \
    APP_VERSION="0.147.3" \
    APP_BUILD="6315977" \
    APP_PATH="/server"

# hadolint ignore=DL3018,DL3008
RUN apt-get -y install --no-install-recommends bash tar
RUN steamcmd +login anonymous +force_install_dir "${APP_PATH}" +app_update ${APP_ID} validate +quit
# Compress files so the image can be small for the price of ~5-10s decompression on runtime
RUN tar -czf "${APP_PATH}/valheim_server_Data.tar.gz" -C "${APP_PATH}" "valheim_server_Data" \
 && rm -rf "${APP_PATH}/valheim_server_Data"


# Fix file format and permissions for the Windows peeps out there
# =================================================================================================
FROM adaliszk/dos2unix:latest as unix

COPY srv /srv-scripts
COPY scripts /scripts
RUN dos2unix /srv-scripts/** && chmod +x /srv-scripts/** \
 && dos2unix /scripts/** && chmod +x /scripts/**


# Set up the Runtime Environment
# =================================================================================================
FROM frolvlad/alpine-glibc:alpine-3.13 as runtime
ENV SERVER_NAME="Valheim v0.147.3" \
    SERVER_WORLD="Dedicated" \
    SERVER_PASSWORD="p4ssw0rd" \
    SERVER_PUBLIC="1" \
    TZ="Etc/UTC" \
    SERVER_PATH="/server" \
    CONFIG_PATH="/config" \
    SCRIPTS_PATH="/scripts" \
    BACKUP_PATH="/backups" \
    BACKUP_RETENTION="6" \
    DATA_PATH="/data" \
    LOG_PATH="/logs"

COPY --from=steam --chown=1001 /server /server

# hadolint ignore=DL3018,DL3008
RUN addgroup --gid 1001 container && adduser --uid 1001 --shell /bin/bash -G container -S container \
 # @TODO: remove Python3 dependency via building the VhPretty as a binary
 && apk add --no-cache coreutils bash multitail tzdata python3 net-tools sdl2 ca-certificates \
 && bash -c "mkdir -p {${SCRIPTS_PATH},${CONFIG_PATH},${SERVER_PATH},${BACKUP_PATH},${DATA_PATH},${LOG_PATH}}" \
 && chown 1001:1001 ${SCRIPTS_PATH} ${CONFIG_PATH} ${SERVER_PATH} ${BACKUP_PATH} ${DATA_PATH} ${LOG_PATH}

COPY --from=unix  /srv-scripts /srv
COPY --from=unix /scripts /scripts

COPY --from=unix /srv-scripts/valheim.sh /valheim
ENTRYPOINT ["/valheim"]

VOLUME ["/data", "/backups", "/logs"]
STOPSIGNAL SIGINT
CMD ["start"]
USER 1001

HEALTHCHECK CMD ["health"]
EXPOSE 2456-2457/udp
