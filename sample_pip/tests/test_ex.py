from src import example

import unittest

class TestCase(unittest.TestCase):

    def test_add1(self):
        assert example.add_func(5,5) == 10

    def test_add2(self):
        assert example.add_func(5,10) == 15
