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


def determine_lang_tools(dir: Path) -> T.Dict[str, str]:
    """Find a suitable linter in the current directory."""
    res = dict()
    if (dir / "pyproject.toml") or (dir / "setup.py"):
        res["lang"] = "python"
        res["linter"] = "mypy"
    else:
        logger.warning("Failed to determine language and tooling.")
    return res


def run_command(cmd: str, cwd: Path = Path.cwd(), silent: bool = False) -> int:
    """Run a given command"""
    logger.info(f"Running `{cmd}` in {cwd}")
    proc = subprocess.Popen(cmd.split(), stdout=subprocess.PIPE, cwd=cwd)
    assert proc is not None
    for line in io.TextIOWrapper(proc.stdout, encoding="utf8"):  # type: ignore
        typer.echo(f"> {line}")
    return 0


@app.command()
def mypy(dir: Path = Path("src")):
    """Run mypy linter in given directory"""
    logger.info(f"Running mypy in {dir}")
    assert dir.exists(), "f{dir} doesn't exists"
    assert 0 == run_command(
        f"{sys.executable} -m mypy --ignore-missing-imports --install-types --non-interactive {str(dir)}"
    )


@app.command("gi")
def generate_gitignore(args: T.List[str] = [], force: bool = False):
    """Create gitignore file"""
    import requests

    cwd = Path.cwd().resolve()
    if not (cwd / ".git").exists():
        logger.warning(f"{cwd} is not a git repository?")

    gitignorefile = cwd / ".gitignore"
    logger.info(f"Getting gitignore for {args}")

    if len(args) == 0:
        args = [determine_lang_tools(cwd).get("lang", "")]

    assert (
        len(args) > 0
    ), f"Could not automatically compute the API params.  Please pass using `--args` option."
    endpoint = ",".join(args)

    url = "https://www.toptal.com/developers/gitignore/api/"
    res = requests.get(f"{url}/{endpoint}")
    if not gitignorefile.exists() or force:
        with gitignorefile.open("w") as f:
            f.write(res.text)
        return
    logger.warning(
        f"{gitignorefile} exists. Use `--force` to overwrite. I am going to write to stdout"
    )
    typer.echo(res.text)


@app.command()
def lint(linter: str = "", dir: T.Optional[Path] = None):
    """Run a linter. If one is not given, pick one."""
    if dir is None:
        dir = Path.cwd()

    if not linter:
        linter = determine_lang_tools(dir).get("linter", "")
        logger.info(f"Automaticaly selecting linter '{linter}'")

    if linter == "mypy":
        mypy(dir)


if __name__ == "__main__":
    import doctest

    doctest.testmod()
