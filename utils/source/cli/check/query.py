#  Copyright (c) 2021, Ádám Liszkai
#  Licensed under the Lesser General Public License, Version 3.0 (the "License"); this is free software,
#  and you are welcome to redistribute it under certain conditions. Unless required by applicable law
#  or agreed to in writing, the software distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OF ANY KIND, either express or implied.

import a2s
import signal

from socket import *

from . import errors


def info(host: str = "0.0.0.0", port: int = 2456, timeout_time: int = 3, deadline_time: int = 3):
    address = (host, port)

    def timeout_handler(signum, frame):
        raise errors.TimeoutReached()

    signal.signal(signal.SIGALRM, timeout_handler)
    signal.alarm(timeout_time)

    try:
        response_info = a2s.info(address, timeout=deadline_time)
        signal.alarm(0)
        return response_info
    except timeout:
        raise errors.DeadlineReached()
