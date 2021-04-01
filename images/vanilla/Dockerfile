
# Install Vanilla Server
# =================================================================================================
FROM steamcmd/steamcmd:ubuntu as steam
ENV APP_ID="896660" \
    APP_VERSION="0.148.7" \
    APP_BUILD="6394774" \
    APP_PATH="/server"

# hadolint ignore=DL3018,DL3008
RUN apt-get -y install --no-install-recommends bash tar
RUN steamcmd +login anonymous +force_install_dir "${APP_PATH}" +app_update ${APP_ID} validate +quit
# Compress files so the image can be small for the price of ~5-10s decompression on runtime
RUN tar -czf "${APP_PATH}/valheim_server_Data.tar.gz" -C "${APP_PATH}" "valheim_server_Data" \
 && rm -rf "${APP_PATH}/valheim_server_Data"


# Fix file format and permissions for the Windows peeps out there
# =================================================================================================
# hadolint ignore=DL3007
FROM adaliszk/dos2unix:latest as unix

COPY scripts /scripts
RUN dos2unix /scripts/** && chmod +x /scripts/**

COPY srv /srv
RUN dos2unix /srv/** && chmod +x /srv/**


# Set up the Runtime Environment
# =================================================================================================
FROM alpine:3.13 as runtime

# Create a user for the container
RUN addgroup --gid 1001 container && adduser --uid 1001 --shell /bin/bash -G container -S container

COPY --from=steam --chown=1001 /server /server

ARG GLIBC_VERSION="2.33-r0"

# Install glibc dependency (sadly needed as a barebone musl libc cannot be used)
# hadolint ignore=DL3018
RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
 && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk \
 && apk --no-cache \
   add \
     glibc-${GLIBC_VERSION}.apk \
 && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk \
 && apk --no-cache \
   add \
     glibc-bin-${GLIBC_VERSION}.apk \
 && rm glibc*.apk /etc/apk/keys/sgerrand.rsa.pub \
 && apk del libc-utils

# Install runtime dependendencies
# @TODO: remove Python3 dependency via building the VhPretty as a Python/Go binary
RUN apk --no-cache \
    add \
      bash=5.1.0-r0 \
      coreutils=8.32-r2 \
      multitail=6.5.0-r0 \
      tzdata=2021a-r0 \
      python3=3.8.8-r0 \
 # Install edge versions for up-to-date security
 && apk --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/main \
    add \
      musl=1.2.2-r2 \
      sdl2=2.0.14-r0 \
      ca-certificates=20191127-r5 \
      openssl=1.1.1k-r0

ENV \
 SERVER_NAME="Valheim v0.148.7" \
 SERVER_WORLD="Dedicated" \
 SERVER_PASSWORD="p4ssw0rd" \
 SERVER_PUBLIC="1" \
 SERVER_ADMINS="" \
 SERVER_PERMITTED="" \
 SERVER_BANNED="" \
 BACKUP_RETENTION="6" \
 TZ="Etc/UTC"

RUN bash -c "mkdir -p /{scripts,config,server,backup,data,logs}" \
 && chown 1001:1001 /scripts /config /server /backup /data /logs

COPY --from=unix /scripts /scripts
COPY --from=unix /srv /srv

COPY --from=unix /srv/valheim.sh /valheim
ENTRYPOINT ["/valheim"]

VOLUME ["/data", "/backups", "/logs"]
STOPSIGNAL SIGINT
CMD ["start"]
USER 1001

HEALTHCHECK --start-period=30s --timeout=5s CMD ["/scripts/health.sh"]
EXPOSE 2456-2457/udp
