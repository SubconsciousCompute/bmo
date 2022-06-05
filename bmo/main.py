__author__ = "Dilawar Singh"
__email__ = "dilawar@subcom.tech"

from typing import Optional

from loguru import logger

import typer

# Local
import bmo.network

app = typer.Typer()
app.add_typer(bmo.network.app, name="network")
app.add_typer(bmo.doctor.app, name="doctor")


@app.command()
def bye(name: Optional[str] = None):
    if name:
        typer.echo(f"Bye {name}")
    else:
        typer.echo("Goodbye!")


if __name__ == "__main__":
    app()
