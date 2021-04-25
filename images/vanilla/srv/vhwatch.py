#!/usr/bin/env python3

import os
import subprocess
import sys

import fileinput
import re

import datetime

LOG_PATH = os.environ.get('LOG_PATH') or "/logs"
STATUS_PATH = os.environ.get('STATUS_PATH') or "/status"

stdin = sys.stdin.reconfigure(encoding='utf-8', errors='ignore')

server_boot = datetime.datetime.now()
server_start = None
server_initialized = None
server_listen = None
server_ready = None


def echo(message: str):
    print("{}".format(message).rstrip())
    sys.stdout.flush()


def echo_metric(message: str):
    echo("m> {}".format(message).rstrip())


def echo_elapsed(message: str, elapsed_time):
    echo_metric("{} ( took {}s )".format(message, elapsed_time.total_seconds()))


def set_status(name: str, status: bool):
    f = open(LOG_PATH + "/{}.status".format(name), "w")
    f.write("0" if status else "1")
    f.close()


server_exec = re.compile(r'Execute: /server/valheim_server.x86_64', re.IGNORECASE)

world_saved = re.compile(r'World saved', re.IGNORECASE)

new_connection = re.compile(r'New connection', re.IGNORECASE)
getting_steam_id = re.compile(r'Connecting to Steamworks.SteamNetworkIdentity', re.IGNORECASE)
got_connection = re.compile(r'Got connection SteamID (?P<steam_id>\d{17})', re.IGNORECASE)


set_status('server', False)


for line in fileinput.input():

    new_connection_match = re.search(got_connection, line)
    if new_connection_match:
        subprocess.Popen(["/scripts/backup.sh", new_connection_match.group('steam_id')])

    if re.search(world_saved, line):
        subprocess.Popen(["/scripts/backup.sh", "auto"])

    echo(line)

    if re.search(server_exec, line):
        server_start = datetime.datetime.now()
        set_status('world', False)

    if re.search(r'DungeonDB Start', line):
        server_listen = datetime.datetime.now()
        set_status('world', True)

    if re.search(r'Steam game server initialized', line) and server_start is not None and server_initialized is None:
        server_initialized = datetime.datetime.now()
        echo_elapsed("Steam initialized", server_initialized - server_start)

    if re.search(r'Game server connected', line) and server_start is not None and server_ready is None:
        server_ready = datetime.datetime.now()
        echo_elapsed("Game server ready", server_ready - server_boot)
        set_status('server', True)
