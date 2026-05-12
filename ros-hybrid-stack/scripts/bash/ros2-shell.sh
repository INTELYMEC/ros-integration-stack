#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
docker exec -it ros2_bridge bash
