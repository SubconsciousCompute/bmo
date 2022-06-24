__author__ = "Dilawar Singh"
__email__ = "dilawar@subcom.tech"


import logging
import typing as T
from pathlib import Path

import bmo.common

import typer

app = typer.Typer()


def determine_lang_tools(dir: Path) -> T.Dict[str, str]:
    """Find a suitable linter in the current directory."""
    res = dict()
    if (dir / "pyproject.toml") or (dir / "setup.py"):
        res["lang"] = "python"
        res["linter"] = "mypy"
    else:
        logging.warning("Failed to determine language and tooling.")
    return res


@app.command()
def mypy(sdir: Path = Path("src")):
    """Run mypy linter in given directory"""
    logging.info(f"Running mypy in {sdir}")
    assert sdir.exists(), "f{sdir} doesn't exists"
    bmo.common.run_command(
        f"poetry run mypy --ignore-missing-imports --install-types --non-interactive {str(sdir)}"
    )


@app.command("gi")
def generate_gitignore(args: T.List[str] = [], force: bool = False):
    """Create gitignore file"""
    import requests

    cwd = Path.cwd().resolve()
    if not (cwd / ".git").exists():
        logging.warning(f"{cwd} is not a git repository?")

    gitignorefile = cwd / ".gitignore"

    if len(args) == 0:
        args = [determine_lang_tools(cwd).get("lang", "")]

    assert (
        len(args) > 0
    ), f"Could not automatically compute the API params.  Please pass using `--args` option."

    endpoint = ",".join(args)
    url = f"https://www.toptal.com/developers/gitignore/api/{endpoint}"
    logging.info(f"Fetching .gitignore content for {url}")

    res = requests.get(f"{url}")
    if not gitignorefile.exists() or force:
        with gitignorefile.open("w") as f:
            f.write(res.text)
        return

    typer.echo(res.text)
    logging.warning(
        f"{gitignorefile} exists. Use `--force` to overwrite. I am displaying the content of .gitignore to console."
    )


@app.command()
def lint(linter: str = "", dir: T.Optional[Path] = None):
    """Run a linter. If one is not given, pick one."""
    if dir is None:
        dir = Path.cwd()

    if not linter:
        linter = determine_lang_tools(dir).get("linter", "")
        logging.info(f"Automaticaly selecting linter '{linter}'")

    if linter == "mypy":
        mypy(dir)


if __name__ == "__main__":
    import doctest

    doctest.testmod()
