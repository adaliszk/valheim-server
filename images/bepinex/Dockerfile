# Download Modpack
# =================================================================================================
FROM alpine:3.14.2 as bepinex

# hadolint ignore=DL3018
RUN apk add --no-cache zip wget

# denkinson's BepInEx: https://valheim.thunderstore.io/package/denikson/BepInExPack_Valheim/
ENV MOD_SOURCE="https://valheim.thunderstore.io/package/download/denikson/BepInExPack_Valheim/5.4.1900" \
    MOD_ARHIVE="/bepinex.zip" \
    MOD_PATH="/modpack"

RUN wget -O "${MOD_ARHIVE}" "${MOD_SOURCE}" \
 && mkdir -p "${MOD_PATH}-raw" && unzip "${MOD_ARHIVE}" -d "${MOD_PATH}-raw" \
 && mkdir -p "${MOD_PATH}" && mv "${MOD_PATH}-raw/BepInExPack_Valheim/"* "${MOD_PATH}/"


# Install modpack on top of the Vanilla server
# =================================================================================================
FROM adaliszk/valheim-server:0.207.20 as server-modded
ENV SERVER_NAME="Valheim v0.207.20 with BepInEx v5.4.1900" \
    MOD_PATH="/mod-bepinex" \
    MOD_VERSION="5.4.1900"

COPY --from=bepinex /modpack "${MOD_PATH}"
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