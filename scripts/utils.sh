# Copyright © 2022 by Ádám Liszkai using BSD 2-Clause License
# https://source.adaliszk.io/valheim-server/license

# region Files

function list-to-file() {
	if [[ -n ${1} ]]; then
		echo "Saving \"${1}\" into ${2}" | log "${3}"
		echo "${1}" | tr ',' '\n' >"${2}"
	fi
}

function set-status {
	echo "${2}" >"/tmp/state/${1,,}"
}

# endregion

# region WorkdirSync

function find-with-regex {
	find "${1}" -type f -exec basename {} \; | grep -iE "${2}"
}

function rsync-matched {
	# shellcheck disable=SC2068
	rsync -azhmv --include-from=- --exclude='*' $@ 2>&1
}

function init-workdir {
	echo "Syncing worlds from /data" | log "${1}"
	find-with-regex /data/worlds/ "${SERVER_WORLD}\.(db|fwl)$" |
		rsync-matched /data/worlds/ /tmp/valheim-server/worlds_local |
		log "${1}" DEBUG
}

function sync-workdir {
	echo "Syncing worlds to /data" | log "${1}"
	find-with-regex /tmp/valheim-server/worlds_local/ "${SERVER_WORLD}\.(db|fwl|db\.old|fwl\.old)$" |
		rsync-matched /tmp/valheim-server/worlds_local/ /data/worlds/ |
		log "${1}" DEBUG

	cleanup-backups "${1}"
	echo "Syncing backups to /data" | log "${1}"
	find-with-regex /tmp/valheim-server/worlds_local/ "[0-9]{14,}\.(db|fwl|db\.old|fwl\.old)$" |
		rsync-matched /tmp/valheim-server/worlds_local/ "/data/backups/${SERVER_WORLD}/" |
		log "${1}" DEBUG
}

function cleanup-backups {
	echo "Removing old backups" | log "${1}"
	find-with-regex /tmp/valheim-server/worlds_local/ "[0-9]{14,}\.(db|fwl|db\.old|fwl\.old)$" \
		-type f -mtime +1 -exec rm {} \; |
		log "${1}" DEBUG

	find "/data/backups/${SERVER_WORLD}/" -type f -mtime +5 -exec rm {} \; |
		log "${1}" DEBUG
}

function sync-workdir-watcher {
	while inotifywait -e modify -e create -e delete -e close_write /tmp/valheim-server 2>&1 | log WorkdirSync; do
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

bepinex_log_match="\[([a-zA-Z]+)[: ]+([a-zA-Z.]+)\] (.*)"
bepinex_match="registered |^fallback handler|^load dll|^redirecting to|^base|^could not load signature of"

warning_match="warning|missing|unable|not supported|cloud not load"
error_match="error|failure|failed|exception|  at"
debug_match="debug"
ignore_match="^\.|^building file list"

function log {
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

		[[ ${message,,} =~ $bepinex_match ]] && group="BepInEx"
		[[ ${message} =~ $bepinex_log_match ]] &&
			group="${BASH_REMATCH[2]}" && level="${BASH_REMATCH[1]^^}" && message="${BASH_REMATCH[3]}"

		# Filtering
		[[ ${message,,} =~ $ignore_match ]] && message=""

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
				sed -u "s/{group}/${group}/gi;t" |
				sed -u "s/{message}/${message^}/gi;t"
		}

		if [[ -n "$message" ]]; then
			parse-message "${CONSOLE_FORMAT}" >>/dev/fd/2
			parse-message "${LOG_FORMAT}" >>/data/logs/server.log
		fi
	done
}

# endregion

# region Termination

function gracefully-terminate {
	echo "Received termination signal!" | log GracefulTerminator

	# TODO: Wait for players to disconnect
	pkill -TERM valheim_server
	sync-workdir GracefulTerminator
}

# endregion
