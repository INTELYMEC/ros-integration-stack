#!/bin/bash

# Suite de testing lineal y estricta
set -uo pipefail

FAILED=0

echo "===================================================="
echo "🚀 INICIANDO CERTIFICACIÓN DEL ECOSERVIDOR HÍBRIDO"
echo "===================================================="

run() {
    local name=$1
    shift
    if "$@"; then
        echo "✅ TEST: ${name} PASSED"
    else
        echo "❌ TEST: ${name} FAILED"
        FAILED=1
    fi
}

# 📦 SECCIÓN 1: INFRAESTRUCTURA Y RED COMÚN
echo "📦 [1/3] EVALUANDO INFRAESTRUCTURA BASE"
echo "-----------------------------------------------------"
run "Infraestructura: GUI Desktop Activo (noVNC)" timeout 2 bash -c "</dev/tcp/gui-desktop/80"
echo "-----------------------------------------------------"

# 📡 SECCIÓN 2: COMUNICACIONES Y GRAFOS (Cerebro)
echo "📡 [2/3] EVALUANDO GRAFOS DE DATOS Y BRIDGE HÍBRIDO"
echo "-----------------------------------------------------"
run "ROS1 intra-grafo" /tests/tests/test_robot_p3at_sim_ros1_intra_graph.sh
echo "-----------------------------------------------------"
run "ROS2 intra-grafo" /tests/tests/test_robot_p3at_sim_ros2_intra_graph.sh
echo "-----------------------------------------------------"
run "Bridge ROS1 → ROS2" /tests/tests/test_robot_p3at_sim_ros1_to_ros2_bridge.sh
echo "-----------------------------------------------------"
run "Bridge ROS2 → ROS1" /tests/tests/test_robot_p3at_sim_ros2_to_ros1_bridge.sh
echo "-----------------------------------------------------"
run "Sim ROS1 → Sim ROS2 (bridge)" /tests/tests/test_robot_p3at_sim_ros1_to_robot_p3at_sim_ros2_bridge.sh
echo "-----------------------------------------------------"
run "Sim ROS2 → Sim ROS1 (bridge)" /tests/tests/test_robot_p3at_sim_ros2_to_robot_p3at_sim_ros1_bridge.sh
echo "-----------------------------------------------------"

# 🎮 SECCIÓN 3: MOTOR FÍSICO DE GAZEBO
echo "🎮 [3/3] EVALUANDO MOTOR FÍSICO Y ENTIERRES (GAZEBO)"
echo "-----------------------------------------------------"

# Encapsulamos el entorno Noetic en subshells limpias para que no tire warnings de conflicto con Foxy
run "Gazebo: Publicación de Reloj (/clock)" \
    bash -c "unset ROS_DISTRO && source /opt/ros/noetic/setup.bash && rostopic info /clock > /dev/null"
echo "-----------------------------------------------------"

run "Gazebo: Entidad Pioneer Inyectada" \
    bash -c "unset ROS_DISTRO && source /opt/ros/noetic/setup.bash && rostopic type /gazebo/model_states | grep -q 'ModelStates'"
echo "-----------------------------------------------------"

run "Gazebo: Publicación de Odometría Física" \
    bash -c "unset ROS_DISTRO && source /opt/ros/noetic/setup.bash && rostopic info /p3at_sim_1/odom > /dev/null"

echo "===================================================="
echo "🏁 REPORTE FINALIZADO"
echo "===================================================="

exit "${FAILED}"