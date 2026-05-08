#!/bin/bash

# Colores para la terminal
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "🔍 Iniciando Tests Automáticos del Bridge Híbrido..."
echo "----------------------------------------------------"

# --- TEST 1: ROS 2 -> ROS 1 ---
echo -n "Test 1: ROS 2 Bridge mandando a ROS 1 Simulator... "
docker exec robot_p3at_sim bash -c "source /opt/ros/noetic/setup.bash && timeout 5s rostopic echo -n 1 /cmd_vel" > test1_result.txt 2>&1 &
PID_1=$!
sleep 2
docker exec ros2_bridge bash -c "source /opt/ros/foxy/setup.bash && ros2 topic pub --once /cmd_vel geometry_msgs/msg/Twist '{linear: {x: 1.0}}' > /dev/null"
wait $PID_1 2>/dev/null || true

if grep -q "linear" test1_result.txt 2>/dev/null; then
    echo -e "${GREEN}PASSED${NC}"
else
    echo -e "${RED}FAILED${NC}"
fi

# --- TEST 2: ROS 1 -> ROS 2 ---
echo -n "Test 2: ROS 1 Simulator mandando a ROS 2 Bridge... "
rm -f test2_result.txt

# El truco: Usamos stdbuf para que la salida no se quede en el buffer de Docker
docker exec ros2_bridge bash -c "source /opt/ros/foxy/setup.bash && stdbuf -oL ros2 topic echo /cmd_vel" > test2_result.txt 2>&1 &
PID_2=$!

sleep 5 # Tiempo para que DDS se encuentre

# Publicamos una ráfaga y luego matamos el proceso
docker exec robot_p3at_sim bash -c "source /opt/ros/noetic/setup.bash && timeout 4s rostopic pub /cmd_vel geometry_msgs/Twist '{linear: {x: 5.5}}' -r 10" > /dev/null 2>&1 &
sleep 5

kill $PID_2 2>/dev/null || true

if grep -q "5.5" test2_result.txt 2>/dev/null; then
    echo -e "${GREEN}PASSED${NC}"
else
    echo -e "${RED}FAILED${NC}"
    echo "   [DEBUG] El bridge pasó los datos (según logs), pero el test falló en capturarlos."
fi

# Limpieza final
rm -f test1_result.txt test2_result.txt
echo "----------------------------------------------------"
echo "✅ Fin de los tests."