#!/usr/bin/env python3
import os
import math
import time
from geometry_msgs.msg import Twist
from nav_msgs.msg import Odometry

class SquareNavigatorRos2:
    def __init__(self, node, pub):
        self.node = node
        self.pub = pub
        self.ns = os.environ.get("ROBOT_ROS2_NAMESPACE", "p3at_sim_2").strip().strip("/")
        
        # Variables de estado actualizadas por odometría
        self.x = 0.0
        self.y = 0.0
        self.yaw = 0.0
        
        # Suscripción en ROS 2
        odom_topic = f"/{self.ns}/odom"
        self.sub = self.node.create_subscription(
            Odometry, 
            odom_topic, 
            self.odom_callback, 
            10
        )
        self.node.get_logger().info(f"Subscribed to ROS 2 odometry on {odom_topic}")
        
        # Pequeña pausa activa para esperar telemetría inicial
        time.sleep(1.0)

    def odom_callback(self, msg):
        """Procesa la telemetría del robot proveniente del bridge."""
        self.x = msg.pose.pose.position.x
        self.y = msg.pose.pose.position.y
        
        # Convertir Quaternion a ángulo Yaw (Radianes de -pi a pi)
        q = msg.pose.pose.orientation
        siny_cosp = 2.0 * (q.w * q.z + q.x * q.y)
        cosy_cosp = 1.0 - 2.0 * (q.y * q.y + q.z * q.z)
        self.yaw = math.atan2(siny_cosp, cosy_cosp)

    def move_straight(self, distance, speed=0.2, tolerance=0.03):
        """Avanza una distancia exacta en metros usando lazo cerrado en ROS 2."""
        start_x = self.x
        start_y = self.y
        msg = Twist()
        msg.linear.x = speed
        
        # Loop manual controlado usando rclpy.spin_once para procesar la odometría
        while rclpy_is_active(self.node):
            rclpy_spin_once(self.node, timeout_sec=0.05)
            
            current_distance = math.sqrt((self.x - start_x)**2 + (self.y - start_y)**2)
            error = distance - current_distance
            
            if error <= tolerance:
                break
                
            self.pub.publish(msg)
            
        # Frenar
        self.pub.publish(Twist())
        time.sleep(0.5)

    def turn(self, angle_degrees, speed=0.3, tolerance=0.04):
        """Gira un ángulo exacto en grados utilizando lazo cerrado en ROS 2."""
        target_yaw = self.yaw + math.radians(angle_degrees)
        target_yaw = math.atan2(math.sin(target_yaw), math.cos(target_yaw)) # Normalizar
        msg = Twist()
        
        while rclpy_is_active(self.node):
            rclpy_spin_once(self.node, timeout_sec=0.05)
            
            error = target_yaw - self.yaw
            error = math.atan2(math.sin(error), math.cos(error)) # Normalizar error
            
            if abs(error) <= tolerance:
                break
                
            msg.angular.z = speed if error > 0 else -speed
            self.pub.publish(msg)
            
        # Frenar rotación
        self.pub.publish(Twist())
        time.sleep(0.5)

    def execute_square(self):
        """Bucle infinito del cuadrado de precisión."""
        self.node.get_logger().info("Starting precision square tracking in ROS 2...")
        while rclpy_is_active(self.node):
            for side in range(4):
                self.node.get_logger().info(f"📐 ROS 2 Robot: Executing Side {side + 1}/4")
                self.move_straight(distance=1.0, speed=0.2)
                
                self.node.get_logger().info("🔄 ROS 2 Robot: Turning 90 degrees")
                self.turn(angle_degrees=90.0, speed=0.3)

# Funciones auxiliares globales para mitigar colisiones de contexto
def rclpy_is_active(node):
    import rclpy
    return rclpy.ok()

def rclpy_spin_once(node, timeout_sec):
    import rclpy
    rclpy.spin_once(node, timeout_sec=timeout_sec)

def run(node, pub):
    navigator = SquareNavigatorRos2(node, pub)
    navigator.execute_square()