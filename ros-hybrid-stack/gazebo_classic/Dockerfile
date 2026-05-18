ARG BASE_IMAGE
FROM ${BASE_IMAGE}

# Evitar prompts interactivos durante la instalación
ENV DEBIAN_FRONTEND=noninteractive

# 1. Parche de llaves GPG para evitar Error 100 de APT en 2026
RUN apt-get update -o Acquire::AllowInsecureRepositories=true || true && \
    apt-get install -y --allow-unauthenticated curl gnupg2 sed && \
    curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -

# 2. Instalación completa de Gazebo y conectores de ROS
RUN apt-get update && apt-get install -y \
    ros-noetic-gazebo-ros-pkgs \
    ros-noetic-gazebo-ros-control \
    ros-noetic-xacro \
    ros-noetic-joint-state-publisher \
    ros-noetic-robot-state-publisher \
    && rm -rf /var/lib/apt/lists/*

# 3. Configuración del Entrypoint y entorno
COPY entrypoint.sh /entrypoint.sh

# Fix crucial multiplataforma: Remueve los caracteres \r ocultos si se editó en Windows
RUN sed -i 's/\r$//' /entrypoint.sh && chmod +x /entrypoint.sh

RUN echo "source /opt/ros/noetic/setup.bash" >> /root/.bashrc

WORKDIR /root

ENTRYPOINT ["/entrypoint.sh"]