#  Copyright (c) 2021, Ádám Liszkai
#  Licensed under the Lesser General Public License, Version 3.0 (the "License"); this is free software,
#  and you are welcome to redistribute it under certain conditions. Unless required by applicable law
#  or agreed to in writing, the software distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OF ANY KIND, either express or implied.

import click


def host():
    return click.option(
        "--host", "-H", type=str, envvar="VALHEIM_HOST",
        help="Specify the address to use for the test. \n"
             "[env: VALHEIM_HOST]",
        show_default=True,
        default="0.0.0.0",
    )


def port(label: str, default: int = 2456):
    port_help = "Port to use for the {}"
    return click.option(
        "--port", "-P", type=int,
        help=port_help.format(label),
        show_default=True,
        default=default,
    )


server_attributes = {
    "id": "steam_id",
    "name": "server_name",
    "version": "keywords",
    "game": "game_id",
    "max_players": "max_players",
    "player_count": "player_count",
    "ping": "ping",
    "rtt": "rtt",
}


def limit_server_attributes():
    return click.option(
        '--only', '-O', "attr",
        type=click.Choice(list(server_attributes.keys()), case_sensitive=False),
        help="Only show the value of the given property"
    )


def deadline():
    return click.option(
        "--deadline", "-w", type=int,
        help="Time to wait for a response, in seconds. "
             "The maximum amount of time to wait for any response from the connection that can be "
             "the response answered or some error notification from the network itself. ",
        show_default=True,
        default=3,
    )


def timeout():
    return click.option(
        "--timeout", "-W", type=int,
        help="Time to wait for a connection, in seconds. "
             "Affects only the timeout for making the initial connection. ",
        show_default=True,
        default=3,
    )
