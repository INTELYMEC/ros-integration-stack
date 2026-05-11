#!/bin/bash

set -euo pipefail

FAILED=0

echo "===================================================="
echo "🚀 INICIANDO TESTS"
echo "===================================================="

if /tests/tests/test_ros1_to_ros2.sh; then
    echo "✅ ROS1 → ROS2 PASSED"
else
    echo "❌ ROS1 → ROS2 FAILED"
    FAILED=1
fi

if /tests/tests/test_ros2_to_ros1.sh; then
    echo "✅ ROS2 → ROS1 PASSED"
else
    echo "❌ ROS2 → ROS1 FAILED"
    FAILED=1
fi

exit $FAILED