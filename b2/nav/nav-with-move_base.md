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