__author__ = "Dilawar Singh"
__email__ = "dilawar@subcom.tech"

# info module.
# Execute `bmo info` to print system information

import json
import typing as T

from loguru import logger

import typer

app = typer.Typer()


def which_os() -> str:
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


def which_package_manager(system: str) -> T.Optional[str]:
    logger.warning("Not implemented yet")
    return None


@app.command()
def info() -> str:
    res: T.Dict[str, str] = {}
    res["OS"] = which_os()
    assert res["OS"] in ["Windows", "Linux", "Darwin"], f"{res['OS']} is not supported"
    res["Package Manager"] = which_package_manager(res["OS"])
    return json.dumps(res)


if __name__ == "__main__":
    import doctest

    doctest.testmod()
