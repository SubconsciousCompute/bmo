__author__ = "Dilawar Singh"
__email__ = "dilawar@subcom.tech"

from typing import Optional

from loguru import logger

import typer

# Local
import bmo.network
import bmo.doctor
import bmo.info

app = typer.Typer()
app.add_typer(bmo.doctor.app, name="doctor")
app.add_typer(bmo.info.app, name="info")
app.add_typer(bmo.network.app, name="network")


@app.command()
def bye(name: Optional[str] = None):
    if name:
        typer.echo(f"Bye {name}")
    else:
        typer.echo("Goodbye!")


if __name__ == "__main__":
    app()
