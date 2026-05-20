#!/bin/bash
set -e

source /opt/ros/foxy/setup.bash

export ROS_DOMAIN_ID="${ROS_DOMAIN_ID:-0}"
export RMW_IMPLEMENTATION="${RMW_IMPLEMENTATION:-rmw_cyclonedds_cpp}"
export PYTHONPATH=/app/src:$PYTHONPATH

echo "🤖 Iniciando Lógica de Control ROS 2 (Namespace: ${ROBOT_P3AT_ROS2_NAMESPACE})..."

python3 /app/src/fake_pioneer/main.py
