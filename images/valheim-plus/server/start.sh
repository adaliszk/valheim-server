#!/bin/bash

TEMP_LD_LIBRARY_PATH="$LD_LIBRARY_PATH"

# Whether or not to enable Doorstop. Valid values: TRUE or FALSE
export DOORSTOP_ENABLE=TRUE

# What .NET assembly to execute. Valid value is a path to a .NET DLL that mono can execute.
export DOORSTOP_INVOKE_DLL_PATH="${SERVER_PATH}/BepInEx/core/BepInEx.Preloader.dll"
export DOORSTOP_CORLIB_OVERRIDE_PATH="${SERVER_PATH}/unstripped_corlib"

DOORSTOP_LIB_PATH="${SERVER_PATH}/doorstop_libs"
DOORSTOP_LIBRARY="libdoorstop_x64.so"

export LD_LIBRARY_PATH="${DOORSTOP_LIB_PATH}:$LD_LIBRARY_PATH"
export LD_PRELOAD="${DOORSTOP_LIBRARY}"

export DYLD_LIBRARY_PATH="${DDORSTOP_LIBS}"
export DYLD_INSERT_LIBRARIES="${DOORSTOP_LIB_PATH}/${DOORSTOP_LIBRARY}"

./valheim_server.x86_64 -nographics -batchmode \
  -name "${SERVER_MOTD}" \
  -world "${SERVER_WORLD}" \
  -password "${SERVER_PASSWORD}" \
  -port 2456 \
  -public 0

export LD_LIBRARY_PATH="$TEMP_LD_LIBRARY_PATH"
