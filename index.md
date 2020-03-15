# B2 Robot Project (ROS)

This is my ROS project consisting of the custom code for my robot named **B2**.

### What is B2, and Why?
B2 is a custom 4-wheel differential drive robot. Its initial design goal was to create a hide & seek robot that will roam a single floor in a multi-room house looking for a person who is hiding. This goal was suggested by my elementary school-age kids when I was searching for a goal for which to build a robot from scratch.

My daughter picked the name **B2**. Prior to this robot, we build a light-follower robot partially following [a design](http://www.robotoid.com/my-first-robot/rbb-bot-phase2-part1.html) from the author of [Robot Builder's Bonanza](http://amzn.to/2vk4dpO). That first robot she named Beddo, from a [scene in Despicable Me 2](https://youtu.be/htcQ6CIKqGg?t=1m6s). Therefore she wanted this robot to be named **B2**.

These pages document my journey of designing, building, and modifying B2, as well as generally learning about robotics through this platform.

### Read More:
1. [The Initial Design](b2/2wd-base/InitialDesign.md)
2. [Building the 2-wheel Differential Drive Base](b2/2wd-base/Building-the-Drive-Base.md)
3. [Teleoperation to Obstacle Sensing](b2/2wd-base/Teleoperation-to-Obstacle-Sensing.md)
4. [Initial Autonomous Driving](b2/2wd-base/Initial-Autonomous-Driving.md)


# Otto - Smart Home Automation
Otto is an automation engine for [Home Assistant](https://www.home-assistant.io/).

This is a general purpose automation engine that integrates with [Home Assistant](https://www.home-assistant.io/), and provides higher fidelity automation rules and flexibility than Home Assistant's built-in automation capability.

There are two projects for Otto:
* `otto-engine`
  * https://github.com/sheaffej/otto-engine
  * Python rules engine using asyncio
* `otto-ui`
  * https://github.com/sheaffej/otto-ui
  * Angular 2+ Web UI for buiding and managing rules