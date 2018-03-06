# 6dof-vr

Inspired by https://github.com/FusedVR/GearVR-Positional-Tracking which uses `ARCore` to bring positional tracking to GearVR.

- Dual `SCNView` as viewports
- `ARKit` based position tracking
- `CoreMotion` based orientation tracking using quaternions to avoid gimbal lock
- Barrel distortion implemented using `GLSL` and `MLSL` fragment shader

ARKit tracking is disabled as of now, it can be uncommented in `MotionService`. It's unstable - Once there aren't enough feature points detected e.g. when you're pointing your camera at a clear white wall, the view just drifts away breaking the illusion. On top of that, there are no headsets available that won't obstruct your iPhone's cameras, like the GearVR for Samsung phones. I used a soldering gun to make a hole for the cameras in a cheap generic headset.

![Example image](https://github.com/bartlomiejn/6dof-vr/blob/master/barrel-dist.jpeg "MLSL Example image")
