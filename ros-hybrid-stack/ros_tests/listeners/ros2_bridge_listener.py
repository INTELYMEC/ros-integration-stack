#!/usr/bin/env python3

import os

import rclpy
from rclpy.node import Node

from std_msgs.msg import String


class RosBridgeListener(Node):

    def __init__(self):
        super().__init__('ros_bridge_listener')

        ns1 = os.environ.get("ROBOT_P3AT_ROS1_NAMESPACE", "p3at_sim_1").strip("/")
        trigger_topic = f"/{ns1}/ros1_bridge_test_trigger"

        self.log_file = "/ros_test_shared/ros2_cmd_vel_rx.log"

        self.subscription = self.create_subscription(
            String,
            trigger_topic,
            self.callback,
            10
        )

        self.get_logger().info(
            f"Listening bridge trigger on {trigger_topic}"
        )

    def callback(self, msg):
        self.get_logger().info(
            f"Trigger received: {msg.data}"
        )

        with open(self.log_file, "a") as f:
            f.write("7.77\n")

        self.get_logger().info(
            f"Wrote 7.77 into {self.log_file}"
        )


def main():
    rclpy.init()

    node = RosBridgeListener()

    try:
        rclpy.spin(node)
    except KeyboardInterrupt:
        pass

    node.destroy_node()
    rclpy.shutdown()


if __name__ == "__main__":
    main()