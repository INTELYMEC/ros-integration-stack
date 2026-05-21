#!/bin/bash

set -euo pipefail

GO2_NS="${ROBOT_GO2_ROS2_NAMESPACE:-go2_sim_1}"
GO2_NS="${GO2_NS#/}"

TOPIC="/${GO2_NS}/cmd_vel"
TRIG="/${GO2_NS}/ros_bridge_test_trigger"

LISTENER_LOG="/tmp/go2_listener.log"
ECHO_LOG="/tmp/go2_echo.log"

rm -f "${LISTENER_LOG}" "${ECHO_LOG}"

echo "🔍 Test GO2 ROS2 → bridge → P3AT ROS1 (${TOPIC})"

# =========================================================
# 1. Lanzar listener ROS1
# =========================================================

bash -c "
unset ROS_DISTRO ROS_ROOT ROS_PACKAGE_PATH

export BRIDGE_TRIGGER_TOPIC=${TRIG}
export BRIDGE_LOG_FILE=${LISTENER_LOG}
export BRIDGE_CMD_VEL_TOPIC=${TOPIC}

source /opt/ros/noetic/setup.bash

python3 /tests/listeners/ros1_bridge_listener.py
" &

LISTENER_PID=$!

sleep 2

# =========================================================
# 2. Escuchar cmd_vel en ROS1
# =========================================================

bash -c "
unset ROS_DISTRO ROS_ROOT ROS_PACKAGE_PATH

source /opt/ros/noetic/setup.bash

stdbuf -oL timeout 15s rostopic echo ${TOPIC} \
  > ${ECHO_LOG} 2>&1
" &

ECHO_PID=$!

sleep 3

# =========================================================
# 3. Publicar trigger desde ROS2
# =========================================================

echo "➡️ Publicando desde GO2 ROS2..."

bash -c "
unset ROS_DISTRO ROS_ROOT ROS_PACKAGE_PATH

source /opt/ros/foxy/setup.bash

ros2 topic pub --once ${TRIG} std_msgs/msg/String \
'{data: go}'
" >/dev/null 2>&1

sleep 5

# =========================================================
# 4. Cleanup
# =========================================================

kill "${LISTENER_PID}" 2>/dev/null || true
kill "${ECHO_PID}" 2>/dev/null || true

wait "${ECHO_PID}" 2>/dev/null || true

# =========================================================
# 5. Validación
# =========================================================

if grep -q '8\.88' "${ECHO_LOG}"; then
  echo "✅ GO2 ROS2 → P3AT ROS1 OK"
  grep -m 1 '8\.88' "${ECHO_LOG}"
else
  echo "❌ No se capturó 8.88 en ROS1"

  echo ""
  echo "===== LISTENER LOG ====="
  cat "${LISTENER_LOG}" || true

  echo ""
  echo "===== ROS1 ECHO LOG ====="
  cat "${ECHO_LOG}" || true

  exit 1
fi