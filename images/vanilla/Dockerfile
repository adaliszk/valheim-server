# Install Vanilla Server
# =================================================================================================
FROM steamcmd/steamcmd:ubuntu as steam
ENV APP_ID="896660" \
    APP_VERSION="0.147.3" \
    APP_BUILD="6315977" \
    APP_PATH="/server"

# hadolint ignore=DL3018,DL3008
RUN apt-get -y install --no-install-recommends bash tar
RUN steamcmd +login anonymous +force_install_dir "${APP_PATH}" +app_update ${APP_ID} +quit
# Compress files so the image can be small for the price of ~5s decompression on runtime
RUN tar -czf "${APP_PATH}/valheim_server_Data.tar.gz" -C "${APP_PATH}" "valheim_server_Data" \
 && rm -rf "${APP_PATH}/valheim_server_Data"


# Fix file format and permissions for the Windows peeps out there
# =================================================================================================
FROM adaliszk/valheim-server:dos2unix as unix

COPY srv /scripts
RUN dos2unix /scripts/** && chmod +x /scripts/**


# Set up the Runtime Environment
# =================================================================================================
FROM debian:stable-slim as runtime
ENV SERVER_NAME="Valheim v0.147.3" \
    SERVER_WORLD="Dedicated" \
    SERVER_PASSWORD="p4ssw0rd" \
    SERVER_PUBLIC="1" \
    TZ="Etc/UTC" \
    SERVER_PATH="/server" \
    CONFIG_PATH="/config" \
    SCRIPTS_PATH="/scripts" \
    BACKUP_PATH="/backups" \
    DATA_PATH="/data" \
    LOG_PATH="/logs"

# hadolint ignore=DL3018,DL3008
RUN addgroup --gid 1001 container && useradd -u 1001 --gid 1001 -ms /bin/bash container  \
 && apt-get update && apt-get -y install --no-install-recommends \
    bash coreutils util-linux sed time tzdata python3 ca-certificates net-tools dnsutils nmap \
 && bash -c "mkdir -p {${SCRIPTS_PATH},${CONFIG_PATH},${SERVER_PATH},${BACKUP_PATH},${DATA_PATH},${LOG_PATH}}" \
 && chown 1001:1001 ${SCRIPTS_PATH} ${CONFIG_PATH} ${SERVER_PATH} ${BACKUP_PATH} ${DATA_PATH} ${LOG_PATH} \
 && rm -rf /var/lib/apt/lists/*

COPY --from=steam --chown=1001 /server /server
COPY --from=unix /scripts /srv

COPY --from=unix /scripts/valheim.sh /valheim
ENTRYPOINT ["/valheim"]

VOLUME ["/scripts", "/data", "/backups", "/logs"]
STOPSIGNAL SIGINT
CMD ["start"]
USER 1001

HEALTHCHECK CMD ["health"]
EXPOSE 2456-2457/udp
