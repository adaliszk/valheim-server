#!/bin/bash
# shellcheck disable=SC1091
source /srv/init-env.sh
source /srv/init-configs.sh

echo "BepInExInit" > /tmp/LOG_GROUP

if [ "$(ls -A "${CONFIG_PATH}")" ]; then
  echo "Initialize config files from ${CONFIG_PATH}"
  cp -rf "${MOD_PATH}/BepInEx/config/". "${SERVER_PATH}/BepInEx/config/"
  cp -rf "${CONFIG_PATH}/"*.{cfg,ini,json} "${SERVER_PATH}/BepInEx/config/" 2> /dev/null
fi

if [ -w "${CONFIG_PATH}" ]; then
  echo "Copy new files back to ${CONFIG_PATH}"
  cp -rf "${SERVER_PATH}/BepInEx/config/". "${CONFIG_PATH}/"
fi

if [ "$(ls -A "${PLUGINS_PATH}")" ]; then
  echo "Initialize plugins from ${PLUGINS_PATH}"
  rm -rf "${SERVER_PATH}/BepInEx/plugins/"*
  cp -rf "${MOD_PATH}/BepInEx/plugins/". "${SERVER_PATH}/BepInEx/plugins/"
  cp -rf "${PLUGINS_PATH}/". "${SERVER_PATH}/BepInEx/plugins/"
fi

# BepInEx-specific settings
# NOTE: Do not edit unless you know what you are doing!
####
export DOORSTOP_ENABLE=TRUE
export DOORSTOP_INVOKE_DLL_PATH=${SERVER_PATH}/BepInEx/core/BepInEx.Preloader.dll
export DOORSTOP_CORLIB_OVERRIDE_PATH=${SERVER_PATH}/unstripped_corlib

export LD_LIBRARY_PATH="${SERVER_PATH}/doorstop_libs:$LD_LIBRARY_PATH"
export LD_PRELOAD="libdoorstop_x64.so:$LD_PRELOAD"
####
