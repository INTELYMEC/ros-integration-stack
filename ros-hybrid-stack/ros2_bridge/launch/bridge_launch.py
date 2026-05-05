from launch import LaunchDescription
from launch_ros.actions import Node

def generate_launch_description():

    return LaunchDescription([
        Node(
            package='ros1_bridge',
            executable='dynamic_bridge',
            name='ros1_ros2_bridge',
            output='screen',
        )
    ])
