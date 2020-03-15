# Rethinking the Design
_Sep 2019_

After successfully making the initial B2 drive autonomously and avoid obstacles (in a similar fashion to a Roomba robotic vacuum does) I started thinking about how to make it find a person who is hiding. 

It will need to do two new things:

1. Navigate around the room to find a person
2. Identify once it has found the person

Ideally for 1) it should visit all parts of the room in a deliberate manner, since someone will be waiting to be found. We don't want to wait while the robot randomly bumps into walls and turns. Therefore it will need to know where it is in the room, and where it can go. In robotics, we call this Localization and Mapping.

I looked at many potential ways to localize including [cheap methods of indoor localization](https://www.intorobotics.com/5-cheap-methods-for-indoor-robot-localization-ble-beacon-apriltags-wifi-subpos-nfc-and-rfid/). But after a lot of reading, I decided to pursue Simultaneous Localization and Mapping (SLAM) since that is the current trend. And although it is much more complex, I was doing this to learn about robotic after all.

In my reseach, I stumbled across the RPLIDAR A1 which was selling for $99 on Amazon. Blogs from people using the A1 with ROS recommended more CPU power than a Raspberry Pi 3. Most recommended the Intel NUC.

And for 2) I believe the robot needs to know once it has found the person, vs. the person telling the robot that he/she has been found. 

This would likely take some form of image recognition. There were some other methods I could use, like equipping the person hiding with a Bluetooth LE beacon, but again I was doing this to learn about robotics so I wanted to go the computer vision route.

Both of these new requirements meant I needed more processing power on my robot. I decided on the Intel NUC. But the NUC is much larger than my current Raspberry Pi 3, and I would need more power (i.e. batteries). That meant I needed a larger base.

With a larger base, I was not confident the 2-wheel drive and caster method would work well with my carpeted downstairs. So I decided on a 4-wheel differential drive design. 

I went to work again in Fusion 360.

![](/b2/images/4wd-base/4wd_fusion360.png)

This design has a 250mm x 200mm top layer which is large enough to accomodate both the A1 Lidar and the NUC.

Initially, I was not sure how to handle the differential drive on a 4-wheel robot. But I found several forums where people suggested treating it just like a 2-wheel robot, where the front and real wheels on a side move together like a tracked vehicle.

I looked into driving 4 wheels with the single Roboclaw 2x7a, and some people have done this. But I decided to buy a second Roboclaw and update the `base_node` to drive them simultaneously with the same `roboclaw_driver/SpeedCommand`.

To power the NUC, I needed 12v to 19v DC. For the initial B2, I was using batteries from my R/C car which were 7.2v 6-cell NiMH batteries. So I decide to just wire up two of these in series to give me 14.4v DC.

**Next:** [Moving to Docker](/b2/4wd-base/moving-to-docker)