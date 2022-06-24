# Organization level module.

__author__ = "Dilawar Singh"
__email__ = "dilawar@subcom.tech"

import typing as T
import logging

from pathlib import Path

import typer

app = typer.Typer()


@app.command()
def backup(service: str, token: str = "", outdir: T.Optional[Path] = None):
    logging.info(f"backing up {service}")
    if service == "notion":
        from bmo.helpers.notion import Notion

        n = Notion(token)
        try:
            n.backup(outdir)
        except Exception as e:
            logging.warning(f"Failed to create backup because of {e}")
    else:
        raise NotImplementedError(f"{service} is not supported yet")


if __name__ == "__main__":
    import doctest

    doctest.testmod()
