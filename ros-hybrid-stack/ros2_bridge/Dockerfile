ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive

# Dependencias básicas
RUN apt-get update && apt-get install -y \
    curl gnupg2 lsb-release git build-essential python3-colcon-common-extensions

# Repositorio ROS 1 Noetic
RUN echo "deb http://packages.ros.org/ros/ubuntu focal main" > /etc/apt/sources.list.d/ros1.list && \
    curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -

# Instalamos ROS 1 Noetic nativo
RUN apt-get update && apt-get install -y ros-noetic-ros-base

WORKDIR /bridge_ws/src
RUN git clone https://github.com/ros2/ros1_bridge.git && \
    cd ros1_bridge && git checkout foxy

WORKDIR /bridge_ws
RUN /bin/bash -c "\
    source /opt/ros/noetic/setup.bash && \
    source /opt/ros/foxy/setup.bash && \
    colcon build --symlink-install --packages-select ros1_bridge \
"

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]