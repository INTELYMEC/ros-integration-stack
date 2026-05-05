#!/usr/bin/env python3

import os
import rospy
from geometry_msgs.msg import Twist

from strategies.square_motion import run as square
from strategies.random_walk import run as random_walk

def main():
    rospy.init_node("fake_pioneer")

    pub = rospy.Publisher("/cmd_vel", Twist, queue_size=10)

    strategy = os.getenv("STRATEGY", "square")

    rospy.loginfo(f"Using strategy: {strategy}")

    if strategy == "square":
        square(pub)
    elif strategy == "random":
        random_walk(pub)
    else:
        rospy.logwarn("Unknown strategy, defaulting to square")
        square(pub)

if __name__ == "__main__":
    main()