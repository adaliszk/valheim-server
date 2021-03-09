# Install Vanilla Server
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
FROM steamcmd/steamcmd:ubuntu as steam
ENV APP_ID="896660" \
    APP_VERSION="0.147.3" \
    APP_BUILD="6315977" \
    APP_PATH="/server"

# hadolint ignore=DL3018,DL3008
RUN apt-get -y install --no-install-recommends bash
RUN steamcmd +login anonymous +force_install_dir "${APP_PATH}" +app_update ${APP_ID} +quit
RUN bash -c "rm -rf ${APP_PATH}/*.{sh,pdf}"
RUN tar -czvf "${APP_PATH}/valheim_server_Data.tar.gz" -C "${APP_PATH}" "valheim_server_Data" \
 && rm -rf "${APP_PATH}/valheim_server_Data"

# Fix file format and permissions for the Windows peeps out there
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
FROM adaliszk/valheim-server:dos2unix as unix

COPY server /server-scripts
COPY srv /srv-scripts

RUN dos2unix /server-scripts/** && chmod +x /server-scripts/** \
 && dos2unix /srv-scripts/** && chmod +x /srv-scripts/**

# Set up the Runtime Environment
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
FROM debian:stable-slim as runtime
ENV SERVER_NAME="Valheim" \
    SERVER_MOTD="Valheim Vanilla Server" \
    SERVER_WORLD="Dedicated" \
    SERVER_PASSWORD="p4ssw0rd" \
    SERVER_PUBLIC="1" \
    TZ="Europe/Berlin" \
    SERVER_PATH="/server" \
    CONFIG_PATH="/config" \
    SCRIPTS_PATH="/scripts" \
    BACKUP_PATH="/backups" \
    DATA_PATH="/data" \
    LOG_PATH="/logs"

# hadolint ignore=DL3018,DL3008
RUN addgroup --gid 1001 container && useradd -u 1001 --gid 1001 -ms /bin/bash container  \
 && apt-get update && apt-get -y install --no-install-recommends \
    bash python3 sed tzdata coreutils net-tools dnsutils nmap \
 && bash -c "mkdir -p {${CONFIG_PATH},${SERVER_PATH},${BACKUP_PATH},${DATA_PATH},${LOG_PATH}}" \
 && chown 1001:1001 ${CONFIG_PATH} ${SERVER_PATH} ${BACKUP_PATH} ${DATA_PATH} ${LOG_PATH} \
 && rm -rf /var/lib/apt/lists/*

COPY --from=steam --chown=1001 /server /server
COPY --from=unix --chown=1001 /server-scripts /scripts
COPY --from=unix /srv-scripts /srv

VOLUME ["/config", "/data", "/backups", "/logs"]
ENTRYPOINT ["/srv/docker-entrypoint.sh"]

USER 1001
HEALTHCHECK CMD ["health"]
STOPSIGNAL SIGINT
EXPOSE 2456-2457/udp
CMD ["start"]

#FROM server-vanilla as server
#ENV DEFAULT_SERVER_NAME="Valheim" \
#    DEFAULT_SERVER_MOTD="Valheim v${SERVER_VERSION}" \
#    DEFAULT_SERVER_WORLD="Dedicated" \
#    DEFAULT_SERVER_PASSWORD="p4ssw0rd"
#
#COPY --from=unix /srv-scripts /srv
#COPY --from=unix /sbin-scripts/docker-entrypoint.sh /sbin/docker-entrypoint
#COPY --from=unix /sbin-scripts/valheim-console.py /sbin/valheim-console
#ENTRYPOINT ["/sbin/docker-entrypoint"]
#
#COPY --from=unix --chown=1001 /server-scripts /home/steam/scripts
#
#VOLUME [
#    "/home/steam/valheim-data",
#    "/home/steam/valheim-backups"
#]
#
#USER 1001
#HEALTHCHECK CMD ["health"]
#STOPSIGNAL SIGTERM
#EXPOSE 2456-2458/udp
#CMD ["start"]
