# Initial Autonomous Driving
_13 Aug 2018_

Today I ran the first real test of B2 driving autonomously using the new `pilot_node` and the initial obstacle avoidance planner. Until now, all of my testing of the `pilot_node` code had been using unit and node-level integration tests and ROS tools (Topic Monitor, Pose Viewer, tf_echo, etc) to make sure all of the "autonomous" version nodes were working properly. And the last real world test on the B2 robot was a teleoperation test where I was controlling B2 using a joystick and my laptop.

I was very pleased with the initial results! Below is the video of the initial autonomous test.

(Click picture below to view in YouTube)

[![B2's initial autonomous driving video](https://img.youtube.com/vi/EFLEaKHsunI/0.jpg)](https://www.youtube.com/watch?v=EFLEaKHsunI)

This test used the code as of commit: [e944f0a](https://github.com/sheaffej/b2/tree/e944f0a4f20038805e9b6f8c4cdf259ed273e4da)

The `pilot_node` uses a fairly simple, initial obstacle avoidance planner that follows this algorithm:

![One Sensor Obstacle Navigation](/b2/images/2wd-base/Obstacle_Navigation-One_Sensor_Flow.png)

As this was the initial robot test, there are clearly lots of things that need improvement. 

For example:
* The turning rate is too slow
  * And it seems the motors are not getting enough voltage from the low QPPS to move B2 when it gets alongside a wall in a corner
* Sometimes B2 stops far from an obstacle, and sometimes it hits the obstacle just before stopping
  * But I'm pleased that it doesn't continue to try to drive when up against the obstacle
  * I suspect there is a timing delay between when the `ir_sensors` node detects the obstacle, to when the `pilot` node sends commands to the `base` node, and then to the `roboclaw_driver` node
  * Maybe need to increase the loop_hz in the nodes
* B2 is not driving very straight, which will really throw off its odometry
  * I may need to spend some more time calibrating the Roboclaw PID controller so that a specific QPPS results in the right motor speed

### Update: 19 Aug 2018

After simply tuning some of the ROS node parameters in the launch file, B2 is driving a lot better! 

As I let B2 drive around the kitchen (without the cat this time) and monitoring the topics for the IR sensors, cmd_vel Twist, and Roboclaw SpeedCommand messages, I noticed a few things:
* The QPPS rates to the Roboclaw during a turn were really low.
  * This explained why B2 was turning so slowly
  * But the QPPS rates to the Roboclaw when driving straight were at the max of 3700 QPPS
  * **Solution:** I increased the `max_turn_speed` parameter to 1 pi/sec (from 0.25 pi/sec)
* The IR sensors were sluggish in reporting obstacles
  * Which is why B2 in the first test would sometimes stop just as it lightly impacted the wall
    * Keep in mind, B2 has no impact sensors. So this told me that the IR sensors were detecting the wall, but too slowly.
  * **Solution:** I realized I had left the `pub_hz` parameter (aka the hz of the main loop) of the ir_sensors node at testing/debugging rate of 1 hz. Increased this to 10 hz and voila! The walls were being detected in a very responsive manner.
* I also noticed that the roboclaw_node was consuming quite a lot of CPU
  * It was using around 40% CPU on the Raspberry Pi3, where other nodes were only using less than 10%
  * This didn't seem right, since the roboclaw nodes is really just an interface for the SPI2 serial comm to the Roboclaw controller
  * I found the loop_hz parameter at 100, which doesn't need to be that high. The other nodes are looping at 10 hz, so no reason to have the roboclaw node looping 10 times for each time the other nodes loop
  * **Solution:** Changed the roboclaw_node's `loop_hz` parameter to 10 (from 100)
* Lastly, B2 was not driving straight. During a straight drive mode, it would consistently turn to the right
  * After watching the SpeedCommand message sent to the roboclaw_node (which was commanding 3700 QPPS to each motor), and the Stats message from the roboclaw_node showing what the motors are actually doing in terms of QPPS, I realized my flaw
    * I was commanding the motors to run at 3700 QPPS which is the max motor speed when they are run at 100% on the bench (that is, their max _unloaded_ speed)
    * But when you put any load on the motors, they cannot continue to turn at 3700 QPPS anymore. And each motor will run at a slightly different max loaded speed, which is why it turns. The right motor runs slightly slower than the left when loaded and commanded at 100% speed.
    * The effect of this is the Roboclaw controller wasn't actually controlling the speed. It just kept telling the motors to go as fast as they can since they were not yet at the 3700 QPPS target speed.
  * **Solution:** Set the base_node's `max_qpps` lower to a QPPS that the motors can easily achieve when loaded.
    * By watching the Stats topic with rostopic, I could see the motors would run between 3300 and 3600 QPPS when driving straight
    * So I set the `max_qpps` to 3000. That way the motors should easily be able to reach that speed, at which point the Roboclaw's PID controller would start actually regulating the speed and keep each motor running at roughly the same QPPS.
    * After this change, B2 is definitely driving in a much straighter line. However, there is still a little turn during long straight drives. I am thinking that there may be some small differences in the wheels which could be causing this
    * The real solution for this would be to have some form of localization that would tell B2 how it is actually moving and oriented (compared to just what the roboclaw_node reports). Then the base could calculate correction vectors to turn B2 back on a perfectly straight course. But that's a problem I'll need to defer on right now.

Here is the commit with the parameter changes to the launch file:
https://github.com/sheaffej/b2/commit/67234b842a3280dd32a838978d76fae568c4c22b

And here is B2 navigating the kitchen after the parameter changes. Much better!!!

[![B2 follow-on kitchen test (19 Aug 2018)](https://img.youtube.com/vi/rDFhwQ56HUw/0.jpg)](https://www.youtube.com/watch?v=rDFhwQ56HUw)

**Next:** [Rethinking the Design](/b2/4wd-base/rethinking-the-design.md)