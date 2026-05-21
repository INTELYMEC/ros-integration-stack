#!/usr/bin/env python3

import os

import rclpy
from rclpy.node import Node

from std_msgs.msg import String

LOG_FILE = "/ros_test_shared/ros2_cmd_vel_rx.log"

class BridgeListener(Node):

    def __init__(self):
        super().__init__("ros_bridge_listener")

        self.trigger_topic = os.environ.get(
            "BRIDGE_TRIGGER_TOPIC",
            "/p3at_sim_1/ros1_bridge_test_trigger"
        )

        self.subscription = self.create_subscription(
            String,
            self.trigger_topic,
            self.callback,
            10
        )

        self.get_logger().info(
            f"Listening bridge trigger on {self.trigger_topic}"
        )

    def callback(self, msg):

        self.get_logger().info(
            f"Trigger received: {msg.data}"
        )

        os.makedirs("/ros_test_shared", exist_ok=True)

        with open(LOG_FILE, "w") as f:
            f.write("7.77\n")

        self.get_logger().info(
            f"Wrote 7.77 into {LOG_FILE}"
        )

def main():

    rclpy.init()

    node = BridgeListener()

    try:
        rclpy.spin(node)
    finally:
        node.destroy_node()
        rclpy.shutdown()

if __name__ == "__main__":
    main()