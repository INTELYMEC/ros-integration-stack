#!/bin/bash

set -euo pipefail

NS1="${ROBOT_ROS1_NAMESPACE:-p3at_sim_1}"
NS1="${NS1#/}"
TRIG="/${NS1}/ros1_bridge_test_trigger"
LOG="/ros_test_shared/ros2_cmd_vel_rx.log"

mkdir -p /ros_test_shared
rm -f "${LOG}"

echo "🔍 Test sim ROS1 → bridge → sim ROS2"

echo "🚀 Iniciando listener ROS2..."

bash -c "
source /opt/ros/foxy/setup.bash
python3 /tests/listeners/ros2_bridge_listener.py
" &

LISTENER_PID=$!

sleep 3

echo "➡️ Publicando trigger desde ROS1..."

bash -c "
source /opt/ros/noetic/setup.bash
rostopic pub -1 ${TRIG} std_msgs/String \"data: 'go'\"
"

sleep 5

kill ${LISTENER_PID} 2>/dev/null || true

if grep -q '7\.77' "${LOG}"; then
  echo "✅ TEST PASSED"
else
  echo "❌ TEST FAILED"
  cat "${LOG}" || true
  exit 1
fi