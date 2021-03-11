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

for line in fileinput.input():
    # ignore empty lines
    if re.match(r'^\s+$', line):
        continue

    # ignore Debug lines with (Filename: ...)
    if re.match(r'^\(Filename:', line):
        continue

    # remove DATETIME prefix as this is added outside of the STDOUT
    datePrefix = re.compile(r'^\d+/\d+/\d+ \d+:\d+:\d+:', re.IGNORECASE)
    if re.search(datePrefix, line):
        line = re.sub(datePrefix, r'', line)

    # remove Noisy prefixes
    noisyPrefix = re.compile(r'^\[Subsystems]|-', re.IGNORECASE)
    if re.search(noisyPrefix, line):
        line = re.sub(noisyPrefix, r'', line)

    # trim needless space within the line
    needlessSpace = re.compile(r'\s{2,}', re.IGNORECASE)
    if re.search(needlessSpace, line):
        line = re.sub(needlessSpace, r' ', line)

    # remove WHITESPACE and format the line to look nice
    line = ucfirst(line.strip())

    # detect when the Server is reported to be Ready
    if re.match(r'^Game server connected$', line):
        set_server_connected(True)

    prefix = "I"

    bepInExRegex = re.compile(r'^\[(\w+)\s*:\s*(\w+)] (.*)', re.IGNORECASE)
    if re.match(bepInExRegex, line):
        match = re.search(bepInExRegex, line)
        levels = {"Info": "I", "Message": "M", "Debug": "D", "Warn": "W", "Error": "E"}
        prefix = levels.get(match.group(1), "I")
        line = re.sub(bepInExRegex, r'\2> \3', line)

    debugRegex = re.compile(r'(Section not|Loading config|Loading key|Load DLL:|Base:|Redirecting to)', re.IGNORECASE)
    if re.search(debugRegex, line):
        prefix = "D"

    warningRegex = re.compile(r'(Warning|Failed|Missing|Fallback)', re.IGNORECASE)
    if re.search(warningRegex, line):
        prefix = "W"

    errorRegex = re.compile(r'Error', re.IGNORECASE)
    if re.search(errorRegex, line):
        prefix = "E"

    severityRegex = re.compile(r'(Error|Warning|Failed|Missing|Fallback|)', re.IGNORECASE)
    if re.search(severityRegex, line) or prefix in ["W", "E"]:
        log_error(line)

    if prefix not in ["D"]:
        print(prefix + "> " + line)
        sys.stdout.flush()
