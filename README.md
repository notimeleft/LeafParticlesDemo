# leaf particles! 

Run Instructions: Download project, open 'leafParticlesDemo.xcodeproj' in xcode 10.1 or above. Run on a device or simulater with iOS 12.0 or above.  

This mini project simulates a box in which 500 leaf sprites are generated. 


![Leaf gif](https://thumbs.gfycat.com/MenacingDelectableDromedary-size_restricted.gif)


Shake the device, or touch the 'gravity' button, to enable gravity. 

Rotate the screen to change the direction of gravity.  

Draw on the screen to create a 'wind' force which affects nearby leaves. 

Reset the scene by touching the 'new' button


The leaves are modeled as Spritekit sprite nodes with circular physics bodies. The leaves are affected by the overall gravity of Spritekit's physics world and the momentary 'wind' effect created by user touch events. 

There are 150 'real' leaves with physics bodies attached that collide with one another

And there are 350 'dummy' leaves that only collide with the floor of the physics world. 

500 total leaves in all, they are all affected by the 'wind' force which your finger swipes will impart. The 'wind' force will be applied to all leaves that are around 40 pts in proximity to your touch point. 




