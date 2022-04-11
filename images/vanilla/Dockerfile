
# Install Vanilla Server
# =================================================================================================
FROM steamcmd/steamcmd:ubuntu as steam
ENV APP_ID="896660" \
    APP_VERSION="0.208.1" \
    APP_BUILD="8449481" \
    APP_PATH="/server"

# hadolint ignore=DL3018,DL3008
RUN apt-get -y install --no-install-recommends bash tar

# Workaround for https://github.com/ValveSoftware/steam-for-linux/issues/7843
# creating a steamapps folder for the install dir
RUN mkdir -p "${APP_PATH}/steamapps"

# Install the server
RUN steamcmd +force_install_dir "${APP_PATH}" +login anonymous +app_update ${APP_ID} +quit

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
# hadolint ignore=DL3007
FROM adaliszk/alpine:3.15 as runtime

ARG REF=""
ARG TIMESTAMP=""
ARG VERSION=""

# Apply OCI Annotations
LABEL \
  org.opencontainers.image.created="${TIMESTAMP}" \
  org.opencontainers.image.title="Valheim Server OCI" \
  org.opencontainers.image.description="Secure Kubernetes-ready Valheim Server with Mod support, Automatic backups, Alpine." \
  org.opencontainers.image.authors="Ádám Liszkai <valheim-server@adaliszk.dev>" \
  org.opencontainers.image.license="MIT" \
  org.opencontainers.image.url="https://adaliszk.github.io/valheim-server" \
  org.opencontainers.image.documentation="https://adaliszk.github.io/valheim-server" \
  org.opencontainers.image.source="https://github.com/adaliszk/valheim-server" \
  org.opencontainers.image.version="${VERSION}" \
  org.opencontainers.image.revision="${REF}" \
  org.opencontainers.image.vendor="AdaLiszk"


# Install glibc dependency (sadly needed as a barebone musl libc cannot be used)
ARG GLIBC_VERSION="2.34-r0"

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
      'bash>=5.1.16-r0' \
      'coreutils>=9.0-r2' \
      'tzdata>=2021e-r0' \
      'python3>=3.9.7-r4' \
 # Install edge packages for up-to-date security
 && apk --no-cache --repository="https://dl-cdn.alpinelinux.org/alpine/edge/main" \
    add \
      'musl>=1.2.2-r7' \
      'ca-certificates>=20211220-r0' \
      'openssl>=1.1.1m-r2' \
 && apk --no-cache --repository="https://dl-cdn.alpinelinux.org/alpine/edge/community" \
    add \
      'sdl2>=2.0.20-r1'

COPY --from=steam --chown=1001 /server /server

ENV \
 SERVER_NAME="Valheim v0.208.1" \
 SERVER_WORLD="Dedicated" \
 SERVER_PASSWORD="p4ssw0rd" \
 SERVER_PUBLIC="1" \
 SERVER_ADMINS="" \
 SERVER_PERMITTED="" \
 SERVER_BANNED="" \
 LEGACY_BACKUP_SYSTEM="true" \
 BACKUP_RETENTION="6" \
 LOG_LEVEL="info" \
 TZ="Etc/UTC"

RUN bash -c "mkdir -p /{scripts,config,server,backup,data,logs,status}" \
 && chown 1001:1001 /scripts /config /server /backup /data /logs /status

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
