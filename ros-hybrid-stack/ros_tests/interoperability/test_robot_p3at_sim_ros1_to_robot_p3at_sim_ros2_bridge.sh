#!/bin/bash

set -euo pipefail

NS1="${ROBOT_P3AT_ROS1_NAMESPACE:-p3at_sim_1}"
NS1="${NS1#/}"

TRIG="/${NS1}/ros1_bridge_test_trigger"
LOG="/ros_test_shared/ros2_cmd_vel_rx.log"

mkdir -p /ros_test_shared
rm -f "${LOG}"

echo "🔍 Test P3AT ROS1 → bridge → P3AT ROS2"

# =========================================================
# 1. Lanzar listener ROS2
# =========================================================

echo "🚀 Iniciando listener ROS2..."

bash -c "
export BRIDGE_TRIGGER_TOPIC=${TRIG}

source /opt/ros/foxy/setup.bash
python3 /tests/listeners/ros2_bridge_listener.py
" &

LISTENER_PID=$!

sleep 3

# =========================================================
# 2. Publicar trigger desde ROS1
# =========================================================

echo "➡️ Publicando trigger desde ROS1..."

bash -c "
unset ROS_DISTRO ROS_ROOT ROS_PACKAGE_PATH
source /opt/ros/noetic/setup.bash

rostopic pub -1 ${TRIG} std_msgs/String \"data: 'go'\"
"

sleep 5

# =========================================================
# 3. Cleanup
# =========================================================

kill ${LISTENER_PID} 2>/dev/null || true

# =========================================================
# 4. Validación
# =========================================================

if grep -q '7\.77' "${LOG}"; then
  echo "✅ P3AT ROS1 → P3AT ROS2 OK"
else
  echo "❌ TEST FAILED"
  cat "${LOG}" || true
 exit 1
fi