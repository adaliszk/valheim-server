# Download Modpack
# =================================================================================================
FROM alpine:3.13 as valheim-plus

# hadolint ignore=DL3018
RUN apk add --no-cache wget

ENV MOD_SOURCE="https://github.com/valheimPlus/ValheimPlus/releases/download/0.9.5.5/UnixServer.tar.gz" \
    MOD_ARHIVE="/valheim-plus.zip" \
    MOD_PATH="/modpack"

RUN wget -O "${MOD_ARHIVE}" "${MOD_SOURCE}"
RUN mkdir -p "${MOD_PATH}" && tar -xvf "${MOD_ARHIVE}" -C "${MOD_PATH}"


# Install modpack on top of the Vanilla server
# =================================================================================================
FROM adaliszk/valheim-server:vanilla as server-modded
ENV SERVER_NAME="Valheim Plus v0.9.5.5" \
    MOD_PATH="/mod-valheim+" \
    MOD_VERSION="0.9.5.5"

COPY --from=valheim-plus /modpack "${MOD_PATH}"

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