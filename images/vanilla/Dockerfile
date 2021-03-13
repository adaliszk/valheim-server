
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
FROM adaliszk/valheim-server:dos2unix as unix

COPY scripts /scripts
COPY srv /srv
RUN dos2unix /scripts/** && chmod +x /scripts/** \
 && dos2unix /srv/** && chmod +x /srv/**


# Set up the Runtime Environment
# =================================================================================================
FROM frolvlad/alpine-glibc:alpine-3.13 as runtime
ENV SERVER_NAME="Valheim v0.147.3" \
    SERVER_WORLD="Dedicated" \
    SERVER_PASSWORD="p4ssw0rd" \
    SERVER_PUBLIC="1" \
    TZ="Etc/UTC"

# hadolint ignore=DL3018,DL3008
RUN addgroup --gid 1001 container && adduser --uid 1001 --shell /bin/bash -G container -S container \
 # @TODO: remove Python3 dependency via building the VhPretty as a binary
 && apk add --no-cache bash coreutils findutils multitail tzdata python3 net-tools sdl2 ca-certificates \
 && bash -c "mkdir -p /{scripts,config,server,backups,data,logs}" \
 && chown 1001:1001 /scripts /config /server /backups /data /logs

COPY --from=steam --chown=1001 /server /server
COPY --from=unix --chown=1001 /scripts /scripts
COPY --from=unix --chown=1001 /srv /srv

COPY --from=unix --chown=1001 /srv/valheim.sh /valheim
ENTRYPOINT ["/valheim"]

VOLUME ["/data", "/backups", "/logs"]
STOPSIGNAL SIGINT
CMD ["start"]

HEALTHCHECK CMD ["health"]
EXPOSE 2456-2457/udp
