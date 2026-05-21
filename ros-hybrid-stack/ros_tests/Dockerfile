ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive
ENV RMW_IMPLEMENTATION=rmw_cyclonedds_cpp

SHELL ["/bin/bash", "-c"]

WORKDIR /tests

# Dependencias base
RUN apt-get update && \
    apt-get install -y \
    curl \
    gnupg2 \
    lsb-release \
    net-tools \
    iputils-ping

# Repositorio ROS 1 Noetic
RUN apt-get update && apt-get install -y curl && \
    curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | tee /etc/apt/trusted.gpg.d/ros.asc && \
    echo "deb http://packages.ros.org/ros/ubuntu focal main" > /etc/apt/sources.list.d/ros1.list

# Instalar ROS1 + herramientas
RUN apt-get update && \
    apt-get install -y \
      ros-noetic-ros-base \
      python3-rosdep \
      python3-rosinstall \
      python3-vcstools

# Instalar CycloneDDS
RUN apt-get update && \
    apt-get install -y \
    ros-foxy-rmw-cyclonedds-cpp

# ROS2 Python APIs para listeners auxiliares
RUN apt-get update && \
    apt-get install -y \
    ros-foxy-rclpy \
    ros-foxy-std-msgs

# Copiar tests
COPY . /tests

# Permisos + compatibilidad CRLF
RUN find /tests -name "*.sh" -exec chmod +x {} \; && \
    find /tests -name "*.py" -exec chmod +x {} \; && \
    find /tests -type f -exec sed -i 's/\r$//' {} \;

ENTRYPOINT ["/tests/entrypoint.sh"]