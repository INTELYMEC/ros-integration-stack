#!/bin/bash
set -e

source /opt/ros/humble/setup.bash

source /bridge_ws/install/setup.bash

echo "🔥 ROS1-ROS2 Bridge running..."

ros2 run ros1_bridge parameter_bridge