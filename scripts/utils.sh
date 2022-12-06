#!/usr/bin/env bash
# Copyright © 2022 by Ádám Liszkai using BSD 2-Clause License
# https://source.adaliszk.io/valheim-server/license

# region Files

function list-to-file() {
  if [[ -n ${1} ]]; then
    echo "Saving \"${1}\" into ${2}" | capture-output "${3}"
    echo "${1}" | tr ',' '\n' >"/tmp/valheim-server/${2}"
  fi
}

function set-status {
  echo "${2}" >"/tmp/state/${1,,}"
}

# endregion

# region WorkdirSync

function sync-workdir {
  echo "Syncing contents to /data" | capture-output WorkdirSync
  cp -rf "/tmp/valheim-server/worlds_local/${SERVER_WORLD}.db" /data/worlds_local
  cp -rf "/tmp/valheim-server/worlds_local/${SERVER_WORLD}.fwl" /data/worlds_local
  cp -rf /tmp/valheim-server/*.txt /data
  cp -rf /tmp/valheim-server/worlds_local/* /data/backups

  if [[ -w /config ]]; then
    echo "Syncing contents to /config" | capture-output WorkdirSync
    cp -rf /tmp/valheim-server/*.txt /config
  fi
}

function sync-workdir-watcher {
  while inotifywait -e modify -e create -e delete -e close_write /tmp/valheim-server 2>&1 | capture-output WorkdirSync; do
    sync-workdir
  done
}

# endregion

# region Output

export CONSOLE_FORMAT="{l}/{group}: {message}"
export LOG_FORMAT="{timestamp} {level} [{group}]: {message}"

steam_line="steam|sapi"
console_line="^[0-9]+\/[0-9]+\/[0-9]+ [0-9]+:[0-9]+:[0-9]+:"
gc_line="^unloading|^total:|^unloadtime:"

zonesystem_ready="zonesystem start [0-9]+"
dungeondb_ready="dungeondb start [0-9]+"
server_ready="game server connected$"
server_failed="game server connected failed$"
steam_ready="steam game server initialized"
save_completed="^world saved"

warning_match="warning|missing"
error_match="error|failure|failed|exception"
debug_match="debug"

function capture-output {
  local timestamp level l ll group message

  while IFS="" read -r message; do
    # Remove timestamp prefix (as we add our own when needed for logging)
    message=$(echo "${message}" | sed -uE 's/[0-9]+\/[0-9]+\/[0-9]+ [0-9]+:[0-9]+:[0-9]+: //gi;t')
    # Escape slash characters to avoid sed failures
    message=$(echo "${message}" | sed -u 's/\//\\\//g;s/#/\\#/g;t')

    timestamp=$(date "+%Y-%m-%dT%H%M%S%z")
    group="${1:-StdOut}"
    level="${2:-INFO}"

    [[ ${message,,} =~ $warning_match ]] && level="WARNING"
    [[ ${message,,} =~ $error_match ]] && level="ERROR"
    [[ ${message,,} =~ $debug_match ]] && level="DEBUG"

    [[ ${message,,} =~ $steam_line ]] && group="Valve"
    [[ ${message,,} =~ $console_line ]] && group="Console"
    [[ ${message,,} =~ $gc_line ]] && group="GarbageCollector"

    # Status reporting
    [[ ${message,,} =~ $steam_ready ]] && set-status "Steam" 0
    [[ ${message,,} =~ $zonesystem_ready ]] && set-status "Zonesystem" 0
    [[ ${message,,} =~ $dungeondb_ready ]] && set-status "DungeonDB" 0
    [[ ${message,,} =~ $server_failed ]] && set-status "Server" 1
    [[ ${message,,} =~ $server_ready ]] && set-status "Server" 0

    # Hooks into log lines
    [[ ${message,,} =~ $save_completed ]] && sync-workdir &

    # Remove level prefix from the message
    message=$(echo "${message}" | sed -u "s/^${level}:? ?//gi;t")
    l="${level:0:1}"
    ll="${level,,}"

    function parse-message {
      echo "${1}" |
        sed -u "s/{timestamp}/${timestamp}/gi;t" |
        sed -u "s/{level}/${level}/gi;s/{ll}/${ll}/gi;s/{l}/${l}/gi;t" |
        sed -u "s/{group}/${group}/gi;t" |s
        sed -u "s/{message}/${message}/gi;t"
    }

    if [[ -n "$message" ]]; then
      parse-message "${CONSOLE_FORMAT}" | tee /dev/fd/2
      parse-message "${LOG_FORMAT}" >> /logs/server.log
    fi
  done
}

# endregion

# region Termination

function gracefully-terminate {
  echo "Received termination signal!" | capture-output GracefulTerminator

  # TODO: Wait for players to disconnect
  pkill -TERM valheim_server

  echo "Persisting workdir into /data" | capture-output GracefulTerminator
  cp -rf /tmp/valheim-server/* /data
}

# endregion
