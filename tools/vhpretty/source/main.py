#!/usr/bin/env python3

# VALHEIM CONSOLE
# this script is intended to clean the otherwise quite noisy Valheim server's
# output by transforming each line to a more understandable format

import os
import sys

import fileinput

from vhpretty import VhPretty


LOG_PATH = os.environ.get('LOG_PATH')
stdin = sys.stdin.reconfigure(encoding='utf-8', errors='ignore')


for line in fileinput.input():
    parsed_line = VhPretty.parse(line)
    VhPretty.print(parsed_line)
