# Download Modpack
# =================================================================================================
FROM alpine:3.13 as valheim-plus
ENV MOD_SOURCE="https://github.com/valheimPlus/ValheimPlus/releases/download/0.9.5.5/UnixServer.tar.gz" \
    MOD_ARHIVE="/valheim-plus.zip" \
    MOD_PATH="/modpack"

ADD ${MOD_SOURCE} ${MOD_ARHIVE}

RUN mkdir -p ${MOD_PATH} && tar -xvf "${MOD_ARHIVE}" -C ${MOD_PATH}


# Install modpack on top of the Vanilla server
# =================================================================================================
FROM adaliszk/valheim-server:bepinex as server-modded
ENV MOD_PATH="/mod-valheim+" \
    MOD_VERSION="0.9.5.5"

COPY --from=valheim-plus /modpack ${MOD_PATH}
RUN cp -rfa "${MOD_PATH}/." "${SERVER_PATH}/" && chown -R "1001:1001" ${SERVER_PATH}
