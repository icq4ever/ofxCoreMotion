![https://github.com/trentbrooks/ofxCoreMotion/raw/master/screenshot.png](https://github.com/trentbrooks/ofxCoreMotion/raw/master/screenshot.png)

### get openFrameworks for iOS
[download](http://openframeworks.cc/versions/v0.9.8/of_v0.9.8_ios_release.zip)
[설치가이드/installtion guide](http://openframeworks.cc/ko/setup/iphone/)

### installtion this addon
clone to `_oF_iOS_/addons`. result directory is `_oF_iOS_/addons/ofxCoreMotion`

## ofxCoreMotion ##
Openframeworks/ios addon (tested with OF 0.9.0, Xcode 7.1, ios 9.1) for the Core Motion Framework- http://developer.apple.com/library/ios/#documentation/CoreMotion/Reference/CoreMotion_Reference/_index.html

Example displays the values for attitude (quaternion & roll/pitch/yaw euler angles), gyroscope, accelerometer, & magentometer. The cube moves based on the attitude quaternion.

Can be used in replacement of ofxAccelerometer (which uses the deprecated UIAccelerometer).

## Dependencies ##
Add the 'CoreMotion.framework' to your OF xcode project.
- Under TARGETS > ofxCoreMotionExample, under the 'Build Phases' tab, where it says 'Link binary with libraries', click '+' and select the 'CoreMotion.framework'.

## Credit ##
Original DeviceMotion/attitude example by Nardove found on the Openframeworks forum: http://forum.openframeworks.cc/index.php/topic,11517.0.html - Thanks!

See example project for usage.


-Trent Brooks
