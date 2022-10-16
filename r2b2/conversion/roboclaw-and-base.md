# Converting to ROS2
_Oct 2022_

## Re-using the B2 platform
The B2 robot could autonomously move around the downstairs floor when given a goal pose. I will be building upon this platform with R2B2, adding computer vision (CV) object detection to detect cat toys lying around, an arm to pick up the cat toys, and some form of controller that decides where to go and what to do. This new controller (yet to be determined exactly what it will consist of) will be setting the goal pose programmatically, instead of me manually setting the goal pose in Rviz with B2 .

But also, B2 was built when ROS1 was the mainstream ROS version, and ROS2 was still in in infancy. Now, ROS2 has gained a lot more momentum, and building new robots with ROS1 is unwise. So I will build R2B2 using ROS2. Which means I need to convert my previous ROS1 nodes into ROS2 nodes.

## ROS2 deployment differences
Having read through the documentation about migrating ROS1 nodes to ROS2, I like a lot of what I read. I use Python for my custom logic and the ROS1 Python APIs were, ... well ..., peculiar. The Python API in ROS2 is much more pythonic, although generally the `rclpy` API is still pretty inconsistent, and parts of it look as if it was written by a C++ coder and not a Python coder. But it's definitely a move in the right direction.

One big difference is ROS2's move away from the ROS master node, and relying on multicast. At first, I was VERY surprised by this change. The software industry has largely moved away from using multicast because it is problematic to support across different networks. That is, all of the network segments between clients need to support multicast, and many network administrators disable multicast for security reasons. 

My initial reaction was wondering if the ROS2 designers were out of touch with the general software/networking industry, being more focused on research projects where they can create an ideal network environment, vs. a real-world deployment environment where robots need to operate on existing networks. However as I read more, I realized that the driving motivation was to make the inter-node communications more efficient and lower latency, especially for higher data streams between nodes (i.e. images, video, point clouds, etc). With ROS1, if two nodes subscribed to the same image topic, the images would be sent twice across the network in two separate TPC socket connections. But with multicast, the publisher sends it once, it traverses the network once, and any interested nodes receive it. And what if 100 nodes subscribe to that image topic? In ROS1, that would be a significant network load, but in ROS2 with multicast, it's only one image across the network at a time.

OK...this makes sense, and I see how the performance of more complex and sophisticated robot platforms with richer and higher data rate streams need a more efficient inter-node communication protocol. And, the ROS2 designers did architect the system so that the underlying communication middleware could be swapped out. Therefore if folks needed a non-multicast way of connecting nodes, they could implement a custom middleware that works in their specific environment.

