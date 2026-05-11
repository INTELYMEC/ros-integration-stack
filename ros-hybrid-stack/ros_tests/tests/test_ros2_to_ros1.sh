#!/bin/bash

set -euo pipefail

rm -f /tmp/test_ros2_to_ros1.txt

echo "🔍 Test ROS2 → ROS1"

echo "⏳ Esperando subscriber ROS1..."

bash -c "
unset ROS_DISTRO ROS_ROOT ROS_PACKAGE_PATH
source /opt/ros/noetic/setup.bash

timeout 8s rostopic echo -n 1 /cmd_vel \
> /tmp/test_ros2_to_ros1.txt 2>&1
" &

PID=$!

# Esperamos al menos un ciclo para que el subscriber arranque
sleep 2

echo "📤 Publicando desde ROS2..."

bash -c "
unset ROS_DISTRO ROS_ROOT ROS_PACKAGE_PATH
source /opt/ros/foxy/setup.bash

ros2 topic pub --once /cmd_vel geometry_msgs/msg/Twist \
'{linear: {x: 1.0}}'
" >/dev/null 2>&1

wait $PID 2>/dev/null || true

if grep -q "linear" /tmp/test_ros2_to_ros1.txt; then
  echo "✅ Mensaje ROS2 → ROS1 capturado"
  grep -m 1 "linear" /tmp/test_ros2_to_ros1.txt
else
  echo "❌ No se encontró el mensaje esperado en la salida de ROS1"
  echo "--- Contenido capturado ---"
  cat /tmp/test_ros2_to_ros1.txt || true
  echo "---------------------------"
  exit 1
fi