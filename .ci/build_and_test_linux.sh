#!/usr/bin/env bash
set -e
set -x
python -m pip install poetry --user --upgrade
python -m poetry install
make test
