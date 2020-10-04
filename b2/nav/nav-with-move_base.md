# Navigation with move_base

_September 2020_

With a usable map (finally!!!) I could move on to autonomous navigation. By autonomous, I mean that the robot would decide on its own movement commands based on a starting pose and a goal pose.

Fortunately, ROS's nav stack does exactly this. So I don't need to write code, but rather just need to assemble and configure the relevant nav stack nodes to work with my map created by [`b2-nav/b2_slam_toolbox`](https://github.com/sheaffej/b2-nav/tree/4cc5fcce4ba82638980a72289eb2fec5f8b66ca7/b2_slam_toolbox) and [`b2-base`](https://github.com/sheaffej/b2-base/tree/d73742c875dc6695bea2f4b1395d6d96028cb541).

By following the ROS nav tutorial [_Setup and Configuration of the Navigation Stack on a Robot_](http://wiki.ros.org/navigation/Tutorials/RobotSetup), I was able to get B2 moving around my downstairs floor by specifying a goal pose in rviz. It was pretty straight forward and within a few hours, mostly reading about the packages [move_base](http://wiki.ros.org/move_base), [amcl](http://wiki.ros.org/amcl), and [costmap_2d](http://wiki.ros.org/costmap_2d), to my surprise it worked the first time I ran an on-robot test!

It is not perfect, and I still have some tuning to do. When the floor is clear, B2 can move to the goal pose with no problems at all. But when navigating through the more narrow parts, it thinks it is stuck even when there is over a foot of clearance with the nearest object. I believe there are a few things I need to adjust:

* The inflation around obstacles is probably too high. When B2 is over a foot away from an obstacle, it still tries to go around it.
* The localization seems to drift while navigating. Ironically, it doesn't seem to drift when not navigating (i.e. when I joystick it around the downstairs). This has the effect of creating more obstacles since both the obstacles known in the map, and obstacles seen by the laser scanner are considered obstacles when navigating. When the localization drifts (e.g. rotates 20°) then the same obstacle (from map and from scanner) appears in two different places causing more obstacles the planner needs to avoid.
* I need to review my `b2-base` implementation because I believe I took a shortcut and allowed only forward/reverse movement, or rotation movement. But I believe I prevented a combination of the two to make calculating the motor commands easier. However I believe `move_base` local planner will issue combined movements in the Twist messages sent to the `/cmd_vel` topic. When B2 is navigating, you can see how it switches dramatically from forward/reverse to rotation, and back, as if the local planner is fighting with the base.

I'll share more as I make progress tuning the nav stack.

_October 2020_

Spending more time with the nav stack I realized that the main problem I was having was sub-optimal localization with `amcl`. I spent some time adjusting the amcl parameters, including moving to the `diff-corrected` odometry model of `amcl` instead of the legacy `diff` odometry model that appears in most of the tutorials. This helped a lot.

I also tried helping the localization by improving the odometry accuracy through fusing the `/base_node`'s odometry with IMU data using the `robot_localization` package. However after a lot of experimentation, I realized that the odometry from the `/base_node`'s wheel encoders alone was good enough combined with the newer `diff-corrected` odometry model of `amcl`.

I found that the most important characteristic of the odometry is that it is smooth and consistent. It can drift, a huge amount as time goes on, but that's OK since `amcl`'s localization is publishting the `/map` --> `/odom` transform that corrects that drift. When I used `ekf_robot_localization`, the odometry had roughly the same drift (i.e. adding the IMU didn't really make the odometry drift less) but it became more jumpy with the IMU data. That made the `amcl` localization actually less effective.

So in the end, I stayed with the odometry published by B2's `/base_node` and tuned `amcl`'s odometry model to match the characteristics of the robot's movement. BTW, finding these `odom_alphaX` parameters was completely trial-and-error. I had to try various different values using a recorded bag file of sensor inputs from joysticking the robot around my downstairs floor. 

After tuning the localization, all I had to do was decrease the `inflation_radius` of the `move_base` costmaps, and B2 was navigating around my downstairs floor with ease, and avoiding both static and dynamic obstacles (e.g. the cat)

Below is a video of B2 navigating my downstairs as viewed from Rviz. Part of the misalignment of the laser scanner and the map seen in the video I believe is Rviz's lag in rendering between the different TF frames. Because if I set the Fixed Frame in Rviz to be `/odom` the scans stay much more aligned with the map. But you can also see that the costmaps do get rotated from time to time, and B2 has to pause and wait for `amcl` to re-align to the map, thus clearing obstacles induced by localization rotational skew.

(Click picture below to view in YouTube)

[![B2 Robot - ROS Navigatino (Oct 2020)](https://img.youtube.com/vi/4bG1stli68M/0.jpg)](https://www.youtube.com/embed/4bG1stli68M)

**Next:** [Wrapping up the B2 project](/b2/nav/wrapping-up) 