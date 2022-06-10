__author__           = "Dilawar Singh"
__email__            = "dilawar@subcom.tech"

import sys
import json
import platform
import typing as T

import shutils

from loguru import logger

from bmo.common import run_command

import typer

app = typer.Typer()

#
# This is from https://docs.docker.com/engine/install/debian/
DOCKER_INSTALL_SCRIPT : str = """
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install docker-ce docker-ce-cli  containerd.io docker-compose-plugin
sudo systemctl start docker
sudo systemctl enable docker
"""

@app.command("aws_deb11")
def bootstrap_debian11():
    """Bootstrap debian 11 OS."""
    assert shutils.which("apt"), f"apt is not found."
    with tempfile.NamedTemporaryFile(mode='w', suffix='.sh') as f:
        pass
    


if __name__ == "__main__":
    import doctest

    doctest.testmod()
