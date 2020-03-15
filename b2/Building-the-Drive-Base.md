Then I built the lower level which contained the drive system. I sourced parts from Pololu, Mouser, Amazon.com, and the local Ace Hardware store.

Pololu had a big sale during Black Friday 2017, so I picked up a bunch of parts during that sale, including a [Roboclaw 2x7A motor controller](https://www.pololu.com/product/3284). This is the red box on the lower shelf in the design picture above. 

This turned out to be a great move for me, because my alternative was to use an Arduino as the controller. But the Roboclaw has far more capability, works great, and with the Pololu sale was about the same price as an Arduino Uno board. I had already researched and figured out the math to implement a PID controller, but it saved me a lot of time (i.e. nights & weekends) not having to code and debug one of those.

Some pages that helped me understand PID Controllers:

* [Wikipedia: PID Controller](https://en.wikipedia.org/wiki/PID_controller)
* [Good intro to PID controllers by Andrew Kramer](http://andrewjkramer.net/pid-motor-control/)

### Integrating the Drive Base into ROS

After getting the Roboclaw working with the drive motors, I started looking for an existing ROS node to drive the Roboclaw from a Raspberry PI 3 (the grey box pictured on the top shelf above). After searching through the ROS projects I could find that worked with the Roboclaw, I decided to create my own.

[https://github.com/sheaffej/roboclaw_driver](https://github.com/sheaffej/roboclaw_driver)

Once I could control the Roboclaw as a ROS node, I created a basic ROS node fr the base (`base_node`), and a joystick teleoperation node (`teleop_node`) to manually drive the robot around. 

The `teleop_node` was very straight forward. 

However the `base_node` required me to learn about robot kinematics, some linear algebra, and refresh my memory of trigonometry.

### Leaning Kinematics, Linear Algebra, and Odometry

Below are some pages that really helped me understand kinematics, linear algebra, and odometry calculations. I read through many dozens of pages on the web, and the ones listed below were those that really stood out for me, and that I referred back to many times as my knowlege grew.

This paper below by Columbia University helped me understand the fundamental math of Forward and Inverse Kinematics. This introduced me to several terms that I would need to use, but the math here was too far removed from my specific scenario. So I ended up using different equations which are mentioned further below.

* [http://www8.cs.umu.se/kurser/5DV122/HT13/material/Hellstrom-ForwardKinematics.pdf](http://www.cs.columbia.edu/~allen/F17/NOTES/icckinematics.pdf)

These videos below helped me understand how the equations for control and odometry were derived. I ended up using different equations (see Christoph Rösmann's answer below), but seeing how the equations were derived and work together helped me visualize the concepts behind the equations, which allowed me to understand the other variants of equations I found on the web:

* [(YouTube) Georgia Tech: Control of Mobile Robots- 2.2 Differential Drive Robots](https://youtu.be/aE7RQNhwnPQ)
* [(YouTube) Georgia Tech: Control of Mobile Robots- 2.3 Odometry](https://youtu.be/XbXhA4k7Ur8)


I found this page filled in a lot of gaps for me, specifically related to why the ROS calculations looked different from the kinematic calculations used in non-ROS applications. Specifically, it's typical in ROS to use unicycle model where the robot moves straight, or rotates around the center, but not both at the same time (i.e. arc calculations). Because of this, the angular velocity in ROS is typically around the center of the robot, and not the ICC of the arc traveled.

* [http://robotsforroboticists.com/drive-kinematics/](http://robotsforroboticists.com/drive-kinematics/)

Ultimately, to understand how to calculate odometry I needed to learn some linear algebra. Having a real-world problem to solve when learning math concepts makes a HUGE difference. Having my odometry problem to solve, and these really great videos below, I was able to learn what I needed about linear algebra pretty quickly. I only needed to watch up to video #6 which deals with 3D transformations.

* [YouTube playlist: Essence of linear algebra](https://www.youtube.com/playlist?list=PLZHQObOWTQDPD3MizzM2xVFitgF8hE_ab)

In the end, the equations I used to calculate odometry have the linear algebra "baked in", so my implementation didn't need to perform the math myself. However having studied the concepts, I felt confident that I understood what the equations and libraries were doing. It also made it much easier to catch a few bugs in my initial implementation since I could actually understand things like what a Quarternion vs. Euler was, and why/how you need to convert between them.

This answer below by Christoph Rösmann ultimately was the template I used for my odometry calculations. I came across this page early on during my research, and it made very little sense to me at that time. But then after studying the other topics above, when I stumbled on this page again this answer really pulled it all together for me.

* [https://answers.ros.org/question/231942/computing-odometry-from-two-velocities/](https://answers.ros.org/question/231942/computing-odometry-from-two-velocities/)

**Next:** [Teleoperation to Obstacle Sensing](/b2/Teleoperation-to-Obstacle-Sensing)