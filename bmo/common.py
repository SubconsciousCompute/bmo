__author__ = "Dilawar Singh"
__email__ = "dilawar@subcom.tech"

import io
import sys
import subprocess
import shutil
import glob
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


def find_program(
    name: str, hints: list[T.Union[Path, str]] = [], recursive: bool = False
) -> T.Optional[str]:
    """where is a given binary"""
    for hint in hints:
        hint = Path(hint).resolve()
        if not hint.exists():
            continue
        for p in glob.glob(f"{hint}/**/{name}", recursive=recursive):
            if (prg := shutil.which(p)) is not None:
                return prg
    return shutil.which(name)


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


def run_command(
    cmd: str, cwd: Path = Path.cwd(), silent: bool = False, stream: bool = True
) -> str:
    """Run a given command.

    Parameters
    ----------
    cmd : str
        cmd
    cwd : Path
        Current working directory.
    silent : bool
        If `True`, output is not printed onto console.
    stream : bool
        If `True` the output is printed line by line eagerly (as soon as a line is available)
        rather than all at once.

    Returns
    -------
    str

    Credits
    --------
    1. https://stackoverflow.com/questions/18421757/live-output-from-subprocess-command
    """
    logging.debug(f"Running `{cmd}` in {cwd}")
    p = subprocess.Popen(
        cmd.split(),
        cwd=str(cwd),
        text=True,
        stdout=subprocess.STDOUT,
        stderr=subprocess.STDOUT,
    )
    lines = []
    if p.stdout is not None:
        for line in iter(p.stdout.readline, ""):
            if line is None:
                break
            lines.append(f"> {line}")
            if stream and not silent:
                typer.echo(f"> {line}")

    output = "\n".join(lines)
    if not silent:
        typer.echo(f"> {output}")
    return output


def search_pat(pat, haystack):
    """Search for a pattern in haystack."""
    import re

    return re.search(pat, haystack, flags=re.IGNORECASE)


def success(msg: str):
    typer.echo(f":) {msg}")


def failure(msg: str):
    typer.echo(f":( {msg}")
