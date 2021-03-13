#!/bin/bash

log-stdout "Initialize user:group..."

export USER="container"

id -g pgroup &>/dev/null
GROUP_EXIST=$?

if [[ -n "${PGID}" ]] && [[ "${GROUP_EXIST}" == "1" ]];
  then
    log-stdout "PGID specified, creating group..."
    addgroup --gid "${PGID}" pgroup
    addgroup container pgroup
  fi

id -u puser &>/dev/null
USER_EXIST=$?

if [[ -n "${PUID}" ]] && [[ "${USER_EXIST}" == "1" ]];
  then
    log-stdout "PUID specified, creating user..."
    adduser --uid "${PUID}" --shell /bin/bash -G pgroup -S puser
    export USER="puser"
  fi

