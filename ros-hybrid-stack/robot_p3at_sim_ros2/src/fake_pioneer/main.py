#!/usr/bin/env python3
import os
import rclpy
from rclpy.node import Node
from geometry_msgs.msg import Twist

from strategy.square_motion import run as square

class FakePioneerRos2(Node):
    def __init__(self):
        super().__init__("fake_pioneer_ros2")
        
        self.ns = os.environ.get("ROBOT_P3AT_ROS2_NAMESPACE", "p3at_sim_2").strip().strip("/")
        cmd_topic = f"/{self.ns}/cmd_vel"
        
        self.pub = self.create_publisher(Twist, cmd_topic, 10)
        self.get_logger().info(f"Publishing ROS 2 cmd_vel on {cmd_topic}")

def main():
    rclpy.init()
    node = FakePioneerRos2()
    
    try:
        # Ejecutamos la estrategia pasándole el nodo y su publicador
        square(node, node.pub)
    except KeyboardInterrupt:
        pass
    finally:
        node.destroy_node()
        rclpy.shutdown()

if __name__ == "__main__":
    main()