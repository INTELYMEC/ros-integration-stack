#!/bin/bash

set -euo pipefail

NS2="${ROBOT_ROS2_NAMESPACE:-p3at_sim_2}"
NS2="${NS2#/}"
TOPIC="/${NS2}/cmd_vel"
TRIG="/${NS2}/ros2_bridge_test_trigger"

rm -f /tmp/test_sim_r2_r1.txt

echo "🔍 Test sim ROS2 → bridge → ROS1 (${TOPIC})"

echo "➡️  Publicando desde ROS2..."

bash -c "
unset ROS_DISTRO ROS_ROOT ROS_PACKAGE_PATH
source /opt/ros/noetic/setup.bash
stdbuf -oL timeout 15s rostopic echo -n 1 ${TOPIC} \
  > /tmp/test_sim_r2_r1.txt 2>&1
" &

PID=$!

sleep 3

bash -c "
unset ROS_DISTRO ROS_ROOT ROS_PACKAGE_PATH
source /opt/ros/foxy/setup.bash
ros2 topic pub --once ${TRIG} std_msgs/msg/String \"{data: go}\"
" >/dev/null 2>&1

wait "${PID}" 2>/dev/null || true

if grep -q '8\.88' /tmp/test_sim_r2_r1.txt; then
  echo "⬅️ sim ROS2 → bridge → ROS1 OK"
  grep -m 1 '8\.88' /tmp/test_sim_r2_r1.txt
else
  echo "❌ No se capturó 8.88 en ROS1"
  cat /tmp/test_sim_r2_r1.txt || true
  exit 1
fi
