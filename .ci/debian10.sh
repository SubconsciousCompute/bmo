#!/usr/bin/env bash

set -e
set -x

sudo apt-get -y install python3-pip
python3 -m pip install bmo
bmo network check-ssl subcom.tech
bmo run script bootstrap_debian.sh
bmo run script docker_debian.sh
