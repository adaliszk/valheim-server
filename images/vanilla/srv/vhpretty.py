#!/usr/bin/env python3

# VALHEIM CONSOLE
# this script is intended to clean the otherwise quite noisy Valheim server's
# output by transforming each line to a more understandable format

import os
import sys

import fileinput
import re


LOG_PATH = os.environ.get('LOG_PATH')
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

for line in fileinput.input():
    # ignore empty lines
    if re.search(r'^\s+$', line):
        continue

    # ignore Debug lines with (Filename: ...)
    if re.search(r'^\(Filename:', line):
        continue

    # remove DATETIME prefix as this is added outside of the STDOUT
    date_regex = re.compile(r'^\d+/\d+/\d+ \d+:\d+:\d+:', re.IGNORECASE)
    if re.search(date_regex, line):
        line = re.sub(date_regex, r'', line)

    # remove Noisy prefixes
    noisy_regex = re.compile(r'^\[Subsystems]|^-', re.IGNORECASE)
    if re.search(noisy_regex, line):
        line = re.sub(noisy_regex, r'', line)

    # trim needless space within the line
    trim_regex = re.compile(r'\s{2,}', re.IGNORECASE)
    if re.search(trim_regex, line):
        line = re.sub(trim_regex, r' ', line)

    # remove WHITESPACE and format the line to look nice
    line = ucfirst(line.strip())

    # detect when the Server is reported to be Ready
    if re.search(r'^Game server connected$', line):
        set_server_connected(True)

    prefix = "i"

    bepinex_regex = re.compile(r'\[(\w+)\s*:\s*([^]]+)] (.*)', re.IGNORECASE)
    bepinex_match = re.search(bepinex_regex, line)

    if bepinex_match:
        levels = {"Info": "i", "Message": "m", "Debug": "d", "Warn": "w", "Error": "e"}
        prefix = levels.get(bepinex_match.group(1), "I")
        line = re.sub(bepinex_regex, r'\2> \3', line)

        # No need to duplicate the Unity output
        if bepinex_match.group(2) == "Unity Log":
            line = ""

    debug_regex = re.compile(r'(Section not|Loading config|Loading key|Load DLL:|Base:|Redirecting to)', re.IGNORECASE)
    if re.search(debug_regex, line):
        prefix = "d"

    warning_regex = re.compile(r'(Warning|Failed|Missing|Fallback)', re.IGNORECASE)
    if re.search(warning_regex, line):
        prefix = "w"

    error_regex = re.compile(r'Error', re.IGNORECASE)
    if re.search(error_regex, line):
        prefix = "e"

    severe_regex = re.compile(r'(Error|Warning|Failed|Missing|Fallback|)', re.IGNORECASE)
    if re.search(severe_regex, line) or prefix in ["w", "e"]:
        log_error(line)

    if prefix not in ["d"] and len(line) > 0 and line != last_line:
        print(prefix + "> " + line)
        sys.stdout.flush()
        last_line = line
