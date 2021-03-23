# Download Modpack
# =================================================================================================
FROM alpine:3.13 as bepinex

# hadolint ignore=DL3018
RUN apk add --no-cache zip wget

# 1F31A`s BepInEx: https://valheim.thunderstore.io/package/1F31A/BepInEx_Valheim_Full
ENV MOD_SOURCE="https://valheim.thunderstore.io/package/download/1F31A/BepInEx_Valheim_Full/1.0.5" \
    MOD_ARHIVE="/bepinex.zip" \
    MOD_PATH="/modpack"

RUN wget -O "${MOD_ARHIVE}" "${MOD_SOURCE}"
RUN mkdir -p "${MOD_PATH}-raw" && unzip "${MOD_ARHIVE}" -d "${MOD_PATH}-raw" \
 && mkdir -p "${MOD_PATH}" && mv "${MOD_PATH}-raw/BepInEx_Valheim_Full/"* "${MOD_PATH}/" \
 && mkdir -p "${MOD_PATH}/BepInEx/plugins"


# Install modpack on top of the Vanilla server
# =================================================================================================
FROM adaliszk/valheim-server:0.148.6 as server-modded
ENV SERVER_NAME="Valheim v0.148.6 with BepInEx Full v1.0.5" \
    MOD_PATH="/mod-bepinex" \
    MOD_VERSION="1.0.5"

COPY --from=bepinex /modpack /mod-bepinex
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

COPY --from=unix /srv/init-bepinex.sh /srv/init-bepinex.sh
COPY --from=unix /scripts/start.sh /scripts/start.sh

VOLUME ["/plugins"]