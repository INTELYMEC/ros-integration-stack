#!/bin/bash
set -e

_ros_setup_filter_stderr() {
  while IFS= read -r _line || [[ -n "$_line" ]]; do
    if [[ "$_line" == *"ROS_DISTRO was set to "* ]] && [[ "$_line" == *" before."* ]]; then
      continue
    fi
    printf '%s\n' "$_line" >&2
  done
}

# Limpieza inicial de entornos cruzados
unset ROS_DISTRO ROS_VERSION ROS_ROOT ROS_PACKAGE_PATH ROS_ETC_DIR \
  AMENT_PREFIX_PATH AMENT_CURRENT_PREFIX COLCON_PREFIX_PATH

# Encadenamiento nativo Noetic + Foxy + Workspace del Bridge
source /opt/ros/noetic/setup.bash 2> >(_ros_setup_filter_stderr)
source /opt/ros/foxy/setup.bash 2> >(_ros_setup_filter_stderr)
source /bridge_ws/install/setup.bash 2> >(_ros_setup_filter_stderr)

export ROS_MASTER_URI=${ROS_MASTER_URI}
export ROS_HOSTNAME=${ROS_HOSTNAME}

echo "🚀 Iniciando Bridge Híbrido con Mapeo Estricto por Archivo..."

ros2 run ros1_bridge dynamic_bridge \
  --bridge-all-topics \
  --bridge-mapping-with-yaml /bridge_mappings.yaml