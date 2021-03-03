# Install Vanilla Server
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
FROM adaliszk/valheim-server:env as server-vanilla
ENV SERVER_VERSION="0.147.3@v2" \
    SERVER_BUILD_VERSION="6315977@v2" \
    SERVER_PATH="/home/steam/valheim-server" \
    SERVER_DATA_PATH="/home/steam/.config/unity3d/IronGate/Valheim" \
    LOG_PATH="/tmp/valheim"

RUN /sbin/steamcmd +login anonymous +force_install_dir "${SERVER_PATH}" +app_update 896660 +quit \
 && mkdir -p ${SERVER_DATA_PATH}  && chown -R "${UID}:${GID}" "${SERVER_PATH}" \
 && rm -f "${SERVER_PATH}/*.sh" && rm -f "${SERVER_PATH}/*.pdf" \
 && echo "Files in ${SERVER_PATH}" && ls -la "${SERVER_PATH}"


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
FROM server-vanilla as server
ENV DEFAULT_SERVER_NAME="Valheim" \
    DEFAULT_SERVER_MOTD="Valheim v${SERVER_VERSION}" \
    DEFAULT_SERVER_WORLD="Dedicated" \
    DEFAULT_SERVER_PASSWORD="p4ssw0rd"

COPY --from=unix /srv-scripts /srv
COPY --from=unix /sbin-scripts/docker-entrypoint.sh /sbin/docker-entrypoint
COPY --from=unix /sbin-scripts/valheim-console.py /sbin/valheim-console
ENTRYPOINT ["/sbin/docker-entrypoint"]

COPY --from=unix --chown=1001 /server-scripts /home/steam/scripts

#USER 1001
HEALTHCHECK CMD ["health"]
STOPSIGNAL SIGTERM
EXPOSE 2456-2458/udp
CMD ["start"]
