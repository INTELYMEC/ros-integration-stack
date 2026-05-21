#!/bin/bash

set -euo pipefail

echo "🔍 Verificando model_states..."

bash -c "
unset ROS_DISTRO ROS_ROOT ROS_PACKAGE_PATH
source /opt/ros/noetic/setup.bash

rostopic type /gazebo/model_states | grep -q 'ModelStates'
"

echo "✅ Gazebo model_states OK"