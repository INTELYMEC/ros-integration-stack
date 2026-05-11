#!/bin/bash

set -euo pipefail

rm -f /tmp/test_ros1_to_ros2.txt

echo "🔍 Test ROS1 → ROS2"

bash -c "
unset ROS_DISTRO ROS_ROOT ROS_PACKAGE_PATH
export PYTHONUNBUFFERED=1
source /opt/ros/foxy/setup.bash

stdbuf -oL timeout 10s ros2 topic echo /cmd_vel \
> /tmp/test_ros1_to_ros2.txt 2>&1
" &

PID=$!

echo "⏳ Esperando subscriber ROS2..."
for i in $(seq 1 10); do
  bash -c "
  unset ROS_DISTRO ROS_ROOT ROS_PACKAGE_PATH
  source /opt/ros/foxy/setup.bash
  ros2 topic info /cmd_vel 2>/dev/null | grep -q 'Subscription count: 1'
  " && break
  sleep 1
done

echo "📤 Publicando desde ROS1..."

bash -c "
unset ROS_DISTRO ROS_ROOT ROS_PACKAGE_PATH
source /opt/ros/noetic/setup.bash

rostopic pub /cmd_vel geometry_msgs/Twist \
'{linear: {x: 5.5}}' \
-r 2
" >/dev/null 2>&1 &

PUB_PID=$!

sleep 6

kill $PUB_PID 2>/dev/null || true
wait $PID 2>/dev/null || true

if grep -q "5.5" /tmp/test_ros1_to_ros2.txt; then
  echo "✅ Mensaje ROS1 → ROS2 capturado"
  grep -m 1 "5.5" /tmp/test_ros1_to_ros2.txt
else
  echo "❌ No se encontró el mensaje esperado en la salida de ROS2"
  echo "--- Contenido capturado ---"
  cat /tmp/test_ros1_to_ros2.txt || true
  echo "---------------------------"
  exit 1
fi