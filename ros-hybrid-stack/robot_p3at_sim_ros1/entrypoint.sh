#!/bin/bash
set -e

source /opt/ros/noetic/setup.bash

export ROS_MASTER_URI=${ROS_MASTER_URI}
export ROS_HOSTNAME=${ROS_HOSTNAME}
export PYTHONPATH=/app/src:$PYTHONPATH

echo "🤖 Iniciando Lógica de Control del Robot ($ROS_HOSTNAME)..."
echo "🔗 Conectando al Máster central en $ROS_MASTER_URI"

python3 /app/src/fake_pioneer/main.py

wait