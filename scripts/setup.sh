#!/usr/bin/env bash
# Copyright © 2022 by Ádám Liszkai using BSD 2-Clause License
# https://source.adaliszk.io/valheim-server/license

export SERVER_NAME="${SERVER_NAME:-Valheim ${APP_VERSION} Server}"
export SERVER_WORLD="${SERVER_WORLD:-Dedicated}"
export SERVER_PASSWORD="${SERVER_PASSWORD:-p4ssw0rd}"
export SERVER_PUBLIC="${SERVER_PUBLIC:-true}"

export SERVER_PORT="${SERVER_PORT:-2456}"
export SERVER_CROSSPLAY="${SERVER_CROSSPLAY:-false}"

export SAVE_INTERVAL="${SAVE_INTERVAL:-1800}"

export BACKUP_RETENTION="${BACKUP_RETENTION:-5}"
export BACKUP_FIRST_INTERVAL="${BACKUP_FIRST_INTERVAL:-7200}"
export BACKUP_CYCLE_INTERVAL="${BACKUP_CYCLE_INTERVAL:-43200}"

export ADMIN_LIST="${ADMIN_LIST}"
export PERMITTED_LIST="${PERMITTED_LIST}"
export BANNED_LIST="${BANNED_LIST}"

#
# INITIALIZE DATA AND WORKDIR VOLUME
#
#

mkdir -p /tmp/valheim-server/worlds_local
mkdir -p /data/backups
mkdir -p /data/worlds_local

#
# INITIALIZE STATE AND CONFIGS
# Since we use an in-memory workdir, we need to copy the previous state back to the memory
#

if [[ "$(ls -A /data 2>/dev/null)" ]]; then
  echo "Load server files from /data" | capture-output StateInit
  cp -rf /data/worlds_local/ /tmp/valheim-server/worlds_local
fi

if [ "$(ls -A /config/*.txt 2>/dev/null)" ]; then
  echo "Initialize config files from /config" | capture-output ConfigInit
  for config in /config/*txt; do
    filename=$(basename "${config}")
    echo "Copy ${config} into /tmp/valheim-server/${filename}" | capture-output ConfigInit DEBUG
    rm -rf "/tmp/valheim-server/${filename}"
    cat "${config}" >"/tmp/valheim-server/${filename}"
  done
else
  echo "Initializing access lists from pre-existing configuration" | capture-output ConfigInit
  list-to-file "${SERVER_ADMINS}" "adminlist.txt" ConfigInit
  list-to-file "${SERVER_PERMITTED}" "permittedlist.txt" ConfigInit
  list-to-file "${SERVER_BANNED}" "bannedlist.txt" ConfigInit
fi

#
# EXTRACT SERVER FILES
# This usually takes ~5-20s and saves about 750MB of size from the image
#
SHOULD_UNPACK="true"

if [[ "$(ls -A /server/valheim_server_Data/version 2>/dev/null)" ]]; then
  echo "Server files detected, checking version number..." | capture-output ServerInit
  INSTALL_VERSION="$(cat /server/valheim_server_Data/version 2>/dev/null)"
  [[ "${INSTALL_VERSION}" == "${APP_VERSION}" ]] && SHOULD_UNPACK="false"
fi

if [[ "${SHOULD_UNPACK}" == "true" ]]; then
  echo "Unpacking valheim server files in $(pwd)" | capture-output ServerInit
  tar -xzf "./valheim_server_Data.tar.gz"
fi

#
# WORKDIR SYNC
# This keeps world saves around <50ms in each cycle when in-memory storage is used
#

sync-workdir-watcher &
echo "WorkdirSync Start ${!}" | capture-output WorkdirSync
