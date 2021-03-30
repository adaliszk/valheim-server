#!/usr/bin/env python3

import os
import subprocess
import sys

import fileinput
import re

import datetime

stdin = sys.stdin.reconfigure(encoding='utf-8', errors='ignore')

LOG_LEVEL = os.environ.get('LOG_LEVEL') or "debug"
LOG_PATH = os.environ.get('LOG_PATH')

STATUS_PATH = os.environ.get('STATUS_PATH')

server_boot = datetime.datetime.now()
server_start = None
server_initialized = None
server_listen = None
server_ready = None

client_connection = None
client_connected = None
client_spawn = None


def echo(message: str):
    print(message.strip())
    sys.stdout.flush()


def echo_elapsed(message: str, elapsed_time):
    echo("i> Metrics> {} ( took {}s )".format(message, elapsed_time.total_seconds()))


def set_status(name: str, status: bool):
    f = open(STATUS_PATH + "/" + name, "w")
    f.write("0" if status else "1")
    f.close()


for line in fileinput.input():

    new_connection = re.compile(r'Got connection SteamID (?P<steam_id>\d{17})', re.IGNORECASE)
    match = re.search(new_connection, line)
    if match:
        subprocess.Popen(["/scripts/backup.sh", match.group('steam_id')])

    world_saved = re.compile(r'World saved', re.IGNORECASE)
    if re.search(world_saved, line):
        subprocess.Popen(["/scripts/backup.sh", "auto"])

    echo(line)

    if re.search(r'Execute: /server/valheim_server.x86_64', line) and server_start is None:
        server_start = datetime.datetime.now()
        echo_elapsed("Game server initialized", server_start - server_boot)
        set_status('World', False)

    if re.search(r'DungeonDB Start', line) and server_initialized is not None:
        server_listen = datetime.datetime.now()
        echo_elapsed("World is ready", server_listen - server_initialized)
        set_status('World', True)

    if re.search(r'Steam game server initialized', line) and server_start is not None and server_initialized is None:
        server_initialized = datetime.datetime.now()
        echo_elapsed("Steam initialized", server_initialized - server_start)

    if re.search(r'Game server connected', line) and server_start is not None and server_ready is None:
        server_ready = datetime.datetime.now()
        echo_elapsed("Game server ready", server_ready - server_boot)
