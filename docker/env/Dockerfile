# Fix Unix permissions for the Windows peeps out there
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
FROM adaliszk/valheim-server:dos2unix as unix

COPY steamcmd.sh /sbin-scripts/steamcmd
RUN dos2unix /sbin-scripts/** && chmod +x /sbin-scripts/**


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
FROM cm2network/steamcmd:root as environment
ENV UID="1001" GID="1001" HOME="/home/steam"

RUN apt-get update && apt-get -y install --no-install-recommends lib32gcc1 net-tools mtail bash libc6-dev python3 \
# && groupadd -g "${GID}" -r steam && useradd -u ${UID} -r -g ${GID} -s /bin/bash -m -d /home/steam steam \
 && rm -rf /var/lib/apt/lists/*

COPY --from=unix /sbin-scripts/steamcmd /sbin/steamcmd