In my use case, the entire robot will exist within my home network, so I can control how multicast works. I had envisioned running some nodes on cloud VMs which would not work without Herculean networking efforts, but I can easily mitigate that by running those nodes on any one of the old laptops I have around the house (or even the new Gaming/ML PC I'm planning to build).

However, after some experimentation with the ROS2 tutorial nodes, I realized the deployment method I used with ROS1 and B2 won't work with ROS2 and R2B2. With ROS1 and B2, I ran each node in its own Docker container. This aligns with the container best practice of "one process per container". But I learned that multiple Docker containers on the same physical host can't receive multicast messages. 

Here's what I found out:
- Two nodes in separate containers on different hosts work fine with multicast
- Two nodes in the same container (on the same host of course) work fine
- But two nodes in separate containers on the same host can't communicate via multicast

It seems to be a side effect of how Docker routes network traffic through iptables (although admittedly I don't fully understand why it doesn't work). I even tried running all containers with `--network host` on the same host but the simple ROS2 publisher and subscriber nodes could not communicate with each other when in separate containers on the same host.

There has been some discussion about how this could be done, but it involved very complex customization of the Docker networking environment, which I believe at that point it negates the isolation I'm getting by using Docker in the first place. Instead, I should simply run the nodes natively on the host and forget Docker altogether.

But I do want to use Docker since it gives me a brand new and clean environment each time the container starts. It saves me a LOT of time compared to trying to figure out what change I made days or weeks ago to the host's environment which is now causing some problem with my nodes.

Therefore, my plan for R2B2 is to deploy only a single container per physical host. That means on the Intel NUC8 that runs on the robot, I'll have one consolidated container in which I launch all of my nodes. This shouldn't be a big problem, but it does mean I'll have to organize my project differently. With ROS1/B2, I had a Github repo for each node (or group of related nodes) and I would similarly launch a container for the node in that repo. But with ROS2/R2B2 I'll have one consolidated repo, for the most part.

## Converting the Roboclaw and base nodes
I've decided to keep the Roboclaw node as a separate repo since several folks have found that repo useful. I found out just how useful when I renamed the ROS1 `roboclaw_driver` repo to `roboclaw_driver_ros1 ` so that I could subsequently name the ROS2 version `roboclaw_driver`. Within a few days, a user opened an issue on the repo stating they were getting git clone errors. In hind sight, renaming a useful repo like that is a bad idea. So I promptly renamed it back, and that solved that user's issue. And I have named the ROS2 Roboclaw driver [`sheaffej/roboclaw_driver2`](https://github.com/sheaffej/roboclaw_driver2).

In ROS2, it is recommended to separate the custom message types into their own package with the `_interfaces` suffix. Therefore, I pulled out the `Speedcommand` and `Stats` messages from the main Roboclaw package and put them into their own repo named [`sheaffej/roboclaw_interfaces`](https://github.com/sheaffej/roboclaw_interfaces).

Roboclaw ROS2 repos:
- [`sheaffej/roboclaw_driver2`](https://github.com/sheaffej/roboclaw_driver2)
- [`sheaffej/roboclaw_interfaces`](https://github.com/sheaffej/roboclaw_interfaces)

I've also decided to keep the R2B2 base node in a separate repo. I think it's less likely that someone would be able to use this node as-is in their own robot, but I think it does show a decent implementation of a base node that controls wheel motors and computes odometry. So keeping it separate could be useful in the future.

R2B2 base ROS2 repo:
- [`sheaffej/r2b2-base`](https://github.com/sheaffej/r2b2-base)

As a general pattern, I think I'll create separate repos for any significant custom node or logic implementation where I have a lot of code, and unit tests. But I'll keep the "robot-level configuration" code, like robot-level package dependencies, launch files for external ROS2 nodes that I use "off the shelf", robot-wide config files, operation/deployment scripts, etc in a top-level repo [`sheaffej/r2b2`](https://github.com/sheaffej/r2b2). Which as of this writing, only contains a readme and a license file. 

I will also have a private repo [`sheaffej/r2b2-private`](https://github.com/sheaffej/r2b2-private) where I'll store any private robot-level configuration data should I have any. I don't have any at the moment, but possibly things like network IP address or ssh keys that I'd rather not commit to a public Github repo.

R2B2 robot-level ROS2 repos:
- [`sheaffej/r2b2`](https://github.com/sheaffej/r2b2)
- [`sheaffej/r2b2-private`](https://github.com/sheaffej/r2b2-private) (Private repo)

## Plan of work for conversion to ROS2
As of 15 Oct 2022, I have the Roboclaw driver and R2B2 base nodes converted over to ROS2, and both are passing their unit tests.
>Sidebar: Because of the way ROS2 works, it was easier to switch the previous ROS1 node integration tests (which used `rostest` and launch files), to a testing model where there is a single executor that we explicitly loop through the callbacks of all the nodes. This means we can run node integration tests in a regular `pytest` unit test and not have to construct tests that work with `rostest`. This appears to be a deliberate decision by the ROS2 designers, and it is so much cleaner and a welcome improvement in my opinion.

Below is the general plan of work I see going forward with this project.

_Conversion to ROS2:_
- [x] Convert `roboclaw_driver` to ROS2
- [x] Convert `base_node` to ROS2
- [ ] Find ROS2 version of `teleop` (built into RQT? Has this plugin been converted to ROS2?)
- [ ] Convert `b2-nav` to ROS2 (`SteveMacenski/slam_toolbox`)
- [ ] Convert `b2-rplidar` to ROS2 (`Slamtec/rplidar_ros`)
- [ ] Convert `ros-realsense` to ROS2 (`IntelRealSense/realsense-ros`)
- [ ] Put it all together and make it work like it did on ROS1

_Adding new features:_
- [ ] Create object detection node
- [ ] Create arm controller node
- [ ] Create node for logic of finding and handling objects
- ... not necessarily in that order

These repos I believe I don't need to convert to ROS2:
- `b2-imu` : I ended up not needing the IMU with B2 as it just added more odometry noise and didn't actually help stabilize odometry
- `b2-ekf` : This was used to fuse the IMU data for use with odometry, so again I didn't need to use this with B2 in the end
- `b2-slam` : This was a package for Google Cartographer, but I struggled with Cartographer and instead switched to using SLAM Toolbox, which I put into the `b2-nav` package

So now with `roboclaw_driver2` and `r2b2-base` done and using ROS2, I'll turn my focus on to building out the robot-level `r2b2` package/repo to pull all of the external nodes and my custom nodes together and verify it works like it did on ROS1. And hopefully better!

**Next:** _stay tuned_