__author__ = "Dilawar Singh"
__email__ = "dilawar@subcom.tech"

# doctor module.
# Execute `bmo docter` to diagnose your system.

import json
import typing as T

from loguru import logger

import typer

app = typer.Typer()


@app.command()
def doctor() -> str:
    logger.warning("Not implemented")
    return ""


if __name__ == "__main__":
    import doctest

    doctest.testmod()
