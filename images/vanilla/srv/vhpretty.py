#!/usr/bin/env python3

# VALHEIM CONSOLE
# this script is intended to clean the otherwise quite noisy Valheim server's
# output by transforming each line to a more understandable format

import os
import sys

import fileinput
import re

import datetime


stdin = sys.stdin.reconfigure(encoding='utf-8', errors='ignore')

LOG_LEVEL_PREFIX = {"error": "e", "warning": "w", "info": "i", "debug": "d", "verbose": "v"}
LOG_LEVEL_VALUE = {"error": 0, "warning": 1, "info": 2, "debug": 3, "verbose": 4}
LOG_LEVEL = os.environ.get('LOG_LEVEL') or "debug"
LOG_LEVEL_ALLOWED = LOG_LEVEL_VALUE.get(LOG_LEVEL, 3)

STATUS_PATH = os.environ.get('STATUS_PATH') or "/status"
LOG_PATH = os.environ.get('LOG_PATH') or "/logs"


def echo(message: str, level: str = "info", group: str = "Container"):
    prefix = LOG_LEVEL_PREFIX.get(level, "info")
    level_value = LOG_LEVEL_VALUE.get(level, 5)

    if level_value <= LOG_LEVEL_ALLOWED:
        print("{}> {}> {}".format(prefix, group, message.strip()))
        sys.stdout.flush()


def echo_debug(message: str):
    echo(message=message, level="debug", group="VhPretty")


def echo_verbose(message: str):
    echo(message=message, level="verbose", group="VhPretty")


def set_status(name: str, status: bool):
    status_file = STATUS_PATH + "/" + name
    f = open(status_file, "w")
    status_code = "0" if status else "1"
    echo_verbose("Write {} to be {}".format(status_file, status_code))
    f.write(status_code)
    f.close()


def set_log_group(name: str):
    f = open("/tmp/LOG_GROUP", "w")
    f.write(name)
    f.close()


def get_log_group() -> str:

    name = os.environ.get('LOG_GROUP')

    try:
        f = open("/tmp/LOG_GROUP", "r")
        name = f.read()
        f.close()
    except FileNotFoundError:
        pass

    if name is None:
        name = "Server"

    return name.strip()


def log_error(error: str):
    f = open(LOG_PATH + "/error.log", "a")
    timestamp = datetime.datetime.now().isoformat()
    f.write(timestamp + "> " + error.strip() + "\n")
    f.close()


def ucfirst(text: str):
    if re.match(r'^src/', line):
        return text

    return text[0].upper() + text[1:]


set_status('Zonesystem', False)
set_status('DungeonDB', False)
set_status('Server', False)

last_line = ""
bepinex_started = False

date_regex = re.compile(r'^\d+/\d+/\d+ \d+:\d+:\d+:', re.IGNORECASE)
noisy_regex = re.compile(r'^\[Subsystems]|^-', re.IGNORECASE)
trim_regex = re.compile(r'\s{2,}', re.IGNORECASE)
group_regex = re.compile(r'^(\w+)> (.*)', re.IGNORECASE)
steam_regex = re.compile(r'Steam', re.IGNORECASE)
gc_regex = re.compile(r'^Unloading|^Total', re.IGNORECASE)

bepinex_regex = re.compile(r'\[(\w+)\s*:\s*([^]]+)] (.*)', re.IGNORECASE)
bepinex_loader_regex = re.compile(r'Chainloader ready')
debug_regex = re.compile(r'(Section not|Loading config|Loading key|Load DLL:|Base:|Redirecting to)', re.IGNORECASE)
warning_regex = re.compile(r'(Warning|Failed|Missing|Fallback|Wrong)', re.IGNORECASE)
error_regex = re.compile(r'Error', re.IGNORECASE)
severe_regex = re.compile(r'(Error|Warning|Failed|Missing|Fallback)', re.IGNORECASE)
fallback_regex = re.compile(r'Fallback handler could not load library', re.IGNORECASE)

for line in fileinput.input():

    # remove whitespace
    line = line.strip()

    # skip too short lines
    if len(line) < 2:
        echo_verbose("Found too short line, skipping it...")
        continue

    # ignore empty lines
    if re.search(r'^\s+$', line):
        echo_verbose("Found Empty line, skipping it...")
        continue

    # ignore Debug lines with (Filename: ...)
    if re.search(r'^\(Filename:', line):
        echo_verbose("Found Filename line, skipping it...")
        continue

    # remove DATETIME prefix as this is added outside of the STDOUT
    if re.search(date_regex, line):
        echo_debug("Found DATETIME prefix, removing it...")
        line = re.sub(date_regex, r'', line)

    # remove Noisy prefixes
    if re.search(noisy_regex, line):
        echo_debug("Found Noisy patterns, removing it...")
        line = re.sub(noisy_regex, r'', line)

    # trim needless space within the line
    if re.search(trim_regex, line):
        echo_debug("Found long spaces, shortening it...")
        line = re.sub(trim_regex, r' ', line)

    # format the line to look nice
    line = ucfirst(line)

    group = get_log_group()
    level = "info"

    # detect when the Server is reported to be Ready
    if re.search(r'Zonesystem Start', line, re.IGNORECASE):
        echo_debug("Zonesystem started, saving status...")
        set_status('Zonesystem', True)

    # detect when the Server is reported to be Ready
    if re.search(r'DungeonDB Start', line, re.IGNORECASE):
        echo_debug("DungeonDB started, saving status...")
        set_status('DungeonDB', True)

    # detect when the Server is reported to be Ready
    if re.search(r'Game server connected$', line, re.IGNORECASE):
        echo_debug("Server started, saving status...")
        set_status('Server', True)
        set_log_group('Server')
        group = "Server"

    if re.search(r'Game server connected failed|Game server disconnected$', line, re.IGNORECASE):
        echo_debug("Server disconnected, saving status...")
        set_status('Server', False)

    group_match = re.search(group_regex, line)
    if group_match:
        line = re.sub(group_regex, r'\2', line)
        group = group_match.group(1)

    if re.search(steam_regex, line):
        group = "Steam"

    bepinex_match = re.search(bepinex_regex, line)
    if bepinex_match:
        levels = {"Info": "info", "Message": "info", "Debug": "debug", "Warn": "warning", "Error": "error"}
        prefix = levels.get(bepinex_match.group(1), "info")
        group = bepinex_match.group(2) or "BepInEx"
        line = re.sub(bepinex_regex, r'\3', line)

    if re.search(bepinex_loader_regex, line):
        bepinex_started = True

    if re.search(debug_regex, line):
        level = "debug"

    if re.search(warning_regex, line):
        level = "warning"

    if re.search(error_regex, line):
        level = "error"

    if re.search(severe_regex, line) or level in ["warning", "error"]:
        log_error(line)

    if re.search(fallback_regex, line) and not bepinex_started:
        level = "debug"

    if len(line) > 0 and line != last_line:
        echo(message=line, level=level, group=group)
        last_line = line.strip()
