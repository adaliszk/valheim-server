#  Copyright (c) 2021, Ádám Liszkai
#  Licensed under the Lesser General Public License, Version 3.0 (the "License"); this is free software,
#  and you are welcome to redistribute it under certain conditions. Unless required by applicable law
#  or agreed to in writing, the software distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OF ANY KIND, either express or implied.

# Valheim Game Networking Socket checker
# Thanks to @Z1ni

from socket import *

import time
import re

from . import errors
from . import ping


def rpc(pid: int, out: str, args: any):
    host, port, deadline_time = args

    # Establish a connection
    sock = socket(AF_INET, SOCK_DGRAM)
    sock.settimeout(deadline_time)

    # Create k_ESteamNetworkingUDPMsg_ConnectionClosed packet with zero "to_connection_id".
    pkt = b"\x24\x05\x00\x25\x00\x00\x00\x00"
    #        ^   ^---^   ^   ^-----------^
    #        |   |   |   |
    #        |   |   |  32-bit "to_connection_id"
    #        |   |   |
    #        |   |  Protobuf field ID (0 0100 101)
    #        |   |                        ^    ^
    #        |   |                        |    |
    #        |   |                        |   Wire type (5, 32-bit (fixed32))
    #        |   |                       Field number (4)
    #        |  Message length (Little endian)
    #       Message ID (ConnectionClosed)

    # we need to pad the Valheim packets to 512 byte length
    pkt = pkt + (b"\x00" * (512 - len(pkt)))

    try:
        # Send the Packet
        packet_sent_at = time.time()
        sock.sendto(pkt, (host, port))

        # get the response's first meaningful Byte
        resp, _ = sock.recvfrom(16)
        response_received_at = time.time()

        if re.match(b"^\xFF\xFF\xFF\xFF", resp):
            resp = re.sub(b"^\xFF\xFF\xFF\xFF", b"", resp)
        resp = resp[:1]

        # the server should respond with a k_ESteamNetworkingUDPMsg_NoConnection
        if not re.match(b"\x25", resp):
            raise errors.InvalidResponse(resp.hex())

        out[pid] = response_received_at - packet_sent_at
    except timeout:
        raise errors.DeadlineReached()


def rtt(host: str = "0.0.0.0", port: int = 2456, timeout_time: int = 3, deadline_time: int = 3):
    return ping.request(rpc, (host, port, deadline_time), timeout_time)
