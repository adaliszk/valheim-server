#!/bin/bash
source /srv/init-env.sh

# Cleanups
milisec_match="[0-9]+,[0-9]+.?ms"
missing_dat="missing world\.dat"

# Groups
steam_line="steam|sapi"
console_line="^[0-9]+\/[0-9]+\/[0-9]+ [0-9]+:[0-9]+:[0-9]+:"
gc_line="^unloading|^total:"

# Severity
warning_match="warning|missing|::warning::"
error_match="error|failure|failed|exception|::error::"
metric_match="^::metric::"
debug_match="^::debug::"

# Health
zonesystem_ready="zonesystem start [0-9]+"
dungeondb_ready="dungeondb start [0-9]+"
server_ready="game server connected$"
server_failed="game server connected failed$"
steam_ready="steam game server initialized"

# Metrics
world_load_begin="load world"
world_load_end="loaded [0-9]+ locations"
scene_boot_begin="starting to load scene:start"
scene_boot_end="dungeondb start [0-9]+"
server_boot_end="game server connected$|dungeondb start [0-9]+"

# shellcheck disable=SC2034
function format-output {
  while IFS="" read -r LINE; do

    # Pre-Cleanup
    [[ ${LINE,,} =~ $milisec_match ]] && LINE="$(echo "${LINE}" | sed -uE 's/([0-9]+),([0-9]+)/\1\.\2/gi;t')"
    [[ ${LINE,,} =~ $missing_dat ]] && LINE="Missing world data, generating a fresh one..."

    GROUP=$(cat /tmp/LOG_GROUP)
    [[ ${LINE,,} =~ $steam_line ]] && GROUP="Valve"
    [[ ${LINE,,} =~ $console_line ]] && GROUP="Console"
    [[ ${LINE,,} =~ $gc_line ]] && GROUP="GarbageCollector"
    [[ ${LINE,,} =~ $metric_match ]] && GROUP="Metric"

    LEVEL="${LOG_LEVEL_INFO}"
    [[ ${LINE,,} =~ $warning_match ]] && LEVEL="${LOG_LEVEL_WARNING}"
    [[ ${LINE,,} =~ $error_match ]] && LEVEL="${LOG_LEVEL_ERROR}"
    [[ ${LINE,,} =~ $metric_match ]] && LEVEL="${LOG_LEVEL_METRIC}"
    [[ ${LINE,,} =~ $debug_match ]] && LEVEL="${LOG_LEVEL_DEBUG}"

    # Post-Cleanup
    [[ ${LINE,,} =~ $warning_match ]] && LINE="${LINE/::warning::/}"
    [[ ${LINE,,} =~ $error_match ]] && LINE="${LINE/::error::/}"
    [[ ${LINE,,} =~ $metric_match ]] && LINE="${LINE/::metric::/}"
    [[ ${LINE,,} =~ $debug_match ]] && LINE="${LINE/::debug::/}"

    # Health
    [[ ${LINE,,} =~ $steam_ready ]] && set-status "Steam" 0
    [[ ${LINE,,} =~ $zonesystem_ready ]] && set-status "Zonesystem" 0
    [[ ${LINE,,} =~ $dungeondb_ready ]] && set-status "DungeonDB" 0
    [[ ${LINE,,} =~ $server_failed ]] && set-status "Server" 1
    [[ ${LINE,,} =~ $server_ready ]] && set-status "Server" 0

    # Mark Metrics
    [[ ${LINE,,} =~ $world_load_begin ]] && console-time "WorldLoading"
    [[ ${LINE,,} =~ $scene_boot_begin ]] && console-time "SceneBoot"

    OUT=$(
      echo "${LINE}" | grep -vE '^$|^\s+$|^\(Filename' \
        | sed -uE 's/[0-9]+\/[0-9]+\/[0-9]+ [0-9]+:[0-9]+:[0-9]+: //gi;s/^Warning: ([a-z])/\U\1/gi' \
        | sed -uE 's/\n//gi;s/^\s+//gi;s/\s+$//gi'
      )

    [[ ${OUT} != "" ]] && log-out "${OUT}"

    # Print Metrics
    [[ ${LINE,,} =~ $world_load_end ]] && log-metric "World loaded in" | console-timeEnd "WorldLoading"
    [[ ${LINE,,} =~ $scene_boot_end ]] && log-metric "Scene initialized in" | console-timeEnd "SceneBoot"
    [[ ${LINE,,} =~ $server_boot_end ]] && get-status "DungeonDB" && get-status "Server" \
      && log-metric "Server started in" | console-timeEnd "ServerBoot"

  done
}