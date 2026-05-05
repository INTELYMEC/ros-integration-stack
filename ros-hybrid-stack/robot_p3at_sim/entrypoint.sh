#!/bin/bash
set -e

source /opt/ros/noetic/setup.bash

export PYTHONPATH=/app/src:$PYTHONPATH

echo "ROS env:"
echo $ROS_PACKAGE_PATH

echo "Starting roscore..."
/opt/ros/noetic/bin/roscore &

sleep 5

echo "Running fake Pioneer..."
python3 /app/src/fake_pioneer/main.py

tail -f /dev/null