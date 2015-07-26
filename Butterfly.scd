/*
 Butterfly - an audio visualizer for SuperCollider synths inspired by the butterfly effect

 Copyright (C) 2015 Fiore Martin
 Copyright (C) 2015 Patrick Hartono

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/


(
/*-----------------------INIT----------------------------------*/
var window, controllerView, particleView, layout, spriteFactory, sprites,
oscHandle, kNUM_UGENS = 40;

window = Window.new("Butterfly", 700@450, border:false);

/* controller view */
controllerView = View.new(window, 700@100);
controllerView.fixedHeight = 100;
controllerView.background = Color.grey;

/* particle view */
particleView =  UserView.new(window, 700@100);
particleView.background = Color.black;


layout = VLayout(particleView, controllerView);
layout.margins = 0;
window.layout_(layout);

/*-----------------------SPRITE CREATION-------------------------*/

spriteFactory = {|tID|
  var mVal = 0.5;
  /* return */ (
    position:20@20,

    f_triggerID:{|self|
      tID;
    },

    f_setVal:{|self, val|
      mVal = val;
      self;
    },

    f_update: {|self, pos|
      var viewBounds = particleView.bounds;
      self['position'] = ((viewBounds.width/kNUM_UGENS)*tID) @ (viewBounds.height*mVal) ;
      self;
    },

    f_draw: {|self|
      var pos = self.position;
      Pen.fillOval(Rect(pos.x,pos.y,10,10));
      self;
    }
  );
};

/* create an array of sprites that are bound to a unit generator through the id */
sprites = Array.fill(kNUM_UGENS,{|i|
  spriteFactory.(i);
});

/*------------INSTALL THE OSC FUNCS -------------*/

/* handles the SendTrig messages which have the following format:
['/tr', nodeID, triggerID, TriggerValue ]
*/
oscHandle = OSCFunc.new({|msg|
  var triggerID = msg[2];
  var triggerVal = msg[3];

  sprites[triggerID].f_setVal(triggerVal);
}, '/tr');


/*--------------DRAW FUNC -------------------*/
particleView.drawFunc_({|thisView|
  var bounds = thisView.bounds;

  Pen.fillColor_(Color.white);

  /* update and draw sprites */
  sprites.do(_.f_update(thisView.frame % bounds.width @ 20));
  sprites.do(_.f_draw());


  // Pen.addOval(Rect(,20,20));   // an ellipse
  //
  // Pen.fill;   // draw only the outlines
});


/*---------------SHOW GUI --------------------*/

/* start the animation */
particleView.animate_(true).frameRate_(60);

window.onClose_({
  oscHandle.free;
});
/* show GUI */
window.front;



)


(
SynthDef(\Kupu2_Noise2, {|out= 0, mod1= 8, mod2= 20000, mod3= 400, amp= 0.5|

	var sig,noise, tick, send;

	noise= Mix.fill(3, { arg i; BPF.ar(WhiteNoise.ar(mul: SinOsc.ar(MouseX.kr(0,8),phase:Rand (0,pi), mul:Rand( 0.1,1) )),MouseY.kr(0,20000) * Rand(0,400) )});
1
	Out.ar(out, Pan2.ar(noise, 0.01));

	}).add;
)

(
SynthDef(\Kupu2_Noise2, {|out= 0, mod1= 8, mod2= 20000, mod3= 400, amp= 0.5|

	var sig,noise, tick, send;

  noise= Mix.fill(3, { arg i; var bpf = BPF.ar(WhiteNoise.ar(mul: SinOsc.ar(MouseX.kr(0,3*i),phase:Rand (0,pi), mul:Rand( 0.1,1) )),(MouseY.kr(0,20000)) * Rand(0,120) );
    SendTrig.kr(Impulse.kr(60), i, bpf.range(0,1));
    bpf;
  });


	Out.ar(out, Pan2.ar(noise, 0.01));

	}).add;
)

f = Synth(\Kupu2_Noise2)
f.free
(

SynthDef(\mixfill, {
 Mix.fill(40, { arg i ;
    var p =  Pulse.ar(
      freq:Pulse.kr(4+(i*1),
      mul: 1/40).range(20,100) ,
      width:SinOsc.kr(MouseY.kr(1,100)+i).range(0.2,0.3);
    );

    SendTrig.kr(Impulse.kr(60) , i, SinOsc.kr(MouseY.kr(1,100)+i).range(0,1)  );

    p = p.tanh;
    p = LeakDC.ar(p);
  });

  }).add ;
 )

Synth(\mixfill)
(
d = {MouseX.kr(1,62).poll;
  SendTrig.kr(Impulse.kr(60) , 0, SinOsc.kr(60).range(0,1)  );

}.play
)
d.free
(
d =  {
 // the same
 Mix.fill(40, { arg i ;
    var p =  Pulse.ar(Pulse.kr(4+(i*1), mul: 1/40).range(20,100) , width:SinOsc.kr(MouseY.kr(1,100)).range(0.2,0.3))  ;
     p = p.tanh;

    p = LeakDC.ar(p) * MouseX.kr(0,1);

   SendTrig.kr(Impulse.kr(60) , i,p.range(0,1));

    p * [1,1];
  })

 }.play ;
 )



s.scope


