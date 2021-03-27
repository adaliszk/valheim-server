
# Install Vanilla Server
# =================================================================================================
FROM steamcmd/steamcmd:ubuntu as steam
ENV APP_ID="896660" \
    APP_VERSION="0.148.6" \
    APP_BUILD="6394774" \
    APP_PATH="/server"

# hadolint ignore=DL3018,DL3008
RUN apt-get -y install --no-install-recommends bash tar
RUN steamcmd +login anonymous +force_install_dir "${APP_PATH}" +app_update ${APP_ID} validate +quit
# Compress files so the image can be small for the price of ~5-10s decompression on runtime
RUN tar -czf "${APP_PATH}/valheim_server_Data.tar.gz" -C "${APP_PATH}" "valheim_server_Data" \
 && rm -rf "${APP_PATH}/valheim_server_Data"


# Fix file format and permissions for the Windows peeps out there
# =================================================================================================
# hadolint ignore=DL3007
FROM adaliszk/dos2unix:latest as unix

COPY scripts /scripts
RUN dos2unix /scripts/** && chmod +x /scripts/**

COPY srv /srv
RUN dos2unix /srv/** && chmod +x /srv/**


# Set up the Runtime Environment
# =================================================================================================
FROM frolvlad/alpine-glibc:alpine-3.13 as runtime
ENV SERVER_NAME="Valheim v0.148.6" \
    SERVER_WORLD="Dedicated" \
    SERVER_PASSWORD="p4ssw0rd" \
    SERVER_PUBLIC="1" \
    SERVER_ADMINS="" \
    SERVER_PERMITTED="" \
    SERVER_BANNED="" \
    BACKUP_RETENTION="6" \
    TZ="Etc/UTC"

COPY --from=steam --chown=1001 /server /server

# hadolint ignore=DL3018,DL3008
RUN addgroup --gid 1001 container && adduser --uid 1001 --shell /bin/bash -G container -S container \
 # @TODO: remove Python3 dependency via building the VhPretty as a binary
 && apk add --no-cache coreutils bash multitail tzdata python3 net-tools sdl2 ca-certificates \
 && bash -c "mkdir -p /{scripts,config,server,backup,data,logs}" \
 && chown 1001:1001 /scripts /config /server /backup /data /logs

COPY --from=unix /scripts /scripts
COPY --from=unix /srv /srv

COPY --from=unix /srv/valheim.sh /valheim
ENTRYPOINT ["/valheim"]

VOLUME ["/data", "/backups", "/logs"]
STOPSIGNAL SIGINT
CMD ["start"]
USER 1001

HEALTHCHECK --start-period=30s --timeout=5s CMD ["/scripts/health.sh"]
EXPOSE 2456-2457/udp
