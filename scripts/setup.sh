# Copyright © 2022 by Ádám Liszkai using BSD 2-Clause License
# https://source.adaliszk.io/valheim-server/license

export SERVER_NAME="${SERVER_NAME:-Valheim ${APP_VERSION} Server by AdaLiszk}"
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
# INITIALIZE CONTAINER
#

mkdir -p /data/configs "/data/backups/${SERVER_WORLD}" /data/worlds /data/logs
mkdir -p /tmp/valheim-server/worlds_local /.config/unity3d

#[[ ! -f /data/vendor ]] && ln -s /.config/unity3d/IronGate /data/vendor

#
# ROTATE LOGS
#

[[ -f /data/logs/server.log ]] && mv /data/logs/server.log "/data/logs/$(date "+%Y-%m-%dT%H%M%S%z").log"
touch /data/logs/server.log

#
# PARSE ARGUMENTS
#

while [[ $# -gt 0 ]]; do
	if [[ $1 =~ -([a-z]+)(=| )(.*) ]]; then
		ARG="${BASH_REMATCH[1]}"
		VALUE="${BASH_REMATCH[3]}"

		case "${ARG}" in
		name) export SERVER_NAME="${VALUE}" ;;
		password) export SERVER_PASSWORD="${VALUE}" ;;
		world) export SERVER_WORLD="${VALUE}" ;;
		public) export SERVER_PUBLIC="${VALUE}" ;;
		admins) export ADMIN_LIST="${VALUE}" ;;
		permitted) export PERMITTED_LIST="${VALUE}" ;;
		banned) export BANNED_LIST="${VALUE}" ;;
		saveinternal) export SAVE_INTERVAL="${VALUE}" ;;
		backups) export BACKUP_RETENTION="${VALUE}" ;;
		backupshort) export BACKUP_FIRST_INTERVAL="${VALUE}" ;;
		backuplong) export BACKUP_CYCLE_INTERVAL="${VALUE}" ;;
		crossplay) export SERVER_CROSSPLAY="true" ;;
		esac
	fi
	shift
done

#
# COLLECT & DISPLAY SERVER INFO
#
export WORLD_SEED="(undefined)"
# TODO: Parse seed from the .fwl file

cat <<-SERVER_INFO
	> LAN Address: $(hostname -i):${SERVER_PORT}
	> WAN Address: $(dig +short myip.opendns.com @resolver1.opendns.com):${SERVER_PORT} (assuming port-forward)
	> World: ${SERVER_WORLD}
	> Seed: ${WORLD_SEED}

SERVER_INFO

#
# INITIALIZE STATE AND CONFIGS
# Since we use an in-memory workdir, we need to copy the previous state back to the memory
#

if [[ "$(ls -A "/data/worlds/${SERVER_WORLD}".{db,fwl} 2>/dev/null)" ]]; then
	init-workdir WorkdirInit
fi

if [ "$(ls -A /data/configs/*.txt 2>/dev/null)" ]; then
	echo "Initialize config files from data:/configs" | log ConfigInit
	for config in /data/config/*txt; do
		filename=$(basename "${config}")
		echo "Copy ${config} into valheim-server:/${filename}" | log WorkdirInit DEBUG
		rm -rf "/tmp/valheim-server/${filename}"
		cat "${config}" >"/tmp/valheim-server/${filename}"
	done
else
	echo "Initializing config files from environment variables" | log ConfigInit
	list-to-file "${SERVER_ADMINS}" "/tmp/valheim-server/adminlist.txt" WorkdirInit
	list-to-file "${SERVER_PERMITTED}" "/tmp/valheim-server/permittedlist.txt" WorkdirInit
	list-to-file "${SERVER_BANNED}" "/tmp/valheim-server/bannedlist.txt" WorkdirInit
fi

#
# EXTRACT SERVER FILES
# This usually takes ~5-20s and saves about 750MB of size from the image
#

SHOULD_UNPACK="true"

if [[ "$(ls -A /server/valheim_server_Data/version 2>/dev/null)" ]]; then
	echo "Server files detected, checking version number..." | log ServerInit
	INSTALL_VERSION="$(cat /server/valheim_server_Data/version 2>/dev/null)"
	[[ "${INSTALL_VERSION}" == "${APP_VERSION}" ]] && SHOULD_UNPACK="false"
fi

if [[ "${SHOULD_UNPACK}" == "true" ]]; then
	echo "Unpacking valheim server files in $(pwd)" | log ServerInit
	tar -xzf "./valheim_server_Data.tar.gz"
fi

#
# WORKDIR SYNC
# This keeps world saves around <50ms in each cycle when in-memory storage is used
#

sync-workdir-watcher &
echo "WorkdirSync Start ${!}" | log WorkdirSync