__author__ = "Dilawar Singh"
__email__ = "dilawar@subcom.tech"

# doctor module.
# Execute `bmo docter` to diagnose your system.

import json
import typing as T

from loguru import logger

import typer

app = typer.Typer()

def check_os() -> str:
    """Return the current operating system."""
    import platform

    return platform.system()

def get_like_distro():
    """Get the Linux distro.

    Note: Requires Python3.10
    """
    info = platform.freedesktop_os_release()
    ids = [info["ID"]]
    if "ID_LIKE" in info:
        # ids are space separated and ordered by precedence
        ids.extend(info["ID_LIKE"].split())
    return ids


@app.command()
def doctor() -> str:
    res: T.Dict[str, str] = {}
    res["OS"] = which_os()
    assert res["OS"] in ["Windows", "Linux", "Darwin"], f"{res['OS']} is not supported"
    res["Package Manager"] = which_package_manager(res["OS"])
    return json.dumps(res)


if __name__ == "__main__":
    import doctest

    doctest.testmod()
