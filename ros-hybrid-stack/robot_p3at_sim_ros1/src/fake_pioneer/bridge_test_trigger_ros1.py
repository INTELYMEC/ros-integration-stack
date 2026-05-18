#!/usr/bin/env python3
"""Recibe un disparador en ROS1 y publica un Twist distintivo en cmd_vel (para tests sim1→bridge→sim2)."""
import os

import rospy
from geometry_msgs.msg import Twist
from std_msgs.msg import String


def main():
    ns = os.environ.get("ROBOT_NAMESPACE", "p3at_sim_1").strip().strip("/")
    rospy.init_node("bridge_test_trigger_ros1", anonymous=False)
    cmd_topic = f"/{ns}/cmd_vel"
    trig_topic = f"/{ns}/ros1_bridge_test_trigger"
    pub = rospy.Publisher(cmd_topic, Twist, queue_size=1)
    rospy.sleep(0.5)

    def cb(_msg: String):
        t = Twist()
        t.linear.x = 7.77
        pub.publish(t)
        rospy.loginfo("Published bridge test cmd_vel (7.77)")

    rospy.Subscriber(trig_topic, String, cb, queue_size=1)
    rospy.loginfo("Listening on %s → %s", trig_topic, cmd_topic)
    rospy.spin()


if __name__ == "__main__":
    main()
