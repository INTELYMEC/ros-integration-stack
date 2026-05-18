#!/bin/bash
set -e

source /opt/ros/noetic/setup.bash

echo "🤖 Start ROS Master"

exec "$@"