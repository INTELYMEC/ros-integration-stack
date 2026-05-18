DC = docker compose
EXEC = docker exec -it

CHECK_ENV = [ -f .env ] || (echo "====================================================" && \
                             echo "❌ ERROR: Archivo '.env' no encontrado." && \
                             echo "====================================================" && \
                             echo "💡 crea tu archivo de configuración local .env con el modelo .env.example" && \
                             echo "====================================================" && exit 1)

.PHONY: build build-no-cache up up-sim down restart test logs logs-gazebo clean help \
        shell-master shell-robot1 shell-robot2 shell-bridge shell-gazebo shell-gui

help:
	@echo "Comandos disponibles:"
	@echo "  make build           - Construir todas las imágenes del stack"
	@echo "  make build-no-cache  - Reconstruir desde cero sin usar la cache"
	@echo "  make up              - Levantar TODO el laboratorio virtual (Física + Stack Híbrido)"
	@echo "  make down            - Detener y remover todos los contenedores y redes"
	@echo "  make restart s=<name>- Reiniciar un servicio rápido (ej: make restart s=robot_p3at_sim_ros1)"
	@echo "  make test            - Ejecutar la suite de pruebas completa de certificación"
	@echo "  clean                - Limpieza profunda de imágenes y volúmenes"

build:
	@$(CHECK_ENV) && $(DC) build

build-no-cache:
	@$(CHECK_ENV) && $(DC) build --no-cache

up:
	@$(CHECK_ENV) && $(DC) up -d ros-master gui-desktop gazebo robot_p3at_sim_ros1 robot_p3at_sim_ros2 ros2_bridge
	@echo "🎮 Laboratorio virtual híbrido completo activo."
	@echo "🖥️  Interfaz gráfica disponible en http://localhost:8080"

down:
	$(DC) down

restart:
	@$(CHECK_ENV) &&
	@if [ -z "$(s)" ]; then echo "⚠️ Especifica el servicio con s=<nombre>"; exit 1; fi
	$(DC) restart $(s)

logs:
	@$(CHECK_ENV) && $(DC) logs -f --tail=100

logs-gazebo:
	@$(CHECK_ENV) && $(DC) logs -f gazebo

shell-master:
	@$(CHECK_ENV) && $(EXEC) ros-master bash

shell-robot1:
	@$(CHECK_ENV) && $(EXEC) robot_p3at_sim_ros1 bash

shell-robot2:
	@$(CHECK_ENV) && $(EXEC) robot_p3at_sim_ros2 bash

shell-bridge:
	@$(CHECK_ENV) && $(EXEC) ros2_bridge bash

shell-gazebo:
	@$(CHECK_ENV) && $(EXEC) gazebo bash

shell-gui:
	@$(CHECK_ENV) && $(EXEC) gui-desktop bash -c "source /opt/ros/noetic/setup.bash && export DISPLAY=:1 && bash"

clean:
	docker compose down --v --rmi local
	docker system prune -f
	@echo "🧹 Docker limpio y espacio liberado."