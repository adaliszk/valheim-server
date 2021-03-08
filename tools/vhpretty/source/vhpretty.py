import sys
import re
from typing import Union


class VhPretty:

    @staticmethod
    def parse(line: str) -> Union[str, None]:

        # ignore empty lines
        if re.match(r'^\s*$', line):
            return None

        # ignore Debug lines with (Filename: ...)
        if re.match(r'^\(Filename:', line):
            return None

        # remove DATETIME prefix as this is added outside of the STDOUT
        date_prefix = re.compile(r'^\d+/\d+/\d+ \d+:\d+:\d+:\s*', re.IGNORECASE)
        if re.match(date_prefix, line):
            line = re.sub(date_prefix, r'', line)

        # remove Noisy prefixes
        noisy_prefix = re.compile(r'^(\[Subsystems]|-)\s*', re.IGNORECASE)
        if re.match(noisy_prefix, line):
            line = re.sub(noisy_prefix, r'', line)

        return line

    @staticmethod
    def print(message: Union[str, None]) -> None:

        # only send something to the console if there is something
        if message is not None:
            print(message)
            sys.stdout.flush()

        pass
