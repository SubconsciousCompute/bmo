__author__ = "Dilawar Singh"
__email__ = "dilawar@subcom.tech"


import sys
import io
import subprocess

import typing as T
from loguru import logger

from pathlib import Path

import typer

app = typer.Typer()

def determine_linter(dir: Path) -> str:
    """Find a suitable linter in the current directory.
    """
    if (dir / 'pyproject.toml') or (dir / "setup.py"):
        return "mypy"
    return ""

@app.command()
def mypy(dir: Path = Path("src")):
    """Run mypy linter in given directory"""
    logger.info(f"Running mypy in {dir}")
    assert dir.exists(), "f{dir} doesn't exists"
    proc = subprocess.Popen(
        [
            sys.executable,
            "-m",
            "mypy",
            "--ignore-missing-imports",
            "--install-types",
            "--non-interactive",
            str(dir),
        ],
        stdout=subprocess.PIPE,
    )
    assert proc is not None
    for line in io.TextIOWrapper(proc.stdout, encoding="utf8"): # type: ignore
        typer.echo(f"> {line}")

@app.command()
def lint(linter: str="", dir:T.Optional[Path] = None):
    """Run a linter. If one is not given, pick one."""
    if dir is None:
        dir = Path.cwd()

    if not linter:
        linter = determine_linter(dir)
        logger.info(f"Automaticaly selecting linter {linter}")

    if linter == "mypy":
        mypy(dir)


if __name__ == "__main__":
    import doctest

    doctest.testmod()
