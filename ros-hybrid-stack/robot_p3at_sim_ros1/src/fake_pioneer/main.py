#!/usr/bin/env python3
import os
import rospy
from geometry_msgs.msg import Twist
from strategy.square_motion import run as square

def main():
    rospy.init_node("fake_pioneer")

    ns = os.environ.get("ROBOT_NAMESPACE", "p3at_sim_1").strip().strip("/")
    cmd_topic = f"/{ns}/cmd_vel"
    pub = rospy.Publisher(cmd_topic, Twist, queue_size=10)
    rospy.loginfo("Publishing cmd_vel on %s", cmd_topic)

    strategy = "square"
    rospy.loginfo(f"Using strategy: {strategy}")

    square(pub)

if __name__ == "__main__":
    main()