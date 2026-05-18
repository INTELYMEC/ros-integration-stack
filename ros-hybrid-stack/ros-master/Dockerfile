ARG BASE_IMAGE
FROM ${BASE_IMAGE}

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

RUN echo "source /opt/ros/noetic/setup.bash" >> /root/.bashrc

RUN apt-get update && \
    apt-get install -y iputils-ping dnsutils && \
    rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/entrypoint.sh"]

CMD ["stdbuf", "-oL", "-eL", "roscore"]