#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

docker compose build

docker compose up -d robot_p3at_sim ros2_bridge

RESULT=0
if ! docker compose run --rm ros_tests; then
  RESULT=$?
fi

docker compose down -v

exit $RESULT
