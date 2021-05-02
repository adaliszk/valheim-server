#  Copyright (c) 2021, Ádám Liszkai
#  Licensed under the Lesser General Public License, Version 3.0 (the "License"); this is free software,
#  and you are welcome to redistribute it under certain conditions. Unless required by applicable law
#  or agreed to in writing, the software distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OF ANY KIND, either express or implied.

import click
import sys

from . import options
from . import query
from . import rpc


@click.group(
    name="check",
    help="Check your Valheim Server availability and health"
)
# @TODO: Share the flags with the global scope
# @options.host()
# @options.deadline()
# @options.timeout()
def cli(**kwargs):
    pass


@cli.command(
    name="query",
    help="Talk with the Master Server Query Port",
)
@options.host()
@options.port("Master Server Query", default=2457)
@options.timeout()
@options.deadline()
@options.limit_server_attributes()
def query_check(**kwargs):
    info = query.info(
        host=kwargs.get("host"), port=kwargs.get("port"),
        deadline_time=kwargs.get("deadline"),
        timeout_time=kwargs.get("timeout"),
    )

    only_attr = kwargs.get("attr")

    if only_attr:
        attr = options.server_attributes[only_attr]
        click.echo(getattr(info, attr))
        return 0

    for key in list(options.server_attributes.keys()):
        attr = options.server_attributes[key]
        click.echo("{}: {}".format(key, getattr(info, attr)))


@cli.command(
    name="rpc",
    help="Talk with the Steamworks Network Port  \n\n"
         "Send a k_ESteamNetworkingUDPMsg_ConnectionClosed packet to the server  \n"
         "that should return a k_ESteamNetworkingUDPMsg_NoConnection.  \n\n"
         "Special thanks to: Mark Mäkinen, aka @Z1ni",
)
@options.host()
@options.port("Steamworks Network RPC", default=2456)
@options.timeout()
@options.deadline()
def rpc_check(**kwargs):
    try:
        response_time = rpc.rtt(
            host=kwargs.get("host"), port=kwargs.get("port"),
            deadline_time=kwargs.get("deadline"),
            timeout_time=kwargs.get("timeout"),
        )
        click.echo(response_time)
    except rpc.DeadlineReached or rpc.TimeoutReached as err:
        click.echo(err.message)
        sys.exit(1)
