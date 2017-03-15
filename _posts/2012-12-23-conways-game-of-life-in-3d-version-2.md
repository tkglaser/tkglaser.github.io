---
layout: post
title:  "Conway's Game Of Life in 3D (version 2)"
date:   2012-12-23
permalink: /conways-game-of-life-in-3d-version-2/
---
Following up on my [previous post](http://www.tkglaser.net/2012/12/conways-game-of-life-in-3d-using-html-5.html), 
I've had another play with [three.js](http://mrdoob.github.com/three.js/), 
trying to push it a little more. I've allowed the organism to grow into a 3D grid, added some random cube colours, lighting and shadows:

![Conway3Dv2](/assets/images/Conway3Dv2.png)
<!--more-->
You can:
- [Run the demo](http://playground.tkglaser.net/Conway3D2)
- [View the complete source](https://raw.github.com/tkglaser/demos/master/net.tkglaser.demos/net.tkglaser.demos/Views/Conway3D2/WebGL.cshtml)

### Take Conway to the 3rd dimension
First, I wanted to allow the Conway organism to grow into the 3rd dimension. There are many suggested rule sets for this throughout the internet. But in order to see a continuously growing organism, I left the 2D rules unchanged. The grid has been extended to 20x20x20.
### Advanced lighting and shading
In order to add some more interesting lighting, I've added some spotlights:
```javascript
light = new THREE.SpotLight(0xff170f, 1);
light.position.set(0, 500, 2000);
light.castShadow = true;

light2 = new THREE.SpotLight(0xffcf0f, 1);
light2.position.set(0, -400, -1800);
light2.castShadow = true;
```
A spotlight is a point-light that can cast a shadow. I've also enabled shadows in the renderer:
```javascript
renderer = new THREE.WebGLRenderer({ antialias: true });
renderer.sortObjects = true;
renderer.setSize(window.innerWidth, window.innerHeight);

renderer.shadowCameraFov = camera.fov;
renderer.shadowMapBias = 0.0039;
renderer.shadowMapDarkness = 0.5;
renderer.shadowMapWidth = renderer.shadowMapHeight = 2048;

renderer.shadowMapEnabled = true;
renderer.shadowMapSoft = true;
```
### Done
That's it, feel free to have a look at [the demo](http://playground.tkglaser.net/Conway3D2) 
or read [the code](https://raw.github.com/tkglaser/demos/master/net.tkglaser.demos/net.tkglaser.demos/Views/Conway3D2/WebGL.cshtml). 
This demo will only work in WebGL browsers as I couldn't get the lighting to run in a HTML 5 canvas.

By the way there is another example of this on [chromeexperiments.com](http://www.chromeexperiments.com/detail/conways-game-of-life-in-3d).
