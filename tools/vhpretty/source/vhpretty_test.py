import io
import sys

from unittest import TestCase, mock
from parameterized import parameterized
from vhpretty import VhPretty


class VhPrettyTest(TestCase):

    @parameterized.expand([
        ("nothing when None is passed", None, ""),
        ("works with empty string", "", "\n"),
        ("works with a whitespace", " ", " \n"),
    ])
    @mock.patch('sys.stdout', new_callable=io.StringIO)
    def test_that_printing(self, _, message: str, expected, mock_stdout):
        VhPretty.print(message)
        self.assertEqual(expected, mock_stdout.getvalue())

    @parameterized.expand([
        ("does not break on None", None, ""),
        ("does not break on empty string", "", ""),
        ("converts lowercase word", "dolor", "Dolor"),
        ("does nothing on ucfirst word", "Lorem", "Lorem"),
        ("does nothing on a sentence", "Lorem ipsum dolor sit amet.", "Lorem ipsum dolor sit amet."),
        ("converts first word if starts with lowercase", "praesent a ligula vestibulum.", "Praesent a ligula vestibulum."),
    ])
    def test_ucfirst_helper_that(self, _, text: str, expected):
        self.assertEqual(expected, VhPretty.ucfirst(text))

    @parameterized.expand([
        ("removing empty line", "", None),
        ("removing whitespace line", " ", None),
        ("removing whitespace line no matter the length (2)", "  ", None),
        ("removing whitespace line no matter the length (5)", "     ", None),
        ("removing whitespace line no matter the length (12)", "            ", None),

        ("replaces multiple spaces with one", "Pellentesque  vitae   venenatis    justo", "I> Pellentesque vitae venenatis justo"),

        ("normal line goes through", "Lorem ipsum dolor sit amet", "I> Lorem ipsum dolor sit amet"),

        ("removes filename debug line unix", "(Filename: consectetur/adipiscing/elit)", None),
        ("removes filename debug line windows", "(Filename: consectetur\\adipiscing\\elit)", None),

        ("removes date prefix iso", "2021/03/07 09:15:30: Etiam elementum et est nec ultrices", "I> Etiam elementum et est nec ultrices"),
        ("removes date prefix freedom", "03/07/2021 09:15:30: Praesent a ligula vestibulum", "I> Praesent a ligula vestibulum"),
        ("removes date prefix inverse", "07/03/2021 09:15:30: Fringilla diam eu, sagittis enim", "I> Fringilla diam eu, sagittis enim"),

        ("removes [Subsystems] prefix", "[Subsystems] Nam sollicitudin vehicula tincidunt", "I> Nam sollicitudin vehicula tincidunt"),
        ("removes dash from start", "- Nulla sed consectetur nunc", "I> Nulla sed consectetur nunc"),
        ("keeps dash in the text", "Donec ut - velit com-modo", "I> Donec ut - velit com-modo"),
    ])
    def test_that_parsing_cleans_the_output_by(self, _, line: str, expected):
        pretty = VhPretty()
        self.assertEqual(expected, pretty.parse(line))

    @parameterized.expand([
        ("adding I prefix for the lines", "Lorem ipsum dolor sit amet", "I> Lorem ipsum dolor sit amet"),
        ("adding W prefix for lines with warning", "Warning: Nam sollicitudin", "W> Warning: Nam sollicitudin"),
        ("adding W prefix for lines with failed", "Nam sollicitudin Failed consectetur nunc", "W> Nam sollicitudin Failed consectetur nunc"),
        ("adding W prefix for lines with missing", "Praesent a ligula missing!", "W> Praesent a ligula missing!"),
        ("adding E prefix for lines with error", "Error: Vehicula tincidunt", "E> Error: Vehicula tincidunt"),
    ])
    def test_that_parsing_formats_the_output_by(self, _, line: str, expected):
        pretty = VhPretty()
        self.assertEqual(expected, pretty.parse(line))
