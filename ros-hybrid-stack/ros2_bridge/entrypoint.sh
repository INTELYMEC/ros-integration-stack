#!/bin/bash
set -e

unset ROS_DISTRO ROS_ROOT ROS_PACKAGE_PATH
source /opt/ros/noetic/setup.bash
unset ROS_DISTRO ROS_ROOT ROS_PACKAGE_PATH
source /opt/ros/foxy/setup.bash
source /bridge_ws/install/setup.bash

# Usamos las variables que vienen del docker-compose / .env
export ROS_MASTER_URI=${ROS_MASTER_URI}
export ROS_HOSTNAME=${ROS_HOSTNAME}

echo "🚀 Iniciando Bridge Híbrido..."
ros2 run ros1_bridge dynamic_bridge --bridge-all-topics