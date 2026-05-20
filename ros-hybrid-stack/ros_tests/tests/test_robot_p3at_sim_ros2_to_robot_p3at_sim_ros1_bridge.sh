#!/bin/bash

set -euo pipefail

NS2="${ROBOT_ROS2_NAMESPACE:-p3at_sim_2}"
NS2="${NS2#/}"

TOPIC="/${NS2}/cmd_vel"
TRIG="/${NS2}/ros_bridge_test_trigger"

rm -f /tmp/test_sim_r2_r1.txt

echo "🔍 Test sim ROS2 → bridge → ROS1 (${TOPIC})"

# =========================================================
# 1. Lanzar listener ROS1
# =========================================================

bash -c "
unset ROS_DISTRO ROS_ROOT ROS_PACKAGE_PATH
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
  > /tmp/test_sim_r2_r1.txt 2>&1
" &

ECHO_PID=$!

sleep 3

# =========================================================
# 3. Publicar trigger desde ROS2
# =========================================================

echo "➡️  Publicando desde ROS2..."

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

if grep -q '8\.88' /tmp/test_sim_r2_r1.txt; then
  echo "⬅️ sim ROS2 → bridge → ROS1 OK"
  grep -m 1 '8\.88' /tmp/test_sim_r2_r1.txt
else
  echo "❌ No se capturó 8.88 en ROS1"
  cat /tmp/test_sim_r2_r1.txt || true
  exit 1
fi