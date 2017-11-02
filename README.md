# 6dof-vr

Inspired by https://github.com/FusedVR/GearVR-Positional-Tracking which uses ARCore to bring positional tracking to GearVR.

- Dual `SCNView` as viewports
- `ARKit`-based position tracking
- `CoreMotion`-based orientation tracking using quaternions to avoid gimbal lock
- Barrel distortion implemented using `GLSL` / `HLSL` fragment shader (the GLSL one is a bit broken if i remember correctly)

Since at some point this turned out to be an experimental repository for me to gain knowledge about the SceneKit and Metal APIs I disabled positional tracking during some refactoring session. It can be added back easily - I believe there should be some commented out code there to turn it on in `MotionService`. 

It's much more unstable than I initially thought. Once there aren't enough feature points detected or something else happens, the view just drifts away breaking the illusion, so I guess it's just unusable for the time being in some "real" app. 

On top of that, there are no headsets available that won't obstruct your iPhone's cameras, like the GearVR for Samsung phones - I just used a soldering gun to make a hole for the cameras in some cheap generic headset.
