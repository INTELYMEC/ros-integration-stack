#!/bin/bash

set -euo pipefail

NS2="${ROBOT_P3AT_ROS2_NAMESPACE:-p3at_sim_2}"
NS2="${NS2#/}"

TRIG="/${NS2}/ros_bridge_test_trigger"
LOG="/ros_test_shared/ros2_cmd_vel_rx.log"

mkdir -p /ros_test_shared
rm -f "${LOG}"

echo "🔍 Test P3AT ROS2 → GO2 ROS2"

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
# 2. Publicar trigger desde ROS2
# =========================================================

echo "➡️ Publicando trigger desde P3AT ROS2..."

bash -c "
source /opt/ros/foxy/setup.bash

ros2 topic pub --once ${TRIG} std_msgs/msg/String \
'{data: go}'
"

sleep 5

# =========================================================
# 3. Cleanup
# =========================================================

kill "${LISTENER_PID}" 2>/dev/null || true

# =========================================================
# 4. Validación
# =========================================================

if grep -q '7\.77' "${LOG}"; then
  echo "✅ P3AT ROS2 → GO2 ROS2 OK"
else
  echo "❌ TEST FAILED"
  cat "${LOG}" || true
  exit 1
fi