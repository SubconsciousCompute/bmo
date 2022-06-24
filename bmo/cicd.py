__author__ = "Dilawar Singh"
__email__ = "dilawar@subcom.tech"

import shutil
import bmo.common

from pathlib import Path

import typer
app = typer.Typer()


def find_docker():
    return shutil.which("docker")


@app.command("runner")
def run_gitlab_runner(command: str = "", job: str = "build"):
    """Run gitlab-runner"""
    cwd = Path.cwd()
    gitlab_pipeline = cwd / ".gitlab-ci.yml"
    assert gitlab_pipeline.exists(), f"{gitlab_pipeline} doesn't exists"
    if not command:
        command = "docker" if find_docker() is not None else "shell"
    job = job if job else "build"
    bmo.common.run_command(f"gitlab-runner exec {command} {job}")



if __name__ == "__main__":
    import doctest

    doctest.testmod()
