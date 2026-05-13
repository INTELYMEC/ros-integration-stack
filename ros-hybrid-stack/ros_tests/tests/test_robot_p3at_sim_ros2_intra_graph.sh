#!/bin/bash

set -euo pipefail

NS2="${ROBOT_ROS2_NAMESPACE:-p3at_sim_2}"
NS2="${NS2#/}"
TOPIC="/${NS2}/intra_ros2"

rm -f /tmp/test_ros2_intra.txt

echo "🔍 Test intra-grafo ROS2 (${TOPIC})"

bash -c "
unset ROS_DISTRO ROS_ROOT ROS_PACKAGE_PATH
export PYTHONUNBUFFERED=1
source /opt/ros/foxy/setup.bash
stdbuf -oL timeout 12s ros2 topic echo ${TOPIC} std_msgs/msg/String \
  > /tmp/test_ros2_intra.txt 2>&1
" &

PID=$!
sleep 2

bash -c "
unset ROS_DISTRO ROS_ROOT ROS_PACKAGE_PATH
source /opt/ros/foxy/setup.bash
ros2 topic pub --once ${TOPIC} std_msgs/msg/String \"{data: intra_ros2_ok}\"
" >/dev/null 2>&1

wait "${PID}" 2>/dev/null || true

if grep -q "intra_ros2_ok" /tmp/test_ros2_intra.txt; then
  echo "📡 ROS2 intra-grafo OK"
else
  echo "❌ ROS2 intra-grafo FAILED"
  cat /tmp/test_ros2_intra.txt || true
  exit 1
fi
