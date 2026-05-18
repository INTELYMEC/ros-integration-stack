#!/bin/bash
set -e

source "/opt/ros/noetic/setup.bash"

echo "⏳ [Gazebo] Esperando al Master de ROS en ${ROS_MASTER_URI}..."
until rostopic list > /dev/null 2>&1; do
  sleep 1
done
echo "✅ [Gazebo] Conectado al Master de ROS con éxito."

exec "$@"