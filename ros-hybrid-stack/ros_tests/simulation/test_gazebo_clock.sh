#!/bin/bash

set -euo pipefail

echo "🔍 Verificando /clock..."

bash -c "
unset ROS_DISTRO ROS_ROOT ROS_PACKAGE_PATH
source /opt/ros/noetic/setup.bash

rostopic info /clock > /dev/null
"

echo "✅ Gazebo clock OK"