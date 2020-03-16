# I finally came to my RealSense(s)

_January 2020_

Or rather, RealSense came to me. I'm referring to [Intel's RealSense](https://www.intelrealsense.com/stereo-depth/) 3D depth cameras.

A friend and co-worker [Michael Butler](https://github.com/mtbutler93) obtained an [Intel RealSense D435](https://www.intelrealsense.com/depth-camera-d435/) and gave it to me for my robotics project - thanks again Michael!

This is a game-changer for my B2 robot. 

![](/b2/images/4wd-base/d435_realsense_300px.jpg)

I had been considering the [RPLIDAR A1](http://www.slamtec.com/en/lidar/a1) 360° laser-scanner to perform mapping and localization, and then also a webcam for image recognition to detect when the robot has found the person it was seeking. But the RealSense D435 has both 3D depth sensing, and an RGB camera, therefore I can accomplish both with the same sensor unit.

## NUC, you're out...Raspberry Pi 4, you're in
At the same time, I was trying to buy an Intel NUC computer as the onboard computer for B2. Both the RPLIDAR A1 laser scanner and the Intel RealSense cameras need USB 3.0, but my current Raspberry Pi 3 only has USB2.0.

However, shortages of NUCs on the market caused by the 2019 trade war between the US and China were driving the prices really high. I wanted the [NUC8i5BEK](https://www.intel.com/content/www/us/en/products/boards-kits/nuc/kits/nuc8i5bek.html) which still needs RAM and M.2 storage. That kit was selling for the inflated price $549.00, and that's before adding RAM and storage.

Eventually, I decided on the new Raspberry Pi 4 Model B. It has USB 3.0 and much better USB and networking performance due to the dedicated USB and Gigabit Ethernet controllers that are now conncted directly to the PCIe bus. And it was only $61.99 for the larger 4GB RAM model.

**Raspberry Pi 4 Model B**
![](/b2/images/4wd-base/rpi4.png)

With the NUC, I was planning to run all processing on the robot. But now I'll have to run the vision and possibily nav nodes on a remote computer. The Pi 4 will just need to run the base nodes, and enough of the RealSense function to send ROS messages to the rest of the stack on a different computer.

## My `ros-realsense` node
It took some work to get the D435 RealSense camera working on the Raspberry Pi 4. This isn't officially supported yet, so I needed to fuse together steps from multiple documents and forums I found in the Internet. 

After a lot of trial and error (__emphasis on a lot__), I eventually succeeded in creating a Docker image that runs the Intel [`realsense-ros`](https://github.com/IntelRealSense/realsense-ros) node on the Raspberry Pi 4, with Raspbian as the host OS.

Originally I tried runing Ubuntu 19.10 server on the Pi since there were RealSense docs on how to run the libraries on Ubuntu. But ultimately, I hit a kernel incompatibility that resulted in periodic instability of the Pi when running the RealSense camera. This led me back to the official Raspbian OS, running a Docker container of Ubuntu 18.04 LTS. 

To see what I did to get it all working, just check out the [Dockerfile](https://github.com/sheaffej/ros-realsense/blob/master/Dockerfile) in my [`ros-realsense`](https://github.com/sheaffej/ros-realsense) repo.

For SLAM, I was planning to use the A1 laser scanner that publishes a `sensor_msgs/LaserScan` topic. But the RealSense publishes a depth image as a `sensor_msgs/Image` topic. Fortunately, ROS provides a [`depthimage_to_laserscan`](http://wiki.ros.org/depthimage_to_laserscan) package that can produce a laser scan from the depth image. My ros-realsense package builds upon [Intel's `realsense-ros`](https://github.com/IntelRealSense/realsense-ros) package that uses nodelets to make processing and filtering of the camera data more efficient. And `depthimage_to_laserscan` can be run as a nodelet, so that keeps the conversion on-robot and avoids sending images across the network.

You can check out my `ros-realsense` GitHub repo here:
* [sheaffej/ros-realsense](https://github.com/sheaffej/ros-realsense)

**Next:** [SLAM with Google Cartographer](/b2/slam/slam-with-cartographer)