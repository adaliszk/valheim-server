#!/usr/bin/env python3

#  Copyright (c) 2021, Ádám Liszkai
#  Licensed under the Lesser General Public License, Version 3.0 (the "License"); this is free software,
#  and you are welcome to redistribute it under certain conditions. Unless required by applicable law
#  or agreed to in writing, the software distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OF ANY KIND, either express or implied.

import click

from source.cli.copyright import license
from source.cli.shared import options

from source.cli import fwl


@click.group(
    help="{intro}\n\n{copyright}\n\n{license}".format(
        intro="Manage your Valheim Data files efficiently and easily",
        copyright=license.Copyright,
        license=license.Notice,
    )
)
@options.path
def cli(**kwargs):
    pass


if __name__ == '__main__':
    cli.add_command(fwl.cli)
    cli()
