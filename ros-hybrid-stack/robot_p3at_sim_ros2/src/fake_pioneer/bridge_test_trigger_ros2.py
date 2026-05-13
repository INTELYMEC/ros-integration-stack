#!/usr/bin/env python3
"""Disparador ROS2 → publica Twist en cmd_vel del robot ROS2 (tests sim2→bridge→ROS1)."""
import os
import time

import rclpy
from geometry_msgs.msg import Twist
from rclpy.node import Node
from std_msgs.msg import String


class BridgeTestTriggerRos2(Node):
    def __init__(self):
        super().__init__("bridge_test_trigger_ros2")
        ns = os.environ.get("ROBOT_ROS2_NAMESPACE", "p3at_sim_2").strip().strip("/")
        self._pub = self.create_publisher(Twist, f"/{ns}/cmd_vel", 10)
        self.create_subscription(
            String,
            f"/{ns}/ros2_bridge_test_trigger",
            self._cb,
            10,
        )
        self.get_logger().info(f"Listening on /{ns}/ros2_bridge_test_trigger")

    def _cb(self, _msg: String):
        t = Twist()
        t.linear.x = 8.88
        self._pub.publish(t)
        self.get_logger().info("Published bridge test cmd_vel (8.88)")


def main():
    rclpy.init()
    node = BridgeTestTriggerRos2()
    time.sleep(0.5)
    try:
        rclpy.spin(node)
    finally:
        node.destroy_node()
        rclpy.shutdown()


if __name__ == "__main__":
    main()
