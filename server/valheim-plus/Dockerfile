# Download Modpack
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
FROM alpine:latest as valheim-plus
ENV MOD_SOURCE="https://github.com/valheimPlus/ValheimPlus/releases/download/0.9/UnixServer.tar.gz" \
    MOD_PATH="/valheim-plus.tar.gz"

ADD ${MOD_SOURCE} ${MOD_PATH}
RUN mkdir -p "/modpack" && tar -xvf ${MOD_PATH} -C "/modpack"


# Install modpack on top of the Vanilla server
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
FROM adaliszk/valheim-server:latest as server-modded
ENV MOD_CONFIG_PATH="${SERVER_PATH}/BepInEx/config" \
    MOD_PATH="/home/steam/valheim-plus" \
    MOD_VERSION="0.9"

COPY --from=valheim-plus /modpack ${MOD_PATH}
RUN cp -rfa "${MOD_PATH}/." "${SERVER_PATH}/" && chown -R "1001:1001" ${SERVER_PATH} \
 && ls -la ${SERVER_PATH}


# Fix Unix permissions for the Windows peeps out there
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
FROM adaliszk/valheim-server:dos2unix as unix

COPY sbin /sbin-scripts
COPY server /server-scripts
COPY srv /srv-scripts

RUN dos2unix /server-scripts/** && chmod +x /server-scripts/** \
 && dos2unix /sbin-scripts/** && chmod +x /sbin-scripts/** \
 && dos2unix /srv-scripts/** && chmod +x /srv-scripts/**


# Set up the Runtime Environment
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
FROM server-modded as server
ENV SERVER_VERSION="0.147.3@v2" \
    SERVER_BUILD_VERSION="6315977@v2" \
    DEFAULT_SERVER_NAME="Valheim Plus" \
    DEFAULT_SERVER_MOTD="Valheim Plus v${MOD_VERSION}" \
    DEFAULT_SERVER_WORLD="Dedicated" \
    DEFAULT_SERVER_PASSWORD=""

COPY --from=unix /srv-scripts/env-valheim-plus.sh /srv/env-valheim-plus.sh
COPY --from=unix /sbin-scripts/docker-entrypoint.sh /sbin/docker-entrypoint
ENTRYPOINT ["/sbin/docker-entrypoint"]

#USER 1001
COPY --from=unix /server-scripts/start.sh /home/steam/scripts/start.sh
HEALTHCHECK CMD ["health"]
STOPSIGNAL SIGTERM
EXPOSE 2456-2458/udp
CMD ["start"]
