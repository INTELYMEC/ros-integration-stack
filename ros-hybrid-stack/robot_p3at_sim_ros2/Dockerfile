ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
      ros-foxy-rmw-cyclonedds-cpp \
      ros-foxy-geometry-msgs \
      ros-foxy-std-msgs \
      && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY src/ /app/src/
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && \
    sed -i 's/\r$//' /entrypoint.sh

ENTRYPOINT ["bash", "/entrypoint.sh"]
