#!/bin/bash
# shellcheck disable=SC1091
source /srv/init-server.sh


# Valheim Plus specific settings
# NOTE: Do not edit unless you know what you are doing!
####
export DOORSTOP_ENABLE=TRUE

# What .NET assembly to execute. Valid value is a path to a .NET DLL that mono can execute.
export DOORSTOP_INVOKE_DLL_PATH="${SERVER_PATH}/BepInEx/core/BepInEx.Preloader.dll"
export DOORSTOP_CORLIB_OVERRIDE_PATH="${SERVER_PATH}/unstripped_corlib"

DOORSTOP_LIB_PATH="${SERVER_PATH}/doorstop_libs"
DOORSTOP_LIBRARY="libdoorstop_x64.so:$LD_PRELOAD"

export LD_LIBRARY_PATH="${DOORSTOP_LIB_PATH}:$LD_LIBRARY_PATH"
export LD_PRELOAD="${DOORSTOP_LIBRARY}"

export DYLD_LIBRARY_PATH="${DDORSTOP_LIBS}"
export DYLD_INSERT_LIBRARIES="${DOORSTOP_LIB_PATH}/${DOORSTOP_LIBRARY}"
####


TEMP_LD_LIBRARY_PATH="$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="${SERVER_PATH}/linux64:$LD_LIBRARY_PATH"

# Build the Server's Arguments into a Command-Line
SERVER_ARGS=(
  "-name" "${SERVER_NAME}"
  "-password" "${SERVER_PASSWORD}"
  "-world" "${SERVER_WORLD}"
  "-savedir" "${DATA_PATH}"
  "-public" "${SERVER_PUBLIC}"
)

SERVER_ARGS_STR=$( IFS=$' '; echo "${SERVER_ARGS[*]}" )

SERVER_CMD="${SERVER_PATH}/valheim_server.x86_64 -nographics -batchmode -logfile -port 2456"

echo "Execute: ${SERVER_CMD} ${SERVER_ARGS_STR}"
${SERVER_CMD} "${SERVER_ARGS[@]}"

export LD_LIBRARY_PATH="$TEMP_LD_LIBRARY_PATH"
