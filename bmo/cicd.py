__author__ = "Dilawar Singh"
__email__ = "dilawar@subcom.tech"

import shutil
import logging
from pathlib import Path
import typing as T

import yaml

import bmo.common

import typer

app = typer.Typer()


def find_docker():
    return shutil.which("docker")


@app.command("runner")
def run_gitlab_runner(
    command: str = "", jobs: T.List[str] = [], pipeline_file: T.Optional[Path] = None
):
    """Run gitlab-runner"""
    cwd = Path.cwd()
    if pipeline_file is None:
        pipeline_file = cwd / ".gitlab-ci.yml"
    assert (
        pipeline_file.exists()
    ), f"{pipeline_file} doesn't exists. Please use `--pipeline-file`"
    if not command:
        command = "docker" if find_docker() is not None else "shell"

    with pipeline_file.open("r") as f:
        pipeline_yaml = yaml.safe_load(f)

    if not jobs:
        jobs = list(pipeline_yaml.keys())

    output = ""
    for job in jobs:
        if job not in pipeline_yaml:
            available_jobs = list(pipeline_yaml.keys())
            logging.warning(
                f"{job} is not found in pipeline. Available jobs are {available_jobs}"
            )
            continue
        output += bmo.common.run_command(f"gitlab-runner exec {command} {job}")
    return output


def _test_gitlab_runner():
    out = run_gitlab_runner()
    assert len(out) > 0


def test_cicd():
    _test_gitlab_runner()


if __name__ == "__main__":
    test_cicd()
