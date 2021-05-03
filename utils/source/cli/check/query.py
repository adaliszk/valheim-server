#  Copyright (c) 2021, Ádám Liszkai
#  Licensed under the Lesser General Public License, Version 3.0 (the "License"); this is free software,
#  and you are welcome to redistribute it under certain conditions. Unless required by applicable law
#  or agreed to in writing, the software distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OF ANY KIND, either express or implied.

import a2s

from socket import *
import time

from . import errors
from . import ping


def info(pid: int, out: str, args: any):
    host, port, deadline_time = args
    address = (host, port)

    try:
        packet_sent_at = time.time()
        data = a2s.info(address, timeout=deadline_time)
        response_received_at = time.time()

        out[pid] = {
            "rtt": response_received_at - packet_sent_at,
            "data": data,
        }
    except timeout as err:
        raise errors.DeadlineReached()
    except gaierror as err:
        raise errors.InvalidRequest("{}".format(err.strerror))


def rtt(host: str = "0.0.0.0", port: int = 2456, timeout_time: int = 3, deadline_time: int = 3):
    resp = ping.request(info, (host, port, deadline_time), timeout_time)

    if resp is None:
        raise errors.InvalidResponse(resp)

    return resp
