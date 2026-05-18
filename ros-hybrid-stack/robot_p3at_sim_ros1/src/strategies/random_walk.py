import rospy
import random
from geometry_msgs.msg import Twist

def run(pub):
    rate = rospy.Rate(1)

    while not rospy.is_shutdown():
        msg = Twist()
        msg.linear.x = random.uniform(0, 1)
        msg.angular.z = random.uniform(-1, 1)
        pub.publish(msg)
        rate.sleep()
