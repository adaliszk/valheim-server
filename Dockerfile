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
# Set up the Runtime Environment
#
FROM alpine:3.17 as valheim-server

# Glibc installation as a separate cache layer given that Unity projects require it
ARG GLIBC_VERSION="2.34-r0"
ARG GLIBC_MIRROR="https://github.com/sgerrand/alpine-pkg-glibc/releases/download"
ARG GLIBC_KEY_MIRROR="https://alpine-pkgs.sgerrand.com"
ARG GLIBC_KEY_FILE="sgerrand.rsa.pub"
RUN wget -q -O /etc/apk/keys/${GLIBC_KEY_FILE} ${GLIBC_KEY_MIRROR}/${GLIBC_KEY_FILE} \
 && wget -q ${GLIBC_MIRROR}/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk  \
 && apk --no-cache add --force-overwrite glibc-${GLIBC_VERSION}.apk \
 && wget -q ${GLIBC_MIRROR}/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk  \
 && apk --no-cache add --force-overwrite glibc-bin-${GLIBC_VERSION}.apk \
 && rm -f glibc*.apk /etc/apk/keys/${GLIBC_KEY_FILE} \
 && ln -s /usr/glibc-compat/lib /usr/glibc-compat/lib64

## Runtime depenency cache layer as this is bumped automatically
RUN apk --no-cache --repository="https://dl-cdn.alpinelinux.org/alpine/3.17/main" \
    add  \
       tzdata>=2022f-r1 \
       binutils>=2.39-r2 \
       procps>=3.3.17-r2 \
       tar>=1.34-r1 \
       bash>=5.2.9-r0 \
       grep>=3.8-r1 \
       sed>=4.9-r0 \
       bind-tools>=9.18.9-r0 \
       inotify-tools>=3.22.6.0-r0 \
       rsync>=3.2.7-r0 \
       libatomic>=12.2.1_git20220924-r4 \
       musl-dev>=1.2.3-r4 \
       musl>=1.2.3-r4 \
 && apk --no-cache --repository="https://dl-cdn.alpinelinux.org/alpine/3.17/community" \
    add \
       libpulse>=16.1-r6 \
       sdl2>=2.26.1-r0

SHELL ["bash", "-c"]

COPY --from=steam "/etc/ssl/certs" /etc/ssl/certs
COPY --from=serverfiles --chown=1001 /server /server

WORKDIR /server

ARG APP_ID="896660"
ARG APP_VERSION=""
ARG APP_BUILD=""
ENV APP_ID="${APP_ID}" \
    APP_VERSION="${APP_VERSION}" \
    APP_BUILD="${APP_BUILD}" \
    LANG="en_UK.UTF-8" \
    TZ="Etc/UTC"

COPY ./scripts /scripts
WORKDIR /server

RUN mkdir -p /{scripts,server,data} /tmp/valheim-server /.config \
 && chown -R 1001:1001 /scripts /server /data /tmp/valheim-server /.config \
 && ln -s /scripts/healthcheck.sh /usr/local/bin/healthcheck \
 && ln -s /scripts/entrypoint.sh /usr/local/bin/valheim-server

ENTRYPOINT ["valheim-server"]
HEALTHCHECK --start-period=30s --interval=30s --timeout=5s CMD ["healthcheck"]
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
# Secure the image with a non-root user
#
FROM ${SERVER_IMAGE} as secure-valheim-server
USER 1001
