#!/bin/bash

log-stdout "init-user> Initialize user:group..."
export USER="container"

if [[ -n "${PGID}" ]] && ! grep -q "pgroup:" /etc/group;
  then
    log-stdout "init-user> PGID specified, creating group..."
    addgroup --gid "${PGID}" pgroup
    addgroup container pgroup
  fi

if [[ -n "${PUID}" ]];
  then
    log-stdout "init-user> PUID specified..."
    export USER="puser"

    if ! grep -q "puser:" /etc/passwd;
      then
        log-stdout "init-user> Creating PUID user..."
        adduser --uid "${PUID}" --shell /bin/bash --home /data -G pgroup -S puser
      fi
  fi

