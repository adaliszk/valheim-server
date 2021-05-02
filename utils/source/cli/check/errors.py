#  Copyright (c) 2021, Ádám Liszkai
#  Licensed under the Lesser General Public License, Version 3.0 (the "License"); this is free software,
#  and you are welcome to redistribute it under certain conditions. Unless required by applicable law
#  or agreed to in writing, the software distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OF ANY KIND, either express or implied.


class InvalidResponse(Exception):
    def __init__(self, message):
        self.message = "rpc_InvalidResponse"
        if message:
            self.message += ":0x{}".format(message)


class TimeoutReached(Exception):
    def __init__(self):
        self.message = "rpc_TimeoutReached"


class DeadlineReached(Exception):
    def __init__(self):
        self.message = "rpc_DeadlineReached"
