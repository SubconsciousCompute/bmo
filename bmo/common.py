__author__ = "Dilawar Singh"
__email__ = "dilawar@subcom.tech"

import io
import sys
import subprocess
import shutil
import logging
import platform

import typing as T

from pathlib import Path

import typer


def system() -> T.Tuple[str, str]:
    return (platform.system(), sys.platform)


def is_windows(cygwin_is_windows: bool = True) -> bool:
    """Check if we are running on windows.

    Parameters
    ----------
        cygwin_is_windows : (default `True`). When set to `True`, consider cygwin as Windows.

    Returns
    -------
    `True` if on Windows, `False` otherwise.
    """
    _sys = system()
    if _sys[0].startswith("windows"):
        return True
    return cygwin_is_windows and _sys[1] == "cygwin"


def find_program(prg: str):
    """where is a given binary"""
    return shutil.which(prg)


def run_command_pipe(
    cmd: str, cwd: Path = Path.cwd(), silent: bool = False, shell: bool = False
) -> str:
    """Run a given command"""
    logging.info(f"Running `{cmd}` in {cwd}")
    proc = subprocess.Popen(cmd.split(), cwd=cwd, shell=shell, text=True)
    assert proc is not None
    lines = []
    for line in io.TextIOWrapper(proc.stdout, encoding="utf8"):  # type: ignore
        if not silent:
            typer.echo(f"> {line}")
        lines.append(line)
    return "".join(lines)


def run_command(cmd: str, cwd: Path = Path.cwd(), silent: bool = False) -> str:
    """Run a given command"""
    logging.info(f"Running `{cmd}` in {cwd}")
    p = subprocess.run(cmd.split(), cwd=cwd, capture_output=True, check=True, text=True)
    output = p.stdout + p.stderr
    if not silent:
        typer.echo(f"> {output}")
    return output


def search_pat(pat, haystack):
    """Search for a pattern in haystack."""
    import re

    return re.search(pat, haystack, flags=re.IGNORECASE)


def success(msg: str):
    typer.echo(f"👍 {msg}")


def failure(msg: str):
    typer.echo(f"👎 {msg}")
