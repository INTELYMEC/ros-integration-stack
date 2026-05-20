#!/bin/bash

set -euo pipefail

NS2="${ROBOT_P3AT_ROS2_NAMESPACE:-p3at_sim_2}"
NS2="${NS2#/}"
TOPIC="/${NS2}/cmd_vel"

rm -f /tmp/test_ros2_to_ros1_bridge.txt

echo "🔍 Test bridge ROS2 → ROS1 (${TOPIC})"

bash -c "
unset ROS_DISTRO ROS_ROOT ROS_PACKAGE_PATH
source /opt/ros/noetic/setup.bash

stdbuf -oL timeout 12s rostopic echo -n 1 ${TOPIC} \
  > /tmp/test_ros2_to_ros1_bridge.txt 2>&1
" &

PID=$!

sleep 3

echo "➡️  Publicando desde ROS2..."

bash -c "
unset ROS_DISTRO ROS_ROOT ROS_PACKAGE_PATH
source /opt/ros/foxy/setup.bash

ros2 topic pub --once ${TOPIC} geometry_msgs/msg/Twist \
'{linear: {x: 1.0}}'
" >/dev/null 2>&1

wait "${PID}" 2>/dev/null || true

if grep -q "linear" /tmp/test_ros2_to_ros1_bridge.txt; then
  echo "⬅️  Mensaje ROS2 → ROS1 (bridge) capturado"
  grep -m 1 "linear" /tmp/test_ros2_to_ros1_bridge.txt
else
  echo "❌ No se encontró el mensaje esperado en ROS1"
  cat /tmp/test_ros2_to_ros1_bridge.txt || true
  exit 1
fi
