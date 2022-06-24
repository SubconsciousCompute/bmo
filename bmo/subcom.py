__author__ = "Dilawar Singh"
__email__ = "dilawar@subcom.tech"


import tempfile
import requests
import logging

from pathlib import Path

from bmo.common import run_command

import typer

app = typer.Typer()


@app.command("script")
def download_and_run_script(
    script: str, force: bool = False, download_only: bool = False
) -> str:
    """Download a script from https://gitlab.subcom.tech/open/scripts repo and execute it..

    Parameters
    ----------
    script : str
        The name or the full URL of the script.
    force : bool
        When set to `True`, redownload the script even if it exists in the cache.
    download_only:
        When set to `True`, only download the script and do not execute it.

    Returns
    -------
    `True` on success. `False` otherwise.

    """
    SCRIPT_DIR = Path(tempfile.gettempdir()) / "bmo"
    SCRIPT_DIR.mkdir(parents=True, exist_ok=True)

    if not script.startswith("http"):
        script = f"https://gitlab.subcom.tech/open/scripts/-/raw/main/{script}"

    scriptname: str = script.rsplit("/", maxsplit=1)[-1]
    scriptpath = SCRIPT_DIR / scriptname
    if not scriptpath.exists() or force:
        res = requests.get(script)
        if res.status_code != 200:
            logging.warn(f"Failed to download {script}")
            return ""
        with open(scriptpath, "w") as f:
            f.write(res.text)

    if download_only:
        with scriptpath.open() as f:
            return f.read()

    output = run_command(f"bash -c {scriptpath}")
    print(output)
    return output


def test_download_only():
    text = download_and_run_script("debian_bootstrap.sh", download_only=True)
    print(text)



if __name__ == "__main__":
    test_download_only()
