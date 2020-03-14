# B2 - Hide & Seek Robot
[![Build Status](https://travis-ci.org/sheaffej/b2.svg?branch=master)](https://travis-ci.org/sheaffej/b2) [![Coverage Status](https://coveralls.io/repos/github/sheaffej/b2/badge.svg?branch=HEAD)](https://coveralls.io/github/sheaffej/b2?branch=HEAD)

This is my ROS project consisting of the custom code for my robot named **B2**.

### What is B2, and Why?
B2 is a 2-wheel differential drive robot. Its initial design goal is to create a hide & seek robot that will roam a single floor in a multi-room house looking for a person who is hiding. This goal was suggested by my elementary school-age kids when I was searching for a goal for which to build a robot from scratch.

My daughter picked the name **B2**. Prior to this robot, we build a light-follower robot partially following [a design](http://www.robotoid.com/my-first-robot/rbb-bot-phase2-part1.html) from the author of [Robot Builder's Bonanza](http://amzn.to/2vk4dpO). That first robot she named Beddo, from a [scene in Despicable Me 2](https://youtu.be/htcQ6CIKqGg?t=1m6s). Therefore she wanted this robot to be named **B2**.

This wiki will document my journey of designing, building, and modifying B2, as well as generally learning about robotics through this platform.

# The Initial Design

First, I modeled the robot in Fusion 360. Doing so allowed me to quickly think through and experiment with many of the physical design ideas I had in my mind. It also allowed me to build a list of parts I would need. Many of the parts I was considering had existing CAD models that I could import into Fusion 360 such as the motors, wheels, and IR sensors, etc. The design changed many times as I worked on the model. For example, at first I forgot to include a battery. When I added a 7.2v R/C battery to the model, I realized I needed a 2nd level to have more room to place some of the components.

|![](https://github.com/sheaffej/b2/blob/master/docs/images/b2_design_v1.png)|
|:---:|
|Initial Fusion 360 design|

**Next:** [Building the Drive Base](https://github.com/sheaffej/b2/wiki/Building-the-Drive-Base)