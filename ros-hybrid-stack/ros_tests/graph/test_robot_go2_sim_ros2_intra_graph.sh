#!/bin/bash

set -euo pipefail

NS="${ROBOT_GO2_ROS2_NAMESPACE:-go2_sim_1}"
NS="${NS#/}"

echo "🔍 Verificando grafo ROS2 GO2..."

bash -c "
source /opt/ros/foxy/setup.bash

topics=\$(ros2 topic list)

echo \"\$topics\" | grep -q '/${NS}/cmd_vel'
echo \"\$topics\" | grep -q '/${NS}/odom'
echo \"\$topics\" | grep -q '/${NS}/status'
"

echo "✅ GO2 ROS2 intra-graph OK"