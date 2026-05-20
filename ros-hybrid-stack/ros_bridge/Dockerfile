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
RUN apt-get update && apt-get install -y curl && \
    curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | tee /etc/apt/trusted.gpg.d/ros.asc && \
    echo "deb http://packages.ros.org/ros/ubuntu focal main" > /etc/apt/sources.list.d/ros1.list

# Instalar ROS1 Noetic + mensajes usados por el bridge (factories en tiempo de compilación)
RUN apt-get update && apt-get install -y \
    ros-noetic-ros-base \
    ros-noetic-geometry-msgs \
    ros-noetic-std-msgs

# CycloneDDS + mensajes Foxy equivalentes (CMake debe ver ambos prefijos al compilar ros1_bridge)
RUN apt-get update && apt-get install -y \
    ros-foxy-rmw-cyclonedds-cpp \
    ros-foxy-geometry-msgs \
    ros-foxy-std-msgs

# Workspace bridge
WORKDIR /bridge_ws/src

RUN git clone https://github.com/ros2/ros1_bridge.git && \
    cd ros1_bridge && \
    git checkout foxy

# Compilar ros1_bridge
WORKDIR /bridge_ws

# Encadenar Noetic y Foxy sin unset intermedio: si solo queda Foxy en CMAKE/AMENT,
# ros1_bridge se compila sin pares ROS1↔ROS2 (p. ej. geometry_msgs/Twist).
RUN unset ROS_DISTRO ROS_VERSION ROS_ROOT ROS_PACKAGE_PATH ROS_ETC_DIR \
      AMENT_PREFIX_PATH AMENT_CURRENT_PREFIX COLCON_PREFIX_PATH && \
    source /opt/ros/noetic/setup.bash && \
    source /opt/ros/foxy/setup.bash && \
    colcon build --symlink-install --packages-select ros1_bridge

# Copiar entrypoint
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh && \
    sed -i 's/\r$//' /entrypoint.sh

ENTRYPOINT ["bash", "/entrypoint.sh"]