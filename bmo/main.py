__author__ = "Dilawar Singh"
__email__ = "dilawar@subcom.tech"

from typing import Optional

from loguru import logger

import typer

app = typer.Typer()

# Local
try:
    import bmo.network
except Exception as e:
    logger.warning(f"Disabling command group 'network' because of {e}")
    app.add_typer(bmo.network.app, name="network")

import bmo.org
app.add_typer(bmo.org.app, name="org")

import bmo.doctor
app.add_typer(bmo.doctor.app, name="doctor")

import bmo.info
app.add_typer(bmo.info.app, name="info")


@app.command()
def bye(name: Optional[str] = None):
    if name:
        typer.echo(f"Bye {name}")
    else:
        typer.echo("Goodbye!")


if __name__ == "__main__":
    app()
