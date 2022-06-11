import pytest
import bmo.network


def test_network():
    bmo.network.check_ssl("https://subcom.link")
