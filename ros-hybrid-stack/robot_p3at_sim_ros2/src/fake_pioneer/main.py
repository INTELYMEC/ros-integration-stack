#!/usr/bin/env python3
"""Escucha /{ROBOT_ROS1_NAMESPACE}/cmd_vel en ROS2 (reflejado vía bridge desde el sim ROS1)."""
import os

import rclpy
from geometry_msgs.msg import Twist
from rclpy.node import Node

LOG_PATH = "/ros_test_shared/ros2_cmd_vel_rx.log"


class CmdVelBridgeListener(Node):
    def __init__(self):
        super().__init__("cmd_vel_bridge_listener")
        ns = os.environ.get("ROBOT_ROS1_NAMESPACE", "p3at_sim_1").strip().strip("/")
        topic = f"/{ns}/cmd_vel"
        self.sub = self.create_subscription(Twist, topic, self._cb, 10)
        self.get_logger().info(f"Subscribed to {topic} -> {LOG_PATH}")

    def _cb(self, msg: Twist):
        os.makedirs(os.path.dirname(LOG_PATH), exist_ok=True)
        with open(LOG_PATH, "a", encoding="utf-8") as f:
            f.write(f"{msg.linear.x}\n")
        self.get_logger().debug(f"logged linear.x={msg.linear.x}")


def main():
    rclpy.init()
    node = CmdVelBridgeListener()
    try:
        rclpy.spin(node)
    finally:
        node.destroy_node()
        rclpy.shutdown()


if __name__ == "__main__":
    main()
