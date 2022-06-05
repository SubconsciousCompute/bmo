__author__ = "Dilawar Singh"
__email__ = "dilawar@subcom.tech"

# info module.
# Execute `bmo info` to print system information

import sys
import json
import platform
import typing as T

from loguru import logger

import typer

app = typer.Typer()


def which_os() -> str:
    """Return the current operating system."""
    import platform

    return platform.system()


def get_like_distro() -> T.List[str]:
    """Get the Linux distro."""
    if int(sys.version_info[1]) >= 10:
        # FIXME: Requires Python3.10
        info = platform.freedesktop_os_release()  # type: ignore # pylint: disable=no-member
        ids = [info["ID"]]
        if "ID_LIKE" in info:
            # ids are space separated and ordered by precedence
            ids.extend(info["ID_LIKE"].split())
        return ids
    return []


def which_package_manager(system: str) -> T.Optional[str]:
    logger.warning("Not implemented yet")
    return None


@app.command()
def system() -> str:
    res: T.Dict[str, str] = {}
    res["OS"] = which_os()
    assert res["OS"] in ["Windows", "Linux", "Darwin"], f"{res['OS']} is not supported"
    res["Package Manager"] = str(which_package_manager(res["OS"]))
    _json = json.dumps(res)
    typer.echo(_json)
    return _json


if __name__ == "__main__":
    import doctest

    doctest.testmod()
