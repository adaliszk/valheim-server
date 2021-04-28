# Download MTail Binary
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
FROM adaliszk/alpine:3.13 as binary

# hadolint ignore=DL3018
RUN apk add --no-cache wget ca-certificates bash && update-ca-certificates

ENV MTAIL_BIN="/go/bin/mtail" \
    REPO="https://github.com/google/mtail" \
    RELEASE="3.0.0-rc45" \
    ARCH="Linux_x86_64"

WORKDIR /binary
RUN export FILE="mtail_${RELEASE}_${ARCH}.tar.gz" && mkdir -p /go/bin \
 && wget "${REPO}/releases/download/v${RELEASE}/${FILE}" -O /binary/${FILE} \
 && tar -xvf /binary/${FILE} -C /go/bin && chmod +x ${MTAIL_BIN}

# Execute Mtail
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
FROM adaliszk/alpine:3.13 as runtime

# hadolint ignore=DL3018
RUN apk add --no-cache bash

COPY --from=binary /go/bin/mtail /usr/bin/mtail
COPY ./programs /etc/mtail
WORKDIR /tmp

COPY ./srv/entrypoint.sh /mtail
ENTRYPOINT ["/mtail"]
EXPOSE 3903