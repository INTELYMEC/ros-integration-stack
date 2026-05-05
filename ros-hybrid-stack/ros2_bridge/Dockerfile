FROM osrf/ros:humble-desktop-full

RUN apt-get update && apt-get install -y \
    git \
    python3-colcon-common-extensions \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Crear workspace
WORKDIR /bridge_ws/src

# Clonar bridge (ROS2 official repo)
RUN git clone --depth 1 https://github.com/ros2/ros1_bridge.git

WORKDIR /bridge_ws

# IMPORTANTE: source SOLO ROS2 (no ROS1 acá)
RUN /bin/bash -c "source /opt/ros/humble/setup.bash && colcon build --symlink-install"

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]