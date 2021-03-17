# Download Modpack
# =================================================================================================
FROM alpine:3.13 as bepinex

# hadolint ignore=DL3018
RUN apk add --no-cache zip wget

ENV MOD_SOURCE="https://valheim.thunderstore.io/package/download/denikson/BepInExPack_Valheim/5.4.800" \
    MOD_ARHIVE="/bepinex.zip" \
    MOD_PATH="/modpack"

RUN wget -O "${MOD_ARHIVE}" "${MOD_SOURCE}"
RUN mkdir -p "${MOD_PATH}-raw" && unzip "${MOD_ARHIVE}" -d "${MOD_PATH}-raw" \
 && mkdir -p "${MOD_PATH}" && mv "${MOD_PATH}-raw/BepInExPack_Valheim/"* "${MOD_PATH}/"


# Install modpack on top of the Vanilla server
# =================================================================================================
FROM adaliszk/valheim-server:vanilla as server-modded
ENV SERVER_NAME="Valheim BepInEx v5.4.800" \
    MOD_PATH="/mod-bepinex" \
    MOD_VERSION="5.4.800"

COPY --from=bepinex /modpack "${MOD_PATH}"
RUN cp -rfa "${MOD_PATH}/." "${SERVER_PATH}/" && chown -R "1001:1001" "${SERVER_PATH}"


# Fix Unix permissions for the Windows peeps out there
# =================================================================================================
# hadolint ignore=DL3007
FROM adaliszk/dos2unix:latest as unix

COPY scripts /scripts
RUN dos2unix /scripts/** && chmod +x /scripts/**


# Set up the Runtime Environment
# =================================================================================================
FROM server-modded

COPY --from=unix /scripts/start.sh /scripts/start.sh
