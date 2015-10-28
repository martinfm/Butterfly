# Butterfly
An audio visualizer for SuperCollider synths inspired by the butterfly effect.

Click on the image or [here](https://vimeo.com/140440037) to see an audio-visual performance using Butterfly.

[![Butterfly at Gen.AV](https://i.vimeocdn.com/video/536834793_640.webp)](https://vimeo.com/140440037)


### Introduction

Thanks to the computational power of modern digital audio, a massive number of sound unit generators added together - with noisy intentions - 
can all be modulated in a way that is different for each generator, but at the same time controlled by the same one dimensional parameter on the user interface. 
Sometimes it happens that the sonic output of such synths be meaningful ( to some extent, again it helps a lot to be after noisy outputs  )  
despite being the result of the sum of apparently chaotic behaviors (in fact it's the complexity given by the computation that gives it the
appearance of being chaotic). Even more surprisingly, sometimes a change on the user interface parameter results 
in an overall change in the sonic output that is distinct and recognizable and responds to the user gesture in a meaningful way. 


This sort of "order emerging out of chaos" is what inspires Butterfly, a sonic visualizer built with the aim to try and reproduce this behavior in the visual domain. 
To have a number of simple graphical elements, each modulated differently in their appearance by a unit generator, and see if some complex visual pattern would emerge. 

The result is a sort of general purpose scope viewer that can be mapped arbitrarily to any internal bits of SuperCollider synths to see if something magic happens!
It is intended as a interactive instrument that can be manipulated in real time for generative audio visuals performances. The visual tool can be used with any 
SuperCollider synth definitions, even your own as long as they fulfill some requirements (see below for more details).

Butterfly is made 100% in SuperCollider for SuperColliderists, it was developed during the second [Gen.AV Hackathon](http://www.gen-av.org) on generative audiovisual tools. 


### Installation
In order to run Butterfly you need to install [SuperCollider](http://supercollider.github.io). 
To launch Butterfly execute first the code in ButterflySynths.scd and ButterflySynths2.scd. 
This will load the synths into the SuperCollider server. Then execute Butterfly.scd

You can execute a SuperCollider script by opening it in the ScuperCollider IDE, which is included in the SuperCollider
installation package, and press ctrl+Enter after placing the cursor anywhere in the script after the initial parentheses. 


### Run Butterfly
Right-click on one of the four butterflies to activate it. This will start a synth and the related visuals.
You can move the butterfly to manipulate two parameters linked to its x and y position, just left-click on it and 
drag it around. Each butterfly can only be dragged within its area. 
The screen is automatically divided into four uniform areas: top-left, top-right, bottom-left and bottom-right.

Right-clicking on an active butterfly will deactivate it and stop the sound and visual associated to it.


### Use Butterfly with your own synths
If you happen to know the SuperCollider language, the Butterfly interface can work with any Supercollider synth out of the box-ish,
as long as they follow some conventions in the naming and they properly send trigger messages back to the SuperCollider client.

In order to use your own synth you must:

1. Name your SynthDef one of the following: 'butterfly_0', 'butterfly_1', 'butterfly_2'  'butterfly_3'. This will assign it to 
one of the areas of the visuals, respectively top-left, top-right, bottom-left and bottom-right;

2. Name the two arguments of your SynthDef that you want to control from the interface respectively 'x' and 'y'. Your synth will
receive values ranging from 0 to 1 for both parameters, as you move the butterfly from the bottom-left to the top-right of the screen;

3. Send back one trigger to the SuperCollider client for each UGen in your synth that you want to map to visuals. This is how you do it in code: 
`SendTrig.kr(Impulse.kr(60), id, yourUgen.range(-1,1));`
Note that the default trigger rate is 60, but you can try and experiment with different values and see what happens. _id_ 
is the id that you assign to your UGen and that will be map to a sprite in the visualization. The id goes from 0 to the number of UGens you want to 
visualize - 1. It's important that this number be matched to the number you enter in the Butterfly configuration lines (see point 4 for details). 
Also note that the range of the values you send to the client should be [-1,1]. 

 A plausible example of sending the trigger is using the _Mix_  UGen as in this example:
 ```
 Mix.fill(10, { arg i; 
    var sinOut = SinOsc.ar( freq:40 * i, mul: 1/10 );
    SendTrig.kr(Impulse.kr(60), i, sinOut); // sinOus already ranges between -1 and 1
    sinOut; // last instruction is to return sinOut to the Mix
 });

 ```
4. Change the configuration lines at the beginning of the Butterfly.scd scripts. In particular you must specify for each area (or butterfly if you like)
 the number of different triggers your synth is going to be sending. This number must match your synth behavior 
 for the visualization to work properly. For the example above this would be 10. You can set this value by changing the variable _kUGENS_PER_SYNTH_, 
 which is actually an array as you must set a specific value for each of the four synths.

 Other variables that you can optionally set are: 
  * _kBUTTERFLY_COLORS_: changes the butterfly color, also an array: one value for each butterfly;
  * _kFULL_SCREEN_: whether to enable full screen mode;

