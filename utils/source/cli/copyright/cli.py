#  Copyright (c) 2021, Ádám Liszkai
#  Licensed under the Lesser General Public License, Version 3.0 (the "License"); this is free software,
#  and you are welcome to redistribute it under certain conditions. Unless required by applicable law
#  or agreed to in writing, the software distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OF ANY KIND, either express or implied.

import click

from . import license


@click.group(
    name="show",
    help="Details about Licenses and Copyright information",
)
def cli(**kwargs):
    pass


@cli.command(
    help="Print License conditions.",
)
def conditions():
    click.echo(license.conditions())


@cli.command(
    help="Print Warranty details.",
)
def warranty():
    click.echo(license.warranty())


# noinspection PyShadowingBuiltins
@cli.command(
    help="Print out the full License to read.",
)
def license():
    click.echo(license.copy())


@cli.command(
    help="Print license notifications from 3rd parties.",
)
def notices():
    click.echo("License for this program:")
    click.echo("{}\n{}.\n".format(license.notice(), license.name()))

    click.echo("Other licenses:")
    copyright()
