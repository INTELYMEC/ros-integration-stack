#!/bin/bash
set -e

source /opt/ros/noetic/setup.bash

# Usamos variables inyectadas
export ROS_MASTER_URI=${ROS_MASTER_URI}
export ROS_HOSTNAME=${ROS_HOSTNAME}
export PYTHONPATH=/app/src:$PYTHONPATH

echo "🤖 Iniciando Simulador ROS 1 ($ROS_HOSTNAME)..."
/opt/ros/noetic/bin/roscore &

sleep 5

# fake_pioneer publica /${ROBOT_NAMESPACE}/cmd_vel (robot ROS1); bridge_test_trigger sim↔sim
python3 /app/src/fake_pioneer/main.py &
python3 /app/src/fake_pioneer/bridge_test_trigger_ros1.py &
wait