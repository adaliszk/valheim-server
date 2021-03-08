import io
import sys

from unittest import TestCase, mock
from parameterized import parameterized
from vhpretty import VhPretty


class VhPrettyTest(TestCase):

    @parameterized.expand([
        ("none", None, ""),
        ("empty string", "", "\n"),
        ("space", " ", " \n"),
    ])
    @mock.patch('sys.stdout', new_callable=io.StringIO)
    def test_printing(self, _, message: str, expected, mock_stdout):
        VhPretty.print(message)
        self.assertEqual(expected, mock_stdout.getvalue())

    @parameterized.expand([
        ("empty line", "", None),
        ("space", " ", None),
        ("multiple spaces", "  ", None),

        ("line goes through", "Lorem ipsum dolor sit amet", "Lorem ipsum dolor sit amet"),

        ("filename debug line unix", "(Filename: consectetur/adipiscing/elit)", None),
        ("filename debug line windows", "(Filename: consectetur\\adipiscing\\elit)", None),

        ("removes date prefix iso", "2021/03/07 09:15:30: Etiam elementum et est nec ultrices", "Etiam elementum et est nec ultrices"),
        ("removes date prefix freedom", "03/07/2021 09:15:30: Praesent a ligula vestibulum", "Praesent a ligula vestibulum"),
        ("removes date prefix inverse", "07/03/2021 09:15:30: Fringilla diam eu, sagittis enim", "Fringilla diam eu, sagittis enim"),

        ("removes [Subsystems] prefix", "[Subsystems] Nam sollicitudin vehicula tincidunt", "Nam sollicitudin vehicula tincidunt"),
        ("removes dash from start", "- Nulla sed consectetur nunc", "Nulla sed consectetur nunc"),
        ("keeps dash in the text", "Donec ut - velit com-modo", "Donec ut - velit com-modo"),
    ])
    def test_parsing(self, _, line: str, expected):
        self.assertEqual(expected, VhPretty.parse(line))
