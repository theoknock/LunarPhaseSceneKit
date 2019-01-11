# LunarPhase

Displays the current lunar phase using a SceneKit SCNSphere (3D, rotatable) with a complete stereographic projection (mercator) of the Moon applied as SCNMaterial. The shadow is positioned by rotating an SCNCamera on its Y-axis by the normalized degree value (0° to 360°) returned by the LunarPhase class (a float, ranging from 0.0 to 1.0); it is updated every minute.

### To-Do

	1.	Replace the shadow, which is cast by an SCNLight (SCNLightTypeSpot), with a shadow cast by a second SCNSphere geometry (to simulate Earth’s shadow on the moon’s surface cast by the sun).
	2.	Change the size, color and relative brightness of the moon to distinguish between the New and Full Moon.
	3.	Orient the image of the moon to match the visible surface as seen from Earth.

## Setup Instructions

To include it in your app, import the LunarPhaseSceneKitView SCNView subclass and the LunarPhase class into your project.

## Requirements

### Build

Xcode 10.1

### Runtime

iOS 12.1

Copyright (C) 2019 James Alan Bush. All rights reserved.
