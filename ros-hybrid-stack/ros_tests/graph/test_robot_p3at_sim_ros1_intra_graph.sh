#!/bin/bash

set -euo pipefail

NS1="${ROBOT_P3AT_ROS1_NAMESPACE:-p3at_sim_1}"
NS1="${NS1#/}"
TOPIC="/${NS1}/intra_ros1"

rm -f /tmp/test_ros1_intra.txt

echo "🔍 Test intra-grafo ROS1 (${TOPIC})"

bash -c "
unset ROS_DISTRO ROS_ROOT ROS_PACKAGE_PATH
export PYTHONUNBUFFERED=1
source /opt/ros/noetic/setup.bash
stdbuf -oL timeout 12s rostopic echo -n 1 ${TOPIC} \
  > /tmp/test_ros1_intra.txt 2>&1
" &

PID=$!
sleep 2

bash -c "
unset ROS_DISTRO ROS_ROOT ROS_PACKAGE_PATH
source /opt/ros/noetic/setup.bash
rostopic pub -1 ${TOPIC} std_msgs/String \"data: 'intra_ros1_ok'\"
" >/dev/null 2>&1

wait "${PID}" 2>/dev/null || true

if grep -q "intra_ros1_ok" /tmp/test_ros1_intra.txt; then
  echo "📡 ROS1 intra-grafo OK"
else
  echo "❌ ROS1 intra-grafo FAILED"
  cat /tmp/test_ros1_intra.txt || true
  exit 1
fi