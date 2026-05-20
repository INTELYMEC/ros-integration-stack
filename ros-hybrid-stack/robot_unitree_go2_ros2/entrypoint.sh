#!/bin/bash
set -e

source /opt/ros/foxy/setup.bash

export PYTHONPATH=/workspace/src:$PYTHONPATH

exec python3 /workspace/src/fake_go2/main.py