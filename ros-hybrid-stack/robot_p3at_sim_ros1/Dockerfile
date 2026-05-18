ARG BASE_IMAGE
FROM ${BASE_IMAGE}

WORKDIR /app

RUN echo "source /opt/ros/noetic/setup.bash" >> /root/.bashrc

COPY src/ /app/src/

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh && \
    sed -i 's/\r$//' /entrypoint.sh

ENTRYPOINT ["bash", "/entrypoint.sh"]