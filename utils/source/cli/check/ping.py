#  Copyright (c) 2021, Ádám Liszkai
#  Licensed under the Lesser General Public License, Version 3.0 (the "License"); this is free software,
#  and you are welcome to redistribute it under certain conditions. Unless required by applicable law
#  or agreed to in writing, the software distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OF ANY KIND, either express or implied.

from typing import Callable

import multiprocessing

from . import errors


def request(process: Callable[[int, any, str, int, int], any], args: any, timeout_time: int = 3):
    manager = multiprocessing.Manager()
    out = manager.dict()

    program = multiprocessing.Process(target=process, args=(999, out, args))

    program.start()
    program.join(timeout_time)

    if program.is_alive():
        program.kill()
        raise errors.TimeoutReached()

    for response in out.values():
        return response
