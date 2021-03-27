#!/usr/bin/env python3

# VALHEIM CONSOLE
# this script is intended to clean the otherwise quite noisy Valheim server's
# output by transforming each line to a more understandable format

import os
import sys

import fileinput
import re

LOG_PATH = os.environ.get('LOG_PATH')
LOG_LEVEL = os.environ.get('LOG_LEVEL') or "debug"
stdin = sys.stdin.reconfigure(encoding='utf-8', errors='ignore')


def set_server_connected(status: bool):
    f = open(LOG_PATH + "/server-connected.status", "w")
    f.write("0" if status else "1")
    f.close()


def log_error(error: str):
    f = open(LOG_PATH + "/error.log", "a")
    f.write(error + "\n")
    f.close()


def ucfirst(text: str):
    if re.match(r'^src/', line):
        return text

    return text[0].upper() + text[1:]


set_server_connected(False)

last_line = ""
bepinex_started = False

date_regex = re.compile(r'^\d+/\d+/\d+ \d+:\d+:\d+:', re.IGNORECASE)
noisy_regex = re.compile(r'^\[Subsystems]|^-', re.IGNORECASE)
trim_regex = re.compile(r'\s{2,}', re.IGNORECASE)
group_regex = re.compile(r'^(\w+)> (.*)', re.IGNORECASE)
bepinex_regex = re.compile(r'\[(\w+)\s*:\s*([^]]+)] (.*)', re.IGNORECASE)
bepinex_loader_regex = re.compile(r'Chainloader ready')
debug_regex = re.compile(r'(Section not|Loading config|Loading key|Load DLL:|Base:|Redirecting to)', re.IGNORECASE)
warning_regex = re.compile(r'(Warning|Failed|Missing|Fallback|Wrong)', re.IGNORECASE)
error_regex = re.compile(r'Error', re.IGNORECASE)
severe_regex = re.compile(r'(Error|Warning|Failed|Missing|Fallback)', re.IGNORECASE)
fallback_regex = re.compile(r'Fallback handler could not load library', re.IGNORECASE)

for line in fileinput.input():
    # ignore empty lines
    if re.search(r'^\s+$', line):
        continue

    # ignore Debug lines with (Filename: ...)
    if re.search(r'^\(Filename:', line):
        continue

    # remove DATETIME prefix as this is added outside of the STDOUT
    if re.search(date_regex, line):
        line = re.sub(date_regex, r'', line)

    # remove Noisy prefixes
    if re.search(noisy_regex, line):
        line = re.sub(noisy_regex, r'', line)

    # trim needless space within the line
    if re.search(trim_regex, line):
        line = re.sub(trim_regex, r' ', line)

    # remove WHITESPACE and format the line to look nice
    line = ucfirst(line.strip())

    # detect when the Server is reported to be Ready
    if re.search(r'^Game server connected$', line):
        set_server_connected(True)

    prefix = "i"
    group = "Container"

    try:
        group = open("/tmp/LOG_GROUP", "r").read().rstrip()
    except FileNotFoundError:
        pass

    if group is None:
        group = "Container"

    group_match = re.search(group_regex, line)
    if group_match:
        line = re.sub(group_regex, r'\2', line)
        group = group_match.group(1)

    bepinex_match = re.search(bepinex_regex, line)
    if bepinex_match:
        levels = {"Info": "i", "Message": "m", "Debug": "d", "Warn": "w", "Error": "e"}
        prefix = levels.get(bepinex_match.group(1), "i")
        group = bepinex_match.group(2) or "BepInEx"
        line = re.sub(bepinex_regex, r'\3', line)

        # No need to duplicate the Unity output
        if bepinex_match.group(2) == "Unity Log":
            line = ""

    if re.search(bepinex_loader_regex, line):
        bepinex_started = True

    if re.search(debug_regex, line):
        prefix = "d"

    if re.search(warning_regex, line):
        prefix = "w"

    if re.search(error_regex, line):
        prefix = "e"

    if re.search(severe_regex, line) or prefix in ["w", "e"]:
        log_error(line)

    if re.search(fallback_regex, line) and not bepinex_started:
        prefix = "d"

    if prefix not in ["d"] and len(line) > 0 and line != last_line:
        print(prefix + "> " + group + "> " + line)
        sys.stdout.flush()
        last_line = line
