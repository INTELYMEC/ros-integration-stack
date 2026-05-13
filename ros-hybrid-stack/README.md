# ROS Hybrid Stack

Proyecto: ROS Hybrid Stack (ROS1 + ROS2 con Docker)

Integración híbrida entre **ROS 1 Noetic** y **ROS 2 Foxy** con Docker y `ros1_bridge` (bridge dinámico). Incluye **dos robots simulados con prefijos distintos**: uno asociado al grafo ROS1 (`p3at_sim_1` por defecto) y otro al grafo ROS2 (`p3at_sim_2` por defecto), de forma que el bridge refleja tópicos con el **mismo nombre** en ambos mundos.

## Arquitectura

Servicios principales:

- **`robot_p3at_sim_ros1`**
  - ROS 1 Noetic: `roscore`, `fake_pioneer` (publica `cmd_vel` bajo `ROBOT_NAMESPACE` = robot ROS1) y `bridge_test_trigger_ros1` para tests sim↔sim.

- **`robot_p3at_sim_ros2`**
  - ROS 2 Foxy: código en `src/fake_pioneer/` (misma idea de paquete que en el sim ROS1).
  - `main.py`: escucha `/${ROBOT_ROS1_NAMESPACE}/cmd_vel` en ROS2 (línea reflejada desde el sim ROS1 vía bridge).
  - `bridge_test_trigger_ros2.py`: disparador bajo `/${ROBOT_ROS2_NAMESPACE}/` para tests ROS2 → ROS1.

- **`ros2_bridge`**
  - Imagen híbrida Noetic + Foxy, `ros1_bridge` compilado, `dynamic_bridge --bridge-all-topics`.

- **`ros_tests`** (perfil `test`)
  - Pruebas intra-grafo y a través del bridge.

Red Docker: `rosnet`.

### Esquema conceptual

```text
[ robot_p3at_sim_ros1 ]                    [ robot_p3at_sim_ros2 ]
ROS1 Noetic                                ROS2 Foxy
/p3at_sim_1/cmd_vel  …                     escucha /p3at_sim_1/cmd_vel (vía bridge)
/p3at_sim_1/ros1_bridge_test_trigger       /p3at_sim_2/cmd_vel, ros2_bridge_test_trigger

                    ⇅  [ ros2_bridge ]
                    ros1_bridge
```

## Variables de entorno (`.env`)

Copia `.env.example` a `.env` y ajusta:

| Variable | Rol |
|----------|-----|
| `ROS2_BASE_IMAGE` | Imagen base Foxy (en ARM: `arm64v8/ros:foxy-ros-base`). |
| `ROS_MASTER_HOSTNAME` | Hostname del master ROS1 (`robot_p3at_sim_ros1`). |
| `ROS_DOMAIN_ID` | Dominio DDS ROS2. |
| `ROBOT_ROS1_NAMESPACE` | Prefijo del robot solo en ROS1 (default `p3at_sim_1`). |
| `ROBOT_ROS2_NAMESPACE` | Prefijo del robot solo en ROS2 (default `p3at_sim_2`). |
| `STRATEGY` | Estrategia del fake pioneer: `square` o `random`. |

En `docker-compose`, el contenedor ROS1 recibe `ROBOT_NAMESPACE=${ROBOT_ROS1_NAMESPACE}` para compatibilidad con el código existente de `fake_pioneer`.

## Requisitos

- Docker y Docker Compose v2 (`docker compose`).

## Atajos de ejecución

- `scripts/bash/` (Linux/macOS) y `scripts/powershell/` (Windows).

Comandos típicos:

- `make build` / `make build-no-cache`
- `make up` — levanta `robot_p3at_sim_ros1`, `robot_p3at_sim_ros2` y `ros2_bridge`
- `make down`
- `make test` — construye, levanta los tres servicios anteriores, ejecuta `ros_tests`, hace `down -v`
- `make ros1-shell` → `robot_p3at_sim_ros1`
- `make ros2-sim-shell` → `robot_p3at_sim_ros2`
- `make ros2-shell` → `ros2_bridge`
- `make logs`

## Primeros pasos

```bash
cd ros-hybrid-stack
cp .env.example .env   # opcional
make build
make up
```

## Comprobación de contenedores

```bash
docker ps
```

Deberías ver `robot_p3at_sim_ros1`, `robot_p3at_sim_ros2` y `ros2_bridge`.

## Onboarding: comandos manuales con namespaces

Sustituye `NS1`/`NS2` por tus valores de `.env` (por defecto `p3at_sim_1` y `p3at_sim_2`).

### Publicar en ROS2 y escuchar en ROS1

En `ros2_bridge` (Foxy), publica en `/${NS2}/cmd_vel`. En otra sesión, dentro del mismo contenedor o en ROS1, `rostopic echo /${NS2}/cmd_vel` debe ver el mensaje si el bridge enlaza el tópico.

### Publicar en ROS1 y escuchar en ROS2

Desde `robot_p3at_sim_ros1`, publica en `/${NS1}/cmd_vel`. En `ros2_bridge`, `ros2 topic echo /${NS1}/cmd_vel` debe mostrar los `Twist`.

## Pruebas automatizadas

El contenedor `ros_tests` ejecuta scripts en `/tests/tests/` (intra ROS1/ROS2, bridge en ambas direcciones, sim↔sim vía bridge).

```bash
make test
```

O manualmente:

```bash
docker compose run --rm ros_tests
```

Dentro del contenedor de tests:

```bash
/tests/run_tests.sh
```

## Notas útiles

- El bridge refleja tópicos por **nombre**; para cruzar mensajes entre “robot ROS1” y “robot ROS2” los tests publican en el namespace que corresponde al origen y escuchan el **mismo path** en el otro grafo cuando aplica.
- `ros2_bridge` compila `ros1_bridge` en Foxy contra Noetic según el `Dockerfile` del bridge.

## Flujo de ejemplo con compose

```bash
docker compose down -v
docker compose build --no-cache
docker compose up robot_p3at_sim_ros1 robot_p3at_sim_ros2 ros2_bridge
```
