# Tuning Cartographer
_April 2020_

Tuning is ongoing and although I'm getting maps, they are not quite usable yet. I'm stil learning how to tune Google Cartographer for the B2 robot platform.

I believe I have local SLAM working pretty well. When I use the Cartographer Rviz plugin by launching Rviz from my [`b2-slam`](https://github.com/sheaffej/b2-slam) package using [rviz.launch](https://github.com/sheaffej/b2-slam/blob/dev/b2_slam/launch/rviz.launch), I can inspect each submap created.

Each submap on its own looks good. But the submaps are not aligning correctly with each other when Global SLAM is disabled. This is causing rooms to have the double-wall effect where the walls are misaligned in the resulting occupancy grid map.

Then when I turn on Global SLAM, the submaps are squeezed together toward the center of the map, little by little, each time that Global SLAM executes in the background. That really messes up the map.

So I believe I have submap creation working well. But need to tune how the maps are constrained together both in Local SLAM, and in Global SLAM.

More to come.