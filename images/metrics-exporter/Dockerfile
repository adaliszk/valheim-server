# Download MTail Binary
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
FROM alpine:3.13 as binary

# hadolint ignore=DL3018
RUN apk add --no-cache wget ca-certificates bash && update-ca-certificates

ENV MTAIL_ARCHIVE="/tmp/mtail.tar.gz" \
    MTAIL_BIN="/go/bin/mtail" \
    GIT_REPO="https://github.com/google/mtail" \
    GIT_RELEASE="3.0.0-rc44" \
    GIT_ARCH="Linux_x86_64"

WORKDIR /binary
RUN export DL_NAME="mtail_${GIT_RELEASE}_${GIT_ARCH}.tar.gz" && mkdir -p /go/bin \
 && wget "${GIT_REPO}/releases/download/v${GIT_RELEASE}/${DL_NAME}" -O /binary/${DL_NAME} \
 && tar -xvf /binary/${DL_NAME} -C /go/bin && chmod +x ${MTAIL_BIN}

# Compile MTail Binary
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#FROM golang:1.14-alpine as binary
#RUN apk add --no-cache git make imagemagick file
#ENV GIT_REPO="https://github.com/google/mtail" \
#    GIT_TAG="v3.0.0-rc38"
#
#RUN git clone --depth 1 --branch ${GIT_TAG} ${GIT_REPO} /compile
#WORKDIR /compile
#
#RUN make depclean && make install_deps \
# && PREFIX=/go make STATIC=y -B install

# Fix Unix permissions for the Windows peeps out there
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# hadolint ignore=DL3007
FROM adaliszk/dos2unix:latest as unix

COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY programs /mtail-programs
RUN dos2unix docker-entrypoint.sh && chmod +x /docker-entrypoint.sh \
 && dos2unix /mtail-programs/** && chmod +x /mtail-programs/**

# Execute Mtail
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
FROM alpine:3.13 as runtime

# hadolint ignore=DL3018
RUN apk add --no-cache bash

COPY --from=binary /go/bin/mtail /usr/bin/mtail
COPY --from=unix /mtail-programs /etc/mtail
WORKDIR /tmp

COPY --from=unix /docker-entrypoint.sh /mtail
ENTRYPOINT ["/mtail"]
EXPOSE 3903