#!/bin/bash

set -euo pipefail

NS1="${ROBOT_ROS1_NAMESPACE:-p3at_sim_1}"
NS1="${NS1#/}"
TOPIC="/${NS1}/cmd_vel"

rm -f /tmp/test_ros1_to_ros2_bridge.txt

echo "🔍 Test bridge ROS1 → ROS2 (${TOPIC} reflejado en ROS2)"

bash -c "
unset ROS_DISTRO ROS_ROOT ROS_PACKAGE_PATH
export PYTHONUNBUFFERED=1
source /opt/ros/foxy/setup.bash

stdbuf -oL timeout 15s ros2 topic echo ${TOPIC} \
  > /tmp/test_ros1_to_ros2_bridge.txt 2>&1
" &

PID=$!

echo "⏳ Esperando eco ROS2..."
sleep 4

echo "➡️  Publicando desde ROS1..."

bash -c "
unset ROS_DISTRO ROS_ROOT ROS_PACKAGE_PATH
source /opt/ros/noetic/setup.bash

rostopic pub ${TOPIC} geometry_msgs/Twist \
'{linear: {x: 5.5}}' \
-r 2
" >/dev/null 2>&1 &

PUB_PID=$!

sleep 8

kill "${PUB_PID}" 2>/dev/null || true
wait "${PID}" 2>/dev/null || true

if grep -q "5.5" /tmp/test_ros1_to_ros2_bridge.txt; then
  echo "⬅️  Mensaje ROS1 → ROS2 (bridge) capturado"
  grep -m 1 "5.5" /tmp/test_ros1_to_ros2_bridge.txt
else
  echo "❌ No se encontró el mensaje esperado en ROS2"
  cat /tmp/test_ros1_to_ros2_bridge.txt || true
  exit 1
fi
