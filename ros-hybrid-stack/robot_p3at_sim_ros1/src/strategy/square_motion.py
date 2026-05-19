#!/usr/bin/env python3
import os
import math
import rospy
from geometry_msgs.msg import Twist
from nav_msgs.msg import Odometry

class SquareNavigator:
    def __init__(self, pub):
        self.pub = pub
        self.ns = os.environ.get("ROBOT_NAMESPACE", "p3at_sim_1").strip().strip("/")
        
        # Variables de estado del robot (actualizadas por odometría)
        self.x = 0.0
        self.y = 0.0
        self.yaw = 0.0
        
        # Suscripción al tópico de odometría real de Gazebo
        odom_topic = f"/{self.ns}/odom"
        rospy.Subscriber(odom_topic, Odometry, self.odom_callback)
        rospy.loginfo(f"Subscribed to odometry on {odom_topic}")
        
        # Esperar a recibir el primer paquete de odometría para no arrancar a ciegas
        rospy.sleep(1.0)

    def odom_callback(self, msg):
        """Procesa la telemetría del motor físico de Gazebo."""
        self.x = msg.pose.pose.position.x
        self.y = msg.pose.pose.position.y
        
        # Convertir Quaternion a ángulo Yaw (Radianes de -pi a pi)
        q = msg.pose.pose.orientation
        siny_cosp = 2.0 * (q.w * q.z + q.x * q.y)
        cosy_cosp = 1.0 - 2.0 * (q.y * q.y + q.z * q.z)
        self.yaw = math.atan2(siny_cosp, cosy_cosp)

    def move_straight(self, distance, speed=0.2, tolerance=0.02):
        """Avanza una distancia exacta en metros usando lazo cerrado."""
        rate = rospy.Rate(20) # Control loop a 20Hz
        start_x = self.x
        start_y = self.y
        
        msg = Twist()
        msg.linear.x = speed
        
        while not rospy.is_shutdown():
            # Calcular distancia euclidiana recorrida desde el inicio del tramo
            current_distance = math.sqrt((self.x - start_x)**2 + (self.y - start_y)**2)
            error = distance - current_distance
            
            if error <= tolerance:
                break
                
            self.pub.publish(msg)
            rate.sleep()
            
        # Frenar el robot al llegar
        self.pub.publish(Twist())
        rospy.sleep(0.5)

    def turn(self, angle_degrees, speed=0.3, tolerance=0.03):
        """Gira un ángulo exacto en grados utilizando lazo cerrado."""
        rate = rospy.Rate(20)
        target_yaw = self.yaw + math.radians(angle_degrees)
        
        # Normalizar el ángulo objetivo entre -pi y pi
        target_yaw = math.atan2(math.sin(target_yaw), math.cos(target_yaw))
        
        msg = Twist()
        
        while not rospy.is_shutdown():
            # Calcular el error de rotación angular mínimo
            error = target_yaw - self.yaw
            error = math.atan2(math.sin(error), math.cos(error)) # Normalizar error
            
            if abs(error) <= tolerance:
                break
            
            # Control proporcional simple para suavizar el frenado del giro
            msg.angular.z = speed if error > 0 else -speed
            self.pub.publish(msg)
            rate.sleep()
            
        # Frenar la rotación
        self.pub.publish(Twist())
        rospy.sleep(0.5)

    def execute_square(self):
        """Ejecuta los 4 lados del cuadrado de 1x1 metros de forma infinita."""
        rospy.loginfo("Starting precision square motion tracking...")
        while not rospy.is_shutdown():
            for side in range(4):
                rospy.loginfo(f"📐 Executing Side {side + 1}/4")
                self.move_straight(distance=1.0, speed=0.2)
                
                rospy.loginfo("🔄 Turning 90 degrees")
                self.turn(angle_degrees=90.0, speed=0.3)

def run(pub):
    navigator = SquareNavigator(pub)
    navigator.execute_square()