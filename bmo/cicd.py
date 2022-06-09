__author__           = "Dilawar Singh"
__email__            = "dilawar@subcom.tech"


import sys
import json
import platform
import typing as T

from loguru import logger

import typer

app = typer.Typer()


@app.command("runner")
def run_gitlab_runner():
    """Run gitlab-runner """



if __name__ == "__main__":
    import doctest

    doctest.testmod()
