#!/usr/bin/env python3

# Valheim/Valve Game Networking Sockets server online checker
# Thanks to @Z1ni

import re
import socket
import sys

steam_msg = {
    "a2s_Info": b"\xFF\xFF\xFF\xFF\x54\x53\x6F\x75\x72\x63\x65\x20\x45\x6E\x67\x69\x6E\x65\x20\x51\x75\x65\x72\x79\x00",
    b"\xFF\xFF\xFF\xFF\x54\x53\x6F\x75\x72\x63\x65\x20\x45\x6E\x67\x69\x6E\x65\x20\x51\x75\x65\x72\x79\x00": "a2s_Info",

    "a2s_ServerInfo": b"\x49",
    b"\x49": "a2s_ServerInfo",

    "k_ESteamNetworkingUDPMsg_ConnectionClosed": b"\x24\x05\x00\x25\x00\x00\x00\x00",
    b"\x24\x05\x00\x25": "k_ESteamNetworkingUDPMsg_ConnectionClosed",

    "k_ESteamNetworkingUDPMsg_NoConnection": b"\x25",
    b"\x25": "k_ESteamNetworkingUDPMsg_NoConnection",
}


class InvalidResponse(Exception):
    def __init__(self, message):
        self.message = "s_InvalidResponse"
        if message:
            self.message += ":0x{}".format(message)


def send(port: str, msg: str):
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    pkt = steam_msg.get(msg, b"\x00")

    if re.match(r"^k_", msg):
        pkt = pkt + (b"\x00" * (512 - len(pkt)))

    # Send to the server
    sock.sendto(pkt, ("localhost", int(port)))
    sock.settimeout(1)
    resp, _ = sock.recvfrom(16)

    if re.match(b"^\xFF\xFF\xFF\xFF", resp):
        resp = re.sub(b"^\xFF\xFF\xFF\xFF", b"", resp)
    resp = resp[:1]

    if resp == steam_msg.get("k_ESteamNetworkingUDPMsg_NoConnection", b"\x00"):
        return "k_ESteamNetworkingUDPMsg_NoConnection"

    if resp == steam_msg.get("a2s_ServerInfo"):
        return "a2s_ServerInfo"

    raise InvalidResponse(resp.hex())


if __name__ == "__main__":
    try:
        print(send(sys.argv[1], sys.argv[2]))
    except InvalidResponse or timeout as err:
        print(err.message)
        sys.exit(1)