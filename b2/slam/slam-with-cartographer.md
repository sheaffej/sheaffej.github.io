# SLAM with Google Cartographer
_February 2020_

There were a lot of sites that show how to set up SLAM in ROS using [gmapping](http://wiki.ros.org/gmapping). However from what I found and read, people were suggesting that gmapping was outdated, specifically when it comes to loop closure.

I heard about Google Cartographer on the ROS Developer's Podcast [#56 The ROS SLAM Toolbox by Steve Macenski](https://www.theconstructsim.com/the-ros-slam-toolbox-by-steve-macenski/). And then doing some more research, it seemed like a more robust SLAM system that was fairly well documented.

Here is the [docs site](https://google-cartographer-ros.readthedocs.io/en/latest/) for Google Cartographer and ROS. Fortunately, the ROS docs seem to be the most complete of the Cartographer docs.

## Learning Cartographer
A quick read on the Cartographer ROS doc site and you can quickly get a [demo up and running using one of their sample ROS bags](https://google-cartographer-ros.readthedocs.io/en/latest/demos.html).

But those docs don't really explain the concepts very well. What is a submap? A trajectory? A node, and a constraint?

Reading through the [original paper](https://research.google.com/pubs/pub45466.html) by Google helps fill in some more of the gaps, but it's mostly the math behind the algorithms.

It wasn't until I started trying to get a decent map that I really understood the concepts. I'll summarize the main concepts that I learned in the section below. Then on the next page I'll discuss what I did and learned about tuning Cartographer so it builds a good map.

## My Cartographer Primer
The docs are clear to point out that Cartographer has two main parts:
* Local SLAM
* Global SLAM

What it doesn't explain clearly is that Local SLAM's job is to create small pieces of the map (called submaps), and connect neighboring submaps together as it draws the map. The connection of neighboring submaps is called the Trajectory. Then Global SLAM periodically optimizes the submap arrangement to find where submaps overlap (i.e. cover the same part of the map) and connects them - this is alled loop closure. 

You can think of the submaps as pieces of a paper map laid out on a table top, and then "glued" together. The glue in Cartographer is called the Constraints which describe how one submap is positined and glued to another submap. All these submaps glued together make the map.

Here is a good diagram I found in the paper _[Multi-Robot 6D Graph SLAM Connecting Decoupled Local Reference Filters](https://elib.dlr.de/100757/1/multirobot_slam_v2.4_href_header.pdf)_.

![](/b2/images/slam/submaps-loop-closure.png)

Submaps created by Local SLAM are said to be "locally consistent". What that means is the if you took a submap (think of a submap as a piece of paper on the table) and looked at the walls and obstacles in that submap, everything should be the right distance and in the right position compared to everything else on that submap. 

To really understand this, let's look at what the opposite would be - perhaps called globally inconsistent?

As you can imagine, when mapping a very large area, drifts in odometry and sensors would make the walls not so straight as your robot moved from one end of the map to the other. You could have a long straight building that ends up looking like a curved banana.

Or like this:

![](/b2/images/slam/no-global-slam.png)

That's the downstairs floor of my house. But I can assure you my house is not that crooked.

What we a looking at in that picture above is a bunch of submaps overlayed (or glued) together. 

But if we look at a specific room in the map:

![](/b2/images/slam/slam-locally-consistent.png)

...it looks pretty straight. This room is small enough that the laser scanner can map the walls without the robot moving much, therefore the drift is very little. We would say this room is "locally consistent", and it could be a submap.

But in reality, this small piece of the map is actually many submaps. And that is because a submap is not a piece of the map, but a set of laser scans that are combined to form a submap. So a submap may be just one corner of this room. And if I parked the robot in this room with the laser scanner generating scans, even the same corner could be a bunch of submaps since each submap is a set number of scans.

Therefore a submap is a small piece of the map puzzle, and is small enough that drift should not be causing distortion of the distances and positions of objects in that submap.

Let's zoom out a bit on our map.

![](/b2/images/slam/bad-local-slam.png)

We can see here that as the robot moved around, its position drifted. And the laser scan mapping drew walls in newer submaps in different positions than previous submaps. This is a problem with Local SLAM that needs to be fixed by tuning Cartographer.

We'll see in the tuning section that generating good submaps during Local SLAM is the first challenge we need to address. Once we have that working well, we can move on to tunig Global SLAM. But in the map above, we still have a lot of work to do on Local SLAM.

Global SLAM then works to re-align how the submaps are glued together, specifically with regards to loop closure.

Loop closure is when the robot moves around, and then revisits a part of the map that it visited before. Global Slam identifies these overlaps, and builds constrains (i.e. glue) to fix those similar submaps together. Look back above at Fig 4. The yellow line between the two similar gray submaps is the work of Global SLAM "constraining" those two submaps together.

Now that we have a basic conceptual understand of Cartographer, we need to tun Local and Global SLAM so our map gets better than what we have above.

BTW, the map above was actually after a lot of tuning already. My first maps looked like a giant swirled hurricane. The map was so twisted and smashed together you couldn't make our any room at all.

**Next:** [Tuning Cartographer](/b2/slam/tuning-cartographer) 