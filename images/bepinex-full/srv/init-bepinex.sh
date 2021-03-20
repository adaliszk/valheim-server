#!/bin/bash
# shellcheck disable=SC1091
source /srv/init-env.sh


if [ "$(ls -A "${CONFIG_PATH}")" ];
  then
    echo -e "Initialize config files from ${CONFIG_PATH}"
    rm -rf "${SERVER_PATH}/BepInEx/config/"*
    cp -rfa "${MOD_PATH}/BepInEx/config/"*.cfg "${SERVER_PATH}/BepInEx/config/"
    cp -rfa "${CONFIG_PATH}/"*.cfg "${SERVER_PATH}/BepInEx/config/"
  fi


if [ "$(ls -A "${PLUGINS_PATH}")" ];
  then
    echo -e "Initialize plugins from ${PLUGINS_PATH}"
    rm -rf "${SERVER_PATH}/BepInEx/plugins/"*
    cp -rfa "${MOD_PATH}/BepInEx/plugins/." "${SERVER_PATH}/BepInEx/plugins/"
    cp -rfa "${PLUGINS_PATH}/." "${SERVER_PATH}/BepInEx/plugins/"
  fi

# BepInEx-specific settings
# NOTE: Do not edit unless you know what you are doing!
####
export DOORSTOP_ENABLE="TRUE"
export DOORSTOP_INVOKE_DLL_PATH="${SERVER_PATH}/BepInEx/core/BepInEx.Preloader.dll"
export DOORSTOP_CORLIB_OVERRIDE_PATH="${SERVER_PATH}/unstripped_corlib"
export DOORSTOP_LD_PATH="${SERVER_PATH}/BepInEx/doorstop"
export DOORSTOP_LD_PRELOAD="libdoorstop_x64.so"

export LD_LIBRARY_PATH="${DOORSTOP_LD_PATH}:${LD_LIBRARY_PATH}"
export LD_PRELOAD="${DOORSTOP_LD_PRELOAD}:${LD_PRELOAD}"
####
