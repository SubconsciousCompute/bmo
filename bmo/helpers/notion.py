# Notion related functions.

__author__ = "Dilawar Singh"
__email__ = "dilawar@subcom.tech"

import requests
import os
import datetime
import json

import typing as T
from pathlib import Path

from loguru import logger


class Notion:
    """Notion related functions."""

    def __init__(self, token: str):
        self.token = token
        self.backup_dir: T.Optional[str] = None

    def backup(self, outdir: T.Optional[Path]):
        """Backup notion content"""
        assert self.token is not None, f"Token can't be None"
        timestamp = datetime.datetime.now().isoformat()

        folder = Path.home() / "backups" / Path(f"notion_backup-{timestamp}")
        if outdir is not None:
            folder = Path(outdir)
        folder.mkdir(parents=True)

        logger.info(f"Creating backup into {folder}")
        # replace YOUR_INTEGRATION_TOKEN with your own secret token
        headers = {
            "Authorization": f"Bearer {self.token}",
            "Notion-Version": "2022-02-22",
            "Content-Type": "application/json",
        }

        response = requests.post("https://api.notion.com/v1/search", headers=headers)
        logger.info(response.json())
        for block in response.json()["results"]:
            with open(f'{folder}/{block["id"]}.json', "w") as file:
                file.write(json.dumps(block))

            child_blocks = requests.get(
                f'https://api.notion.com/v1/blocks/{block["id"]}/children',
                headers=headers,
            )
            if child_blocks.json()["results"]:
                datadir = (folder / f'{block["id"]}') 
                datadir.mkdir()

                for child in child_blocks.json()["results"]:
                    with open(datadir / f'{child["id"]}.json', "w") as file:
                        file.write(json.dumps(child))
        logger.info("backup is complete")
