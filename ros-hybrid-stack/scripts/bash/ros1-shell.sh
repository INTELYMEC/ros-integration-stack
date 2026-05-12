#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
docker exec -it robot_p3at_sim bash
