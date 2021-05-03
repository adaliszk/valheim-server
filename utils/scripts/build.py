#!/usr/bin/env bash
#
# Copyright (c) 2021, Ádám Liszkai
# Licensed under the Lesser General Public License, Version 3.0 (the "License"); this is free software,
# and you are welcome to redistribute it under certain conditions. Unless required by applicable law
# or agreed to in writing, the software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OF ANY KIND, either express or implied.
#

import sys
import os

entrypoint = sys.argv[1]
workdir = os.getcwd()

source_path = os.path.join(workdir, "source")
dist_path = os.path.join(workdir, "dist")

entrypoint_file = os.path.join(source_path, entrypoint + ".py")


def clean():
    """
    Cleanup the Build artifacts
    """
    import shutil
    for path in ["build", "onefile-build", "dist"]:
        if os.path.exists(entrypoint + "." + path):
            shutil.rmtree(entrypoint + "." + path)


clean()

args = []

if os.name == "posix":
    args.append("--linux-onefile-icon {}".format(
        os.path.join(dist_path, "icon.png")
    ))

if os.name == "nt":
    args.append("--windows-onefile-tempdir")

# Build
# os.system("python -m nuitka --standalone {}".format(entrypoint_file))
os.system("python -m nuitka --onefile {} {}".format(" ".join(args), entrypoint_file))

# Save bundle
bundle_file = entrypoint + (".exe" if os.name == 'nt' else ".bin")
dist_file = os.path.join(dist_path, entrypoint + (".exe" if os.name == 'nt' else ""))
os.rename(bundle_file, dist_file)

clean()
