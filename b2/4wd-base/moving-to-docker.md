# Moving to Docker

![](/b2/images/Docker-Moby-logo_150px.png) ![](/b2/images/ROS_logo_150px.png)

_December 2019_

When I started the B2 project, the latest stable ROS release was [Kinetic](http://wiki.ros.org/kinetic) which was release in May 2016. Now, ROS [Melodic](http://wiki.ros.org/melodic) is available and has been GA since May 2018. Also ROS2 is appearing on the horizion, so eventually I would want to make that jump also. But ROS2 is still changing rapidly, and a lot of the ROS nodes I want to use are not yet ported over to ROS2, so I'll hold off on ROS2 for now.

The next phase of B2 will get me into using the ROS nav and perception packages. Before I delve into those, I wanted to upgrade to ROS Melodic. And since I installed ROS Kinetic natively on the Raspberry Pi, I want to uninstall Kinetic and install Melodic. I realize that I can have both installed and choose one via environment variables. But since I only get to work on this project a few hours at a time, the last thing I want to do is waste time troubleshooting the wrong ROS version. It's worth it to me to re-build the Raspberry Pi OS from scratch and install Melodic.

Then I found [ROS's Docker Hub repo](https://hub.docker.com/_/ros)! 

And I also had been testing out [VSCode's Remote Containers extension](https://code.visualstudio.com/docs/remote/containers) that allows me to develop within a Docker container. This solves another problem I had when working with ROS.

I use macOS, and ROS doesn't really run well on macOS (at least Kinetic didn't). So when developing on ROS, I ran an Ubuntu VM on my mac and then used various packages with Sublime Text to allow me to work locally on my mac but compile/test/run on the VM. It worked ... most of the time.

By encapsulating my ROS code inside of an Ubuntu/ROS Docker container, I could now code in VSCode natively on my mac and the code runs inside the Ubuntu Docker container. I also love that the Dockerfile scripts out all of the enviroment setup, so I know each time I rebuild the Docker image I get a stable and deterministic build.

## One Docker container, or many?
So should I put all of my ROS stuff in a single Docker image, and start a single Docker container as if it was a VM? Or should I start a Docker container for each ROS proecess that I launch - aka "one process per container"?

There does not seem to be consensus on this topic. There are some advantages of having a single process per container (like crash detection and container restarting), but it can also complicate dependencies between processs (for example, networking). To make things even more confusing, ROS has launch files which start many processes and nodes. You run the launch file using roslaunch which is a single process but then it spawns many processes.

Ultimately, I decided on creating one docker image per "role" in the ROS node topology. And what I define as a role is subjective to my own needs, and open for change as I evolve the robot.

For example, I will have docker images for:
* _b2-base_: The code and nodes that drive the base. These will run on the robot's onboard computer.
* _b2-dev_: The code and nodes that will run on my laptop like RViz, teleop_node, etc.
* _b2-nav_: The code and nodes that handle the navigation of the robot. This may run on the robot, or I may put it on a remote computer for better performance.


> _Update 15 Mar 2020_  
> Jumping forward in time, I have a lot of Docker images now:  
> * **`b2-base`**: Contains my `base_node`, my IR `sensors_node`, and the `roboclaw_driver` nodes. This runs on the robot.
> * **`ros-realsense`**: Contains the libraries and nodes for operating the Intel Realsense camera. This also runs on the robot.
> * **`b2-imu`**: Contains the libraries and nodes for publishing the onboard IMU sensor data. This also runs on the robot. I may fold this into the `b2-base` Docker, but for now I'm keeping is separate since it has its own set of library dependenices that need to be compiled from source. This keeps the `b2-base` and `b2-imu` images cleaner and more decoupled. 
> * **`b2-slam`**: Contains libraries and nodes for Google Cartographer for SLAM. This runs on a remote computer that has a lot more CPU processing power that what is available onboard on the robot.
> * **`b2-dev`**: Contains all of the libraries, scripts, and nodes that I use on my laptop when operating and testing the robot. This is essentially my "control plane" for the robot.
> * **`b2-rosmaster`**: This is a simple Docker container that I run on a remote node that runs the ROS master. I keep this running on the same computer all the time, and then configure all of the other containers to connect to this computer as their ROS master.

**Next:** [I finally came to my RealSense(s)](/b2/4wd-base/intel-realsense)
