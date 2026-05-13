#!/bin/bash
set -e

# Filtra avisos benignos al encadenar Noetic + Foxy (ros1_bridge lo requiere).
_ros_setup_filter_stderr() {
  while IFS= read -r _line || [[ -n "$_line" ]]; do
    if [[ "$_line" == *"ROS_DISTRO was set to "* ]] && [[ "$_line" == *" before."* ]]; then
      continue
    fi
    printf '%s\n' "$_line" >&2
  done
}

# Imagen base Foxy suele exportar AMENT_* / ROS_DISTRO; limpiar antes de encadenar Noetic + Foxy.
unset ROS_DISTRO ROS_VERSION ROS_ROOT ROS_PACKAGE_PATH ROS_ETC_DIR \
  AMENT_PREFIX_PATH AMENT_CURRENT_PREFIX COLCON_PREFIX_PATH

# shellcheck disable=SC1090
source /opt/ros/noetic/setup.bash 2> >(_ros_setup_filter_stderr)

# No hacer unset entre Noetic y Foxy: el bridge en runtime necesita ambos prefijos coherentes.
# shellcheck disable=SC1090
source /opt/ros/foxy/setup.bash 2> >(_ros_setup_filter_stderr)

# shellcheck disable=SC1090
source /bridge_ws/install/setup.bash 2> >(_ros_setup_filter_stderr)

export ROS_MASTER_URI=${ROS_MASTER_URI}
export ROS_HOSTNAME=${ROS_HOSTNAME}

echo "🚀 Iniciando Bridge Híbrido..."
ros2 run ros1_bridge dynamic_bridge --bridge-all-topics
