.PHONY: build build-no-cache up down test ros1-shell ros2-shell logs

build:
	docker compose build

build-no-cache:
	docker compose build --no-cache

up:
	docker compose up robot_p3at_sim ros2_bridge

down:
	docker compose down -v

test:
	./scripts/bash/test.sh

ros1-shell:
	docker exec -it robot_p3at_sim bash

ros2-shell:
	docker exec -it ros2_bridge bash

logs:
	docker compose logs -f
