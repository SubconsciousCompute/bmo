__author__ = "Dilawar Singh"
__email__ = "dilawar@subcom.tech"

import bmo.network


def test_network():
    bmo.network.check_ssl("https://subcom.link")
