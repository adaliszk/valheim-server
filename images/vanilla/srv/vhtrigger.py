#!/usr/bin/env python3

import subprocess
import sys

import fileinput
import re


stdin = sys.stdin.reconfigure(encoding='utf-8', errors='ignore')


for line in fileinput.input():

    # ignore empty lines
    if re.match(r'^\s+$', line):
        continue

    new_connection = re.compile(r'Got connection SteamID (?P<steam_id>\d{17})', re.IGNORECASE)
    match = re.search(new_connection, line)
    if match:
        subprocess.Popen(["/scripts/backup.sh", match.group('steam_id')])

    world_saved = re.compile(r'World saved', re.IGNORECASE)
    if re.search(world_saved, line):
        subprocess.Popen(["/scripts/backup.sh", "auto"])

    print(line.rstrip())
    sys.stdout.flush()
