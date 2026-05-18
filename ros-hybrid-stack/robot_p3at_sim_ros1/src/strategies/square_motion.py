import rospy
from geometry_msgs.msg import Twist

def run(pub):
    rate = rospy.Rate(1)

    move = Twist()
    turn = Twist()

    move.linear.x = 0.5
    turn.angular.z = 1.57

    while not rospy.is_shutdown():
        for _ in range(4):
            for _ in range(3):
                pub.publish(move)
                rate.sleep()
            for _ in range(2):
                pub.publish(turn)
                rate.sleep()
