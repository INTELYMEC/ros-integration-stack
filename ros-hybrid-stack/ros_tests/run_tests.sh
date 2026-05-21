#!/bin/bash

set -uo pipefail

FAILED=0

declare -a RESULTS=()

echo "===================================================="
echo "🚀 INICIANDO CERTIFICACIÓN DEL ECOSISTEMA HÍBRIDO"
echo "===================================================="

run() {

    local name=$1
    shift

    if "$@"; then
        echo "✅ TEST: ${name} PASSED"

        RESULTS+=("PASS | ${name}")

    else
        echo "❌ TEST: ${name} FAILED"

        RESULTS+=("FAIL | ${name}")

        FAILED=1
    fi
}

# =====================================================
# 📦 INFRAESTRUCTURA
# =====================================================

echo "📦 [1/5] INFRAESTRUCTURA"
echo "-----------------------------------------------------"

run "GUI Desktop activo" \
    /tests/infrastructure/test_gui_desktop.sh

# =====================================================
# 📡 GRAFOS
# =====================================================

echo "📡 [2/5] GRAFOS ROS"
echo "-----------------------------------------------------"

run "P3AT ROS1 intra-graph" \
    /tests/graph/test_robot_p3at_sim_ros1_intra_graph.sh

run "P3AT ROS2 intra-graph" \
    /tests/graph/test_robot_p3at_sim_ros2_intra_graph.sh

run "GO2 ROS2 intra-graph" \
    /tests/graph/test_robot_go2_sim_ros2_intra_graph.sh

# =====================================================
# 🌉 BRIDGE
# =====================================================

echo "🌉 [3/5] BRIDGE ROS1 ↔ ROS2"
echo "-----------------------------------------------------"

run "ROS1 → ROS2 bridge" \
    /tests/bridge/test_ros1_to_ros2_bridge.sh

run "ROS2 → ROS1 bridge" \
    /tests/bridge/test_ros2_to_ros1_bridge.sh

# =====================================================
# 🤝 INTEROPERABILIDAD
# =====================================================

echo "🤝 [4/5] INTEROPERABILIDAD MULTI-ROBOT"
echo "-----------------------------------------------------"

run "P3AT ROS1 → P3AT ROS2" \
    /tests/interoperability/test_robot_p3at_sim_ros1_to_robot_p3at_sim_ros2_bridge.sh

run "P3AT ROS2 → P3AT ROS1" \
    /tests/interoperability/test_robot_p3at_sim_ros2_to_robot_p3at_sim_ros1_bridge.sh

run "P3AT ROS1 → GO2 ROS2" \
    /tests/interoperability/test_robot_p3at_sim_ros1_to_robot_go2_sim_ros2_bridge.sh

run "GO2 ROS2 → P3AT ROS1" \
    /tests/interoperability/test_robot_go2_sim_ros2_to_robot_p3at_sim_ros1_bridge.sh

run "GO2 ROS2 → P3AT ROS2" \
    /tests/interoperability/test_robot_go2_sim_ros2_to_robot_p3at_sim_ros2_bridge.sh

run "P3AT ROS2 → GO2 ROS2" \
    /tests/interoperability/test_robot_p3at_sim_ros2_to_robot_go2_sim_ros2_bridge.sh

# =====================================================
# 🎮 SIMULACIÓN
# =====================================================

echo "🎮 [5/5] SIMULACIÓN"
echo "-----------------------------------------------------"

run "Gazebo clock" \
    /tests/simulation/test_gazebo_clock.sh

run "Gazebo model states" \
    /tests/simulation/test_gazebo_model_states.sh

# =====================================================
# 🤖 CONTRATOS FÍSICOS
# =====================================================

echo "🤖 [EXTRA] CONTRATOS FÍSICOS"
echo "-----------------------------------------------------"

run "P3AT físico ROS1" \
    /tests/contracts/test_robot_p3at_phy_ros1.sh

run "GO2 físico ROS2" \
    /tests/contracts/test_robot_go2_phy_ros2.sh

echo "===================================================="
echo "🏁 REPORTE FINALIZADO"
echo "===================================================="

echo ""
echo "===================================================="
echo "📊 RESUMEN FINAL"
echo "===================================================="

for result in "${RESULTS[@]}"; do
    echo "${result}"
done

echo "===================================================="

if [ "${FAILED}" -eq 0 ]; then
    echo "🎉 TODOS LOS TESTS PASARON"
else
    echo "❌ EXISTEN TESTS FALLIDOS"
fi

echo "===================================================="

exit "${FAILED}"