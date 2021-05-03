FROM adaliszk/alpine:3.13

ENV \
  CLCACHE_DIR="/cache"

RUN apk --no-cache add python3 py3-pip \
 && pip install pipenv

COPY ./Pipfile /Pipfile
COPY ./dist /dist
COPY ./source /source
WORKDIR /

RUN pipenv install --dev \
 && apk --no-cache add -t .build-deps python3-dev py3-pip gcc musl-dev ccache fuse-dev \
 && pipenv run build \
 && apk del .build-deps \
 && rm -rf /root/.local

USER 1001
