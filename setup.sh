#!/bin/bash
set -uevo pipefail

virtualenv --python=python2.7 venv;
source venv/bin/activate;
pip install -r requirements.txt;
