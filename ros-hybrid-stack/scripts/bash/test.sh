#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

echo "ℹ️  El stack debe estar en marcha (p. ej. make up: sim ROS1, sim ROS2, ros2_bridge)." >&2

docker compose build ros_tests

exec docker compose run --rm ros_tests