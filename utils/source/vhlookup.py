#!/usr/bin/env python3

#  Copyright (c) 2021, Ádám Liszkai
#  Licensed under the Lesser General Public License, Version 3.0 (the "License"); this is free software,
#  and you are welcome to redistribute it under certain conditions. Unless required by applicable law
#  or agreed to in writing, the software distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OF ANY KIND, either express or implied.

import click

from cli import copyright, check
import cli.copyright as license

import git


@click.group(
    help="{intro}\n\n{notice}\n\n{info}\n\nSource: {source}".format(
        intro="Lookup Valheim Server Ports and check if they are really working.  \n"
              "Special thanks to: Mark Mäkinen, aka @Z1ni",
        notice=license.notice(),
        info=license.info(),
        source=git.origin,
    ),
)
def cli(**kwargs):
    pass


if __name__ == '__main__':
    cli.add_command(copyright.cli)
    cli.add_command(check.cli)
    cli()
