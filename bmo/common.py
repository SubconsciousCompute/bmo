__author__ = "Dilawar Singh"
__email__ = "dilawar@subcom.tech"

import io
import subprocess
import shutil

from pathlib import Path

from loguru import logger

import typer


def find_program(prg: str):
    """where is a given binary"""
    return shutil.which(prg)


def run_command_pipe(
    cmd: str, cwd: Path = Path.cwd(), silent: bool = False, shell: bool = False
) -> str:
    """Run a given command"""
    logger.info(f"Running `{cmd}` in {cwd}")
    proc = subprocess.Popen(cmd.split(), stdout=subprocess.PIPE, cwd=cwd, shell=shell)
    assert proc is not None
    lines = []
    for line in io.TextIOWrapper(proc.stdout, encoding="utf8"):  # type: ignore
        if not silent:
            typer.echo(f"> {line}")
        lines.append(line)
    return "".join(lines)


def run_command(
    cmd: str, cwd: Path = Path.cwd(), silent: bool = False, shell: bool = False
) -> str:
    """Run a given command"""
    logger.info(f"Running `{cmd}` in {cwd}")
    output = subprocess.check_output(cmd.split(), stdout=subprocess.PIPE, cwd=cwd, shell=shell)
    if not silent:
        typer.echo(f"> {output}")
    return output


def search_pat(pat, haystack) -> str:
    """Search for a pattern in haystack."""
    import re

    m = re.search(pat, haystack, flags=re.IGNORECASE)
    if m is not None:
        return m.group(0)
    return ""


def success(msg: str):
    typer.echo(f"👍 {msg}")


def failure(msg: str):
    typer.echo(f"👎 {msg}")
