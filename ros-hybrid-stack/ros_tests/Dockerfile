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

# Repositorio ROS1
RUN echo "deb http://packages.ros.org/ros/ubuntu focal main" \
    > /etc/apt/sources.list.d/ros1.list && \
    curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -

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

# Copiar tests
COPY . /tests

# Permisos + compatibilidad CRLF
RUN chmod +x /tests/*.sh && \
    chmod +x /tests/tests/*.sh && \
    sed -i 's/\r$//' /tests/*.sh && \
    sed -i 's/\r$//' /tests/tests/*.sh

ENTRYPOINT ["/tests/entrypoint.sh"]