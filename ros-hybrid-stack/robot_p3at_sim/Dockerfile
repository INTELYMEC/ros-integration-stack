FROM ros:noetic

WORKDIR /app

COPY src/ /app/src/
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && \
    sed -i 's/\r$//' /entrypoint.sh

ENTRYPOINT ["bash", "/entrypoint.sh"]