#!/usr/bin/env python3

import os

import rclpy
from rclpy.node import Node

from geometry_msgs.msg import Twist
from nav_msgs.msg import Odometry
from std_msgs.msg import String


class FakeGo2Node(Node):

    def __init__(self):

        super().__init__("fake_go2_ros2")

        self.ns = os.environ.get(
            "ROBOT_GO2_ROS2_NAMESPACE",
            "go2_sim_1"
        ).strip().strip("/")

        cmd_topic = f"/{self.ns}/cmd_vel"
        odom_topic = f"/{self.ns}/odom"
        status_topic = f"/{self.ns}/status"

        self.cmd_sub = self.create_subscription(
            Twist,
            cmd_topic,
            self.cmd_callback,
            10
        )

        self.odom_pub = self.create_publisher(
            Odometry,
            odom_topic,
            10
        )

        self.status_pub = self.create_publisher(
            String,
            status_topic,
            10
        )

        self.timer = self.create_timer(
            1.0,
            self.publish_fake_data
        )

        self.get_logger().info(
            f"Fake Go2 node started in namespace: {self.ns}"
        )

    def cmd_callback(self, msg):

        self.get_logger().info(
            f"cmd_vel received -> linear.x={msg.linear.x} angular.z={msg.angular.z}"
        )

    def publish_fake_data(self):

        odom = Odometry()
        odom.header.frame_id = "odom"
        odom.child_frame_id = "base_link"

        self.odom_pub.publish(odom)

        status = String()
        status.data = "GO2_OK"

        self.status_pub.publish(status)


def main(args=None):

    rclpy.init(args=args)

    node = FakeGo2Node()

    try:
        rclpy.spin(node)

    except KeyboardInterrupt:
        pass

    finally:
        node.destroy_node()
        rclpy.shutdown()


if __name__ == "__main__":
    main()