
⚙️ Variables de Entorno (.env)
El archivo .env es obligatorio para la ejecución. El Makefile bloqueará cualquier comando operativo si este archivo no se encuentra en la raíz. Existe una plantilla base de referencia en .env.example.

Contrato de Variables Exigidas
Variable	Propósito / Opciones
ROS1_BASE_IMAGE	Imagen base Noetic (ej: arm64v8/ros:noetic para Mac M1/M2/M3, ros:noetic para Intel).
ROS2_BASE_IMAGE	Imagen base Foxy (ej: arm64v8/ros:foxy-ros-base para Mac, ros:foxy-ros-base para Intel).
ROS_DOMAIN_ID	Identificador de aislamiento de subred para ROS 2 (Default: 0).
ROBOT_ROS1_NAMESPACE	Namespace asignado al robot en el grafo ROS 1 (p3at_sim_1).
ROBOT_ROS2_NAMESPACE	Namespace asignado al robot en el grafo ROS 2 (p3at_sim_2).
STRATEGY	Patrón matemático de navegación del robot (square / random).
ROS_MASTER_HOSTNAME	Hostname de resolución para el Máster (Uso local: ros-master / Físico: IP del robot).
ROS_MASTER_PORT	Puerto de escucha del máster (Default: 11311).
ROBOT_MODEL_FILE	Nombre del archivo URDF en la carpeta robots/ (ej: pioneer3at.urdf).
ROBOT_MODEL_NAME	Nombre de la entidad para el registro interno de Gazebo (ej: pioneer3at).
GAZEBO_WORLD_FILE	Archivo de escenario dentro de la carpeta worlds/ (ej: pioneer_world.world).
GAZEBO_GUI_ENABLED	Activa la UI pesada de Gazebo nativa (true para Ubuntu nativo / false para Mac/Win).
HOST_DISPLAY	Socket gráfico del host para Ubuntu nativo (:0).

🚀 Guía de Arranque Rápido
1. Clonar e Inicializar el Entorno Local
Bash
cd ros-hybrid-stack
cp .env.example .env
💡 Nota de seguridad: Edita el .env recién creado e inyecta los tags de tus imágenes base según la arquitectura de tu procesador (Intel o Apple Silicon).

2. Compilar el Ecosistema Híbrido
Bash
make build
(Al compilar el puente dinámico desde las fuentes de ROS, la primera ejecución puede demorar unos minutos).

3. Levantar el Laboratorio Completo
Bash
make up
Una vez ejecutado, abrí tu navegador e ingresá a http://localhost:8080. Introducí la credencial de acceso ubuntu y verás el escritorio virtual con RViz escuchando los tópicos en tiempo real.

🕵️ Certificación y Suite de Tests Automatizados
El framework cuenta con una suite rigurosa de 10 pruebas automatizadas encapsuladas que evalúan la infraestructura de sockets, la integridad de los grafos aislados, la consistencia del bridge bidireccional y las telemetrías del motor de física de Gazebo.

Para lanzar la auditoría sobre tu stack activo, simplemente ejecutá:

Bash
make test
Unidades de Verificación Incluidas:
Infraestructura: Disponibilidad HTTP/WebSocket del servidor visual gui-desktop (Puerto 80).

ROS 1 Intra-grafo: Publicación y lectura interna aislada en Noetic.

ROS 2 Intra-grafo: Publicación y descubrimiento de nodos bajo CycloneDDS en Foxy.

Bridge Flujo Directo: Ingesta de cmd_vel desde ROS 1 y captura correcta reflejada en ROS 2.

Bridge Flujo Inverso: Publicación en ROS 2 y lectura de estructuras geometry_msgs/Twist en ROS 1.

Sim Cross-Talk ROS1 ──► ROS2: Triggers de eventos simulados cruzando el puente.

Sim Cross-Talk ROS2 ──► ROS1: Respuesta inversa de eventos de simulación.

Gazebo Clock: Publicación activa del reloj de simulación de física cuántica (/clock).

Gazebo Entity: Verificación de inyección correcta del modelo URDF en los estados del mundo.

Gazebo Odometry: Validación de publicación de telemetría de chasis física (/odom).

🛠️ Atajos del Desarrollador (Makefile)
Todos los comandos operativos están centralizados y protegidos por el validador del .env:

make up: Levanta de forma coordinada el máster, entorno gráfico, simulación y puentes de datos.

make down: Apaga todos los servicios destruyendo la asignación de red temporal para evitar colisiones.

make test: Compila y lanza el inspector efímero de pruebas mostrando el reporte final de éxitos/fallos.

make restart s=<nombre_servicio>: Reinicia en caliente un único contenedor (ej: make restart s=robot_p3at_sim_ros1).

make clean: Purga profunda de Docker eliminando volúmenes locales residuales y liberando espacio en disco.

Acceso Directo a Terminales (Shells)
Si necesitás auditar tópicos manualmente mediante comandos nativos (rostopic, ros2 topic), podés inyectarte directo en caliente en los contenedores usando:

make shell-master

make shell-robot1

make shell-robot2

make shell-bridge

make shell-gazebo

make shell-gui (Inicializa la shell directo con el entorno sourceado y permisos X11).