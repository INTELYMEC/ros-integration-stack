#!/bin/bash
set -e

source /opt/ros/foxy/setup.bash

export ROS_DOMAIN_ID="${ROS_DOMAIN_ID:-0}"
export RMW_IMPLEMENTATION="${RMW_IMPLEMENTATION:-rmw_cyclonedds_cpp}"

mkdir -p /ros_test_shared
chmod a+w /ros_test_shared 2>/dev/null || true

echo "🤖 Iniciando sim ROS2 ($ROS_DOMAIN_ID, listener ns=${ROBOT_ROS1_NAMESPACE}, trigger ns=${ROBOT_ROS2_NAMESPACE})..."
python3 /app/src/fake_pioneer/main.py &
python3 /app/src/fake_pioneer/bridge_test_trigger_ros2.py &
wait
