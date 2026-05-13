.PHONY: build build-no-cache up down test ros1-shell ros2-sim-shell ros2-shell logs

build:
	docker compose build

build-no-cache:
	docker compose build --no-cache

up:
	docker compose up robot_p3at_sim_ros1 robot_p3at_sim_ros2 ros2_bridge

down:
	docker compose down -v

test:
	./scripts/bash/test.sh

ros1-p3at-sim-shell:
	docker exec -it robot_p3at_sim_ros1 bash

ros2-p3at-sim-shell:
	docker exec -it robot_p3at_sim_ros2 bash

ros2-bridge-shell:
	docker exec -it ros2_bridge bash

logs:
	docker compose logs -f
