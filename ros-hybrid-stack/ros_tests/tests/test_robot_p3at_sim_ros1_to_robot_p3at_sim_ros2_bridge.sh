#!/bin/bash

set -euo pipefail

NS1="${ROBOT_ROS1_NAMESPACE:-p3at_sim_1}"
NS1="${NS1#/}"
TRIG="/${NS1}/ros1_bridge_test_trigger"
LOG="/ros_test_shared/ros2_cmd_vel_rx.log"

mkdir -p /ros_test_shared
rm -f "${LOG}"
: >"${LOG}" || true

echo "🔍 Test sim ROS1 → bridge → sim ROS2 (trigger ${TRIG})"

echo "➡️  Publicando desde ROS1..."

bash -c "
unset ROS_DISTRO ROS_ROOT ROS_PACKAGE_PATH
source /opt/ros/noetic/setup.bash
rostopic pub -1 ${TRIG} std_msgs/String \"data: 'go'\"
" >/dev/null 2>&1

echo "⏳ Esperando recepción en listener ROS2..."
for _ in $(seq 1 20); do
  if grep -q '7\.77' "${LOG}" 2>/dev/null; then
    echo "⬅️ sim ROS1 → bridge → sim ROS2 OK"
    grep -m 1 '7\.77' "${LOG}"
    exit 0
  fi
  sleep 1
done

echo "❌ No se registró 7.77 en ${LOG}"
cat "${LOG}" 2>/dev/null || true
exit 1
