ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive
ENV RMW_IMPLEMENTATION=rmw_cyclonedds_cpp

SHELL ["/bin/bash", "-c"]

# Dependencias básicas
RUN apt-get update && apt-get install -y \
    curl \
    gnupg2 \
    lsb-release \
    git \
    build-essential \
    python3-colcon-common-extensions \
    net-tools \
    iputils-ping

# Repositorio ROS 1 Noetic
RUN echo "deb http://packages.ros.org/ros/ubuntu focal main" \
    > /etc/apt/sources.list.d/ros1.list && \
    curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -

# Instalar ROS1 Noetic
RUN apt-get update && apt-get install -y \
    ros-noetic-ros-base

# Instalar CycloneDDS
RUN apt-get update && apt-get install -y \
    ros-foxy-rmw-cyclonedds-cpp

# Workspace bridge
WORKDIR /bridge_ws/src

RUN git clone https://github.com/ros2/ros1_bridge.git && \
    cd ros1_bridge && \
    git checkout foxy

# Compilar ros1_bridge
WORKDIR /bridge_ws

RUN unset ROS_DISTRO && \
    source /opt/ros/noetic/setup.bash && \
    unset ROS_DISTRO && \
    source /opt/ros/foxy/setup.bash && \
    colcon build --symlink-install --packages-select ros1_bridge

# Copiar entrypoint
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh && \
    sed -i 's/\r$//' /entrypoint.sh

ENTRYPOINT ["bash", "/entrypoint.sh"]