__author__           = "Dilawar Singh"
__email__            = "dilawar@subcom.tech"

import io
import subprocess

from pathlib import Path

from loguru import logger

import typer

# Common functions.

def run_command(cmd: str, cwd: Path = Path.cwd(), silent: bool = False) -> int:
    """Run a given command"""
    logger.info(f"Running `{cmd}` in {cwd}")
    proc = subprocess.Popen(cmd.split(), stdout=subprocess.PIPE, cwd=cwd)
    assert proc is not None
    if not silent:
        for line in io.TextIOWrapper(proc.stdout, encoding="utf8"):  # type: ignore
            typer.echo(f"> {line}")
    return 0

