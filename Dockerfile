ARG SERVER_IMAGE="valheim-server"

#
# Install Valheim Server using SteamCMD
#
FROM steamcmd/steamcmd:alpine as steam

ARG APP_ID="896660"
ARG STEAMCMD_EXTRAS=""
ARG APP_VERSION=""
ARG APP_BUILD=""

# Install the server using SteamCMD
RUN steamcmd +force_install_dir /server +login anonymous +app_update ${APP_ID} ${STEAMCMD_EXTRAS} +quit \
 && echo "${APP_VERSION}@${APP_BUILD}" > /server/valheim_server_Data/version \
 && rm -rf /server/*.sh /server/*.pdf


#
# Compress server files for a smaller download size
# This adds ~5-20s decompression time for fresh and updated server starts,
# overall saves about 750MB of image size for faster pull times
#
FROM alpine:3.17 as serverfiles
RUN apk add --no-cache tar>=1.34-r1

COPY --from=steam /server /server
RUN tar -czf /server/valheim_server_Data.tar.gz -C /server valheim_server_Data \
 && rm -rf /server/valheim_server_Data


#
# Download BepInEx from Thunderstore
#
FROM alpine:3.17 as bepinex
RUN apk add --no-cache zip>=3.0-r10

ARG BEPINEX_VERSION="5.4.1901"

# denkinson's BepInEx: https://valheim.thunderstore.io/package/denikson/BepInExPack_Valheim/
ADD https://valheim.thunderstore.io/package/download/denikson/BepInExPack_Valheim/${BEPINEX_VERSION} /tmp/bepinex.zip
RUN mkdir -p /tmp/bepinex && unzip /tmp/bepinex.zip -d /tmp/bepinex \
 && mkdir -p /bepinex && mv /tmp/bepinex/BepInExPack_Valheim/* /bepinex


#
# Set up the Runtime Environment
#
FROM alpine:3.17 as valheim-server

ARG GLIBC_MIRROR="https://github.com/sgerrand/alpine-pkg-glibc/releases/download"
ARG GLIBC_KEYFILE="https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub"
ARG GLIBC_VERSION="2.34-r0"

RUN wget -q -O /etc/apk/keys/glibc.rsa.pub ${GLIBC_KEYFILE} \
 && wget ${GLIBC_MIRROR}/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk  \
 && apk --no-cache add --force-overwrite glibc-${GLIBC_VERSION}.apk \
 && wget ${GLIBC_MIRROR}/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk  \
 && apk --no-cache add --force-overwrite glibc-bin-${GLIBC_VERSION}.apk \
 && rm -f glibc*.apk /etc/apk/keys/glibc.rsa.pub \
 && apk fix --force-overwrite alpine-baselayout-data>=3.2.0-r23 \
 && apk del libc-utils

# Separate runtime depenency cache layer as this is bumped automatically
RUN apk --no-cache add \
    tzdata>=2022f-r1 \
    binutils>=2.39-r2 \
    tar>=1.34-r1 \
    bash>=5.2.9-r0 \
    sed>=4.9-r0 \
    rsync>=3.2.7-r0 \
    ca-certificates>=20220614-r2 \
    openssl>=3.0.7-r0 \
    musl>=1.2.3-r4

SHELL ["bash", "-c"]

COPY --from=steam "/etc/ssl/certs" /etc/ssl/certs
COPY --from=serverfiles --chown=1001 /server /server
WORKDIR /server

ARG APP_VERSION=""
ARG APP_BUILD=""
ENV APP_VERSION="${APP_VERSION}" \
    APP_BUILD="${APP_BUILD}" \
    LANG="en_UK.UTF-8" \
    TZ="Etc/UTC"

COPY ./scripts /scripts
WORKDIR /server

RUN mkdir -p /{scripts,config,server,data,logs} /tmp/valheim-server /tmp/.config/unity3d/IronGate \
 && chown 1001:1001 /scripts /config /server /data /logs /tmp/valheim-server \
 && ln -s /scripts/entrypoint.sh /valheim

VOLUME ["/data", "/logs"]

ENTRYPOINT ["/valheim"]
HEALTHCHECK --start-period=30s --interval=30s --timeout=5s CMD ["/scripts/healthcheck.sh"]
STOPSIGNAL SIGTERM
EXPOSE 2456-2457/udp

ARG REF=""
ARG TIMESTAMP=""
ARG VERSION=""
LABEL org.opencontainers.image.created="${TIMESTAMP}" \
      org.opencontainers.image.title="Valheim Server OCI" \
      org.opencontainers.image.description="Secure Kubernetes-ready Valheim Server" \
      org.opencontainers.image.authors="Ádám Liszkai <valheim-server@adaliszk.dev>" \
      org.opencontainers.image.license="BSD 2-Clause" \
      org.opencontainers.image.url="https://adaliszk.github.io/valheim-server" \
      org.opencontainers.image.documentation="https://adaliszk.github.io/valheim-server" \
      org.opencontainers.image.source="https://github.com/adaliszk/valheim-server" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.revision="${REF}" \
      org.opencontainers.image.vendor="AdaLiszk"


#
# Installing BepInEx for modding
#
#
FROM ${SERVER_IMAGE} as server-modded
ENV SERVER_NAME="Valheim v0.207.20 with BepInEx v5.4.1900" \
    MOD_PATH="/mod-bepinex" \
    MOD_VERSION="5.4.1900"

COPY --from=bepinex /modpack "${MOD_PATH}"
RUN cp -rfa "${MOD_PATH}/." /server/ && chown -R "1001:1001" /server

#
# Secure the image with a non-root user
#
FROM ${SERVER_IMAGE} as secure-runtime
USER 1001
