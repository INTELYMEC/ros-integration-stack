#!/bin/bash

set -euo pipefail

NS1="${ROBOT_ROS1_NAMESPACE:-p3at_sim_1}"
NS2="${ROBOT_ROS2_NAMESPACE:-p3at_sim_2}"
NS1="${NS1#/}"
NS2="${NS2#/}"
CMD_TOPIC_1="/${NS1}/cmd_vel"
CMD_TOPIC_2="/${NS2}/cmd_vel"

export ROS_MASTER_URI="${ROS_MASTER_URI:-http://robot_p3at_sim_ros1:11311}"

mkdir -p /ros_test_shared

echo "🔄 Esperando ROS Master (${ROS_MASTER_URI})..."

until bash -c "
unset ROS_DISTRO ROS_ROOT ROS_PACKAGE_PATH
source /opt/ros/noetic/setup.bash
rostopic list >/dev/null 2>&1
"
do
    sleep 1
done

echo "✅ ROS Master disponible"

echo "🔄 Esperando bridge en ROS2 (${CMD_TOPIC_1} y ${CMD_TOPIC_2})..."

until bash -c "
unset ROS_DISTRO ROS_ROOT ROS_PACKAGE_PATH
source /opt/ros/foxy/setup.bash
list=\$(ros2 topic list 2>/dev/null || true)
echo \"\$list\" | grep -Fq \"${CMD_TOPIC_1}\"
echo \"\$list\" | grep -Fq \"${CMD_TOPIC_2}\"
"
do
    sleep 1
done

echo "✅ Bridge / sim detectado en ROS2"

exec /tests/run_tests.sh
