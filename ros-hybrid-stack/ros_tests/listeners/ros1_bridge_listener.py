#!/usr/bin/env python3

import os

import rospy

from std_msgs.msg import String
from geometry_msgs.msg import Twist

LOG_FILE = os.environ.get(
    "BRIDGE_LOG_FILE",
    "/tmp/test_sim_r2_r1.txt"
)

CMD_VEL_TOPIC = os.environ.get(
    "BRIDGE_CMD_VEL_TOPIC",
    "/p3at_sim_2/cmd_vel"
)

class BridgeListener:

    def __init__(self):

        self.trigger_topic = os.environ.get(
            "BRIDGE_TRIGGER_TOPIC",
            "/p3at_sim_2/ros_bridge_test_trigger"
        )

        rospy.init_node("ros1_bridge_listener")

        self.pub = rospy.Publisher(
            CMD_VEL_TOPIC,
            Twist,
            queue_size=10
        )

        rospy.Subscriber(
            self.trigger_topic,
            String,
            self.callback
        )

        rospy.loginfo(
            f"Listening bridge trigger on {self.trigger_topic}"
        )

        rospy.loginfo(
            f"Publishing Twist on {CMD_VEL_TOPIC}"
        )

    def callback(self, msg):

        rospy.loginfo(f"Trigger received: {msg.data}")

        twist = Twist()
        twist.linear.x = 8.88

        self.pub.publish(twist)

        with open(LOG_FILE, "w") as f:
            f.write("8.88\n")

        rospy.loginfo("published 8.88")

def main():

    BridgeListener()

    rospy.spin()

if __name__ == "__main__":
    main()