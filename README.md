# Video Exam project

This app consists of a single screen running an AVPlayer instance.

Device motion controls video playback:
- Shaking the device plays/pauses playback
- Pitch (x-axis) controls playback volume
- Yaw (z-axis) is used for rewinding/fast-forwarding (only when playing)
- GPS is used to reset playback whenever device moves 10 meters away from last point

Volume, playback seeking and location controls work in background mode.

Notable quirks:
- Gyroscope experiences a gimbal lock when laid flat on it's back. This is remediated internally by switching to magnetometer, but isn't reliable due to magnetometer calibration issues.
- While GPS location tracking relies on `distanceFilter` leading to decreaced precision, it should be precise enough for given application.
- GPS locations are filtered by `horizontalAccuracy` (defined in `LocationService`). Accuracy threshhold is set to 100 meters to simplify testing indoors. Lesser value should be used to get more accurate results.