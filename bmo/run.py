__author__           = "Dilawar Singh"
__email__            = "dilawar@subcom.tech"


import sys
import json
import platform
import typing as T

from loguru import logger

import typer

app = typer.Typer()

@app.command()
def mypy() -> str:
    logger.info("Running mypy")


if __name__ == "__main__":
    import doctest

    doctest.testmod()
