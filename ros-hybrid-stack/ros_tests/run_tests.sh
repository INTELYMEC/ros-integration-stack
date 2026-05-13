#!/bin/bash

set -euo pipefail

FAILED=0

echo "===================================================="
echo "🚀 INICIANDO TESTS"
echo "===================================================="

run() {
    local name=$1
    shift
    if "$@"; then
        echo "✅ TEST: ${name} PASSED"
    else
        echo "❌ TEST: ${name} FAILED"
        FAILED=1
    fi
}

run "ROS1 intra-grafo" /tests/tests/test_robot_p3at_sim_ros1_intra_graph.sh
echo "-----------------------------------------------------"
run "ROS2 intra-grafo" /tests/tests/test_robot_p3at_sim_ros2_intra_graph.sh
echo "-----------------------------------------------------"
run "Bridge ROS1 → ROS2" /tests/tests/test_robot_p3at_sim_ros1_to_ros2_bridge.sh
echo "-----------------------------------------------------"
run "Bridge ROS2 → ROS1" /tests/tests/test_robot_p3at_sim_ros2_to_ros1_bridge.sh
echo "-----------------------------------------------------"
run "Sim ROS1 → Sim ROS2 (bridge)" /tests/tests/test_robot_p3at_sim_ros1_to_robot_p3at_sim_ros2_bridge.sh
echo "-----------------------------------------------------"
run "Sim ROS2 → Sim ROS1 (bridge)" /tests/tests/test_robot_p3at_sim_ros2_to_robot_p3at_sim_ros1_bridge.sh
echo "===================================================="

exit "${FAILED}"
