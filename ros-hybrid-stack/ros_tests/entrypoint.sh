#!/bin/bash

set -euo pipefail

export ROS_MASTER_URI=http://robot_p3at_sim:11311

echo "🔄 Esperando ROS Master..."

until bash -c "
unset ROS_DISTRO ROS_ROOT ROS_PACKAGE_PATH
source /opt/ros/noetic/setup.bash
rostopic list >/dev/null 2>&1
"
do
    sleep 1
done

echo "✅ ROS Master disponible"

echo "🔄 Esperando Bridge..."

until bash -c "
unset ROS_DISTRO ROS_ROOT ROS_PACKAGE_PATH
source /opt/ros/foxy/setup.bash
ros2 topic list | grep /cmd_vel >/dev/null 2>&1
"
do
    sleep 1
done

echo "✅ Bridge detectado"

exec /tests/run_tests.sh