__author__           = "Dilawar Singh"
__email__            = "dilawar@subcom.tech"

import sys
import json
import platform

import typing as T

from pathlib import Path

from loguru import logger

import bmo.common

import typer


app = typer.Typer()

def find_docker():
    import shutils
    return shutils.which("docker")

@app.command("runner")
def run_gitlab_runner( : str = ""):
    """Run gitlab-runner """
    cwd = Path.cwd()
    gitlab_pipeline = cwd / '.gitlab-ci.yml'
    assert gitlab_pipeline.exists(), f"{gitlab_pipeline} doesn't exists"
    if not runner_cmd:
        runner_cmd = "docker" if find_docker() is not None else "shell"
    action = "build"
    assert 0 == subcom.bmo.run_command("gitlab-runner exec {runner_cmd} {action}")

if __name__ == "__main__":
    import doctest

    doctest.testmod()
