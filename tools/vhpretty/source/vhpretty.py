import sys
import re
from typing import Union


class VhPretty:

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    def parse(self, line: str) -> Union[str, None]:
        line = self.remove_noise(line)
        if line is not None:
            line = self.prefix_severity(line)
        return line

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    def remove_noise(self, line: str) -> Union[str, None]:

        # ignore empty lines
        if re.search(r'^\s*$', line):
            return None

        # ignore Debug lines with (Filename: ...)
        if re.search(r'^\(Filename:', line):
            return None

        # trim multiples spaces into one
        multiple_spaces = re.compile(r'\s+')
        if re.search(multiple_spaces, line):
            line = re.sub(multiple_spaces, r' ', line)

        # remove DATETIME prefix as this is added outside of the STDOUT
        date_prefix = re.compile(r'^\d+/\d+/\d+ \d+:\d+:\d+:\s*', re.IGNORECASE)
        if re.search(date_prefix, line):
            line = re.sub(date_prefix, r'', line)

        # remove Noisy prefixes
        noisy_prefix = re.compile(r'^(\[Subsystems]|-)\s*', re.IGNORECASE)
        if re.search(noisy_prefix, line):
            line = re.sub(noisy_prefix, r'', line)

        # remove WHITESPACE and format the line to look nice
        line = self.ucfirst(line.strip())
        return line

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    def prefix_severity(self, line: str) -> Union[str, None]:

        prefix = "I"

        debug_triggers = re.compile(r'^(Base:|Redirecting to)', re.IGNORECASE)
        if re.search(debug_triggers, line):
            prefix = "D"

        warning_triggers = re.compile(r'(Warning|Failed|Missing|Fallback)', re.IGNORECASE)
        if re.search(warning_triggers, line):
            prefix = "W"

        error_triggers = re.compile(r'Error', re.IGNORECASE)
        if re.search(error_triggers, line):
            prefix = "E"

        return prefix + "> " + line

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    @staticmethod
    def print(message: Union[str, None]) -> None:
        # only send something to the console if there is something
        if message is not None:
            print(message)
            sys.stdout.flush()
        pass

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    @staticmethod
    def ucfirst(text: str):
        if text is None or len(text) < 2:
            return ""

        return text[0].upper() + text[1:]
