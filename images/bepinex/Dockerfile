# Download Modpack
# =================================================================================================
FROM alpine:3.13 as bepinex
RUN apk add --no-cache zip

ENV MOD_SOURCE="https://valheim.thunderstore.io/package/download/denikson/BepInExPack_Valheim/5.4.800" \
    MOD_ARHIVE="/bepinex.zip"

ADD ${MOD_SOURCE} ${MOD_ARHIVE}

RUN mkdir -p /modpack-raw && unzip "${MOD_ARHIVE}" -d /modpack-raw \
 && mkdir -p /modpack && mv /modpack-raw/BepInExPack_Valheim/* /modpack/


# Install modpack on top of the Vanilla server
# =================================================================================================
FROM adaliszk/valheim-server:vanilla as server-modded
ENV MOD_PATH="/mod-bepinex" \
    MOD_VERSION="5.4.800"

COPY --from=bepinex /modpack ${MOD_PATH}
RUN cp -rfa "${MOD_PATH}/." "${SERVER_PATH}/" && chown -R "1001:1001" ${SERVER_PATH}


# Fix Unix permissions for the Windows peeps out there
# =================================================================================================
FROM adaliszk/dos2unix:latest as unix
COPY scripts /scripts
RUN dos2unix /scripts/** && chmod +x /scripts/**


# Set up the Runtime Environment
# =================================================================================================
FROM server-modded
COPY --from=unix /scripts/start.sh /scripts/start.sh

