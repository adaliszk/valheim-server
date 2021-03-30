#!/usr/bin/env python3

import sys
import fileinput
import datetime

stdin = sys.stdin.reconfigure(encoding='utf-8', errors='ignore')


def echo(message: str):
    print(message.strip())
    sys.stdout.flush()


for line in fileinput.input():
    timestamp = datetime.datetime.now().isoformat()
    echo(timestamp + "> " + line.strip())
