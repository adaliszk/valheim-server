# Download Modpack
# =================================================================================================
FROM alpine:3.14.2 as valheim-plus

# hadolint ignore=DL3018
RUN apk add --no-cache wget

ENV MOD_SOURCE="https://github.com/valheimPlus/ValheimPlus/releases/download/0.9.9.8/UnixServer.tar.gz" \
    MOD_ARHIVE="/valheim-plus.zip" \
    MOD_PATH="/modpack"

RUN wget -O "${MOD_ARHIVE}" "${MOD_SOURCE}"
RUN mkdir -p "${MOD_PATH}" && tar -xvf "${MOD_ARHIVE}" -C "${MOD_PATH}"


# Install modpack on top of the Vanilla server
# =================================================================================================
FROM adaliszk/valheim-server:0.207.20 as server-modded
ENV SERVER_NAME="Valheim 0.207.20 with Plus v0.9.9.8" \
    MOD_PATH="/valheim+" \
    MOD_VERSION="0.9.9.8"

COPY --from=valheim-plus /modpack "${MOD_PATH}"

RUN cp -rfa "${MOD_PATH}/." /server/ && chown -R "1001:1001" /server


# Fix Unix permissions for the Windows peeps out there
# =================================================================================================
# hadolint ignore=DL3007
FROM adaliszk/dos2unix:latest as unix

COPY scripts /scripts
RUN dos2unix /scripts/** && chmod +x /scripts/**

COPY srv /srv
RUN dos2unix /srv/** && chmod +x /srv/**


# Set up the Runtime Environment
# =================================================================================================
FROM server-modded
ENV PLUGINS_PATH="/plugins"

COPY --from=unix /srv/init-valheim-plus.sh /srv/init-valheim-plus.sh
COPY --from=unix /scripts/start.sh /scripts/start.sh

VOLUME ["/plugins"]
