# ROS Hybrid Stack

Proyecto: ROS Hybrid Stack (ROS1 + ROS2 con Docker)

El proyecto ROS Hybrid Stack implementa una integración híbrida entre ROS 1 Noetic y ROS 2 Foxy usando Docker y un bridge dinámico. El objetivo es permitir la comunicación de topics bidireccional entre un nodo ROS1 simulado y un bridge ROS2 que traduce mensajes entre ambos mundos.

## Arquitectura

El stack tiene tres servicios principales:

- `robot_p3at_sim`
  - Contenedor ROS1 Noetic
  - Ejecuta `roscore` y un nodo simulado de robot
  - Publica y/o consume el topicos, ejemplo: `/cmd_vel`

- `ros2_bridge`
  - Contenedor híbrido ROS1 Noetic + ROS2 Foxy
  - Instala y compila `ros1_bridge`
  - Actúa como puente dinámico entre ROS1 y ROS2

- `ros_tests`
  - Contenedor de pruebas
  - Verifica la comunicación ROS1 ↔ ROS2 entre los servicios

Todos los servicios están unidos en la red Docker `rosnet`.

### Arquitectura final conceptual

```text
[ robot_p3at_sim ]
ROS1 Noetic
- roscore
- fake pioneer
- publica /cmd_vel

        ⇅

[ ros2_bridge ]
ROS1 Noetic + ROS2 Foxy
- ros1_bridge
- dynamic_bridge
- traduce topics ROS1 ↔ ROS2
```

## Requisitos

- Docker instalado
- Docker Compose compatible con `docker compose`
- Acceso a la terminal en la carpeta raíz del proyecto

> Si usas Mac M1/ARM, revisa el archivo `.env` para usar `ROS2_BASE_IMAGE=arm64v8/ros:foxy-ros-base`.

## Primeros pasos

1. Sitúate en la raíz del proyecto:

```bash
cd ../ros-integration-stack/ros-hybrid-stack
```

2. Construye los contenedores:

```bash
docker compose down -v
docker compose build --no-cache
```

3. Inicia el stack:

```bash
docker compose up
```

> También se pueden usar `docker compose up --build` si prefieres construir e iniciar en un solo paso.

## Comprobación de contenedores

En otra terminal revisa que los contenedores estén activos:

```bash
docker ps
```

Deberías ver al menos:

- `robot_p3at_sim`
- `ros2_bridge`
- `ros_tests`

## Onboarding práctico: comandos manuales

### Test 1: publicar en ROS2 y escuchar en ROS1

Terminal A (ROS2 Bridge):

```bash
docker exec -it ros2_bridge bash
source /opt/ros/foxy/setup.bash
ros2 topic list
ros2 topic echo /cmd_vel
```

Terminal B (ROS2 Bridge):

```bash
docker exec -it ros2_bridge bash
source /opt/ros/foxy/setup.bash
ros2 topic pub --once /cmd_vel geometry_msgs/msg/Twist "{linear: {x: 1, y: 1, z: 1}, angular: {x: 2, y: 2, z: 2}}"
```

Terminal C (ROS1):

```bash
docker exec -it robot_p3at_sim bash
source /opt/ros/noetic/setup.bash
rostopic echo /cmd_vel
```

Si el bridge funciona bien, verás el mensaje publicado desde ROS2 llegando a ROS1.

### Test 2: publicar en ROS1 y escuchar en ROS2

Terminal A (ROS1):

```bash
docker exec -it robot_p3at_sim bash
source /opt/ros/noetic/setup.bash
rostopic pub -r 10 /cmd_vel geometry_msgs/Twist "{linear: {x: 1, y: 1, z: 1}, angular: {x: 2, y: 2, z: 2}}"
```

Terminal B (ROS2 Bridge):

```bash
docker exec -it ros2_bridge bash
source /opt/ros/foxy/setup.bash
ros2 topic echo /cmd_vel
```

En esta prueba deberías recibir en ROS2 los mensajes publicados desde el contenedor ROS1.

## Pruebas automatizadas

El contenedor `ros_tests` ejecuta dos pruebas básicas:

- `ros1 -> ros2`
- `ros2 -> ros1`

Para ejecutar las pruebas manualmente desde el host:

```bash
chmod +x ros_tests/run_tests.sh
docker compose up --build
```

Si prefieres ejecutar la prueba dentro del contenedor `ros_tests`, haz:

```bash
docker exec -it ros_tests bash
/tests/run_tests.sh
```

## Notas útiles

- `ROS_MASTER_HOSTNAME` está definido en `.env` como `robot_p3at_sim`.
- `ROS_DOMAIN_ID` también se configura en `.env` para el entorno ROS2.
- En `ros2_bridge` se compila dinámicamente `ros1_bridge` para que pueda traducir mensajes entre Noetic y Foxy.

## Flujo de comandos de ejemplo

```bash
docker compose down -v
docker compose build --no-cache
docker compose up
```

Este README ya contiene los pasos necesarios para arrancar el proyecto, usar los contenedores y validar la comunicación entre ROS1 y ROS2.
