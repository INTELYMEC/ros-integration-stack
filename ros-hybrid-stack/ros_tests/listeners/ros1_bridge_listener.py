#!/usr/bin/env python3

import rospy
from std_msgs.msg import String
from geometry_msgs.msg import Twist

pub = None


def callback(msg):
    twist = Twist()
    twist.linear.x = 8.88

    pub.publish(twist)

    rospy.loginfo("published 8.88")


def main():
    global pub

    rospy.init_node("ros1_bridge_listener")

    pub = rospy.Publisher(
        "/p3at_sim_2/cmd_vel",
        Twist,
        queue_size=10
    )

    rospy.Subscriber(
        "/p3at_sim_2/ros_bridge_test_trigger",
        String,
        callback
    )

    rospy.spin()


if __name__ == "__main__":
    main()