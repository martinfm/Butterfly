(/*
Butterfly - an audio visualizer for SuperCollider inspired by the butterfly effect

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



/*-----------------------INIT----------------------------------*/
var window, controllerView, canvas, layout, spriteFactory, sprites,
oscHandle, kNUM_CONTROLLERS = 3, controllers, kCONTROLLER_VIEW_HEIGHT = 200;

var kNUMS_UGENTS = [3, 40, 40];


window = Window.new("Butterfly", 700@450, border:true);

/* controller view */
controllerView = HLayoutView.new(window, 900@kCONTROLLER_VIEW_HEIGHT);
controllerView.fixedHeight = 100;
controllerView.background = Color.gray;


/*-----------------------SPRITE CREATION-------------------------*/

spriteFactory = {|tID|
  var mVal = 0.0;
  /* return */ (
    position:20@20,

    f_triggerID:{|self|
      tID;
    },

    f_setVal:{|self, val|
      mVal = val;
      self;
    },

    f_updatePos: {|self, pos|
      var viewBounds = canvas.bounds;
      /* saves the position as the nth cloumn and bounds.height  */
      self['position'] = pos ;
      self;
    },

    f_draw: {|self|
      /* pos is the centre of the drawing */
      var pos = self.position;
      var middle = pos.y;
      var oscill = (pos.x+(100 * mVal))@middle;

      Pen.moveTo(pos.x@0); // starting drawing point
      Pen.curveTo(pos.x@canvas.bounds.height,oscill,oscill);


      /*var halfScreen = (canvas.bounds.height/2);
      Pen.moveTo(pos.x @ (pos.y - (mVal * halfScreen)) ) ;
      Pen.lineTo(pos.x@ (pos.y + (mVal * halfScreen)));*/

      Pen.stroke;
      self;
    }
  );
};



/* ---------------- INIT CONTROLLERS --------------------- */

/* controllers is an array of records (mSynthID, mSprites) */

controllers = Array.fill(kNUM_CONTROLLERS, ({|i|
  var v = HLayoutView( controllerView, 350@kCONTROLLER_VIEW_HEIGHT);
  var slider = Slider2D(v, 100@kCONTROLLER_VIEW_HEIGHT);
  var v2 = VLayoutView( v, 100@kCONTROLLER_VIEW_HEIGHT);
  var button = Button(v2, 100@50).states_([["Play",nil,nil],["Stop",nil,nil]]);
  var box = NumberBox(v2, 100@50 ).value_(kNUMS_UGENTS[i]);
  var separatorView = View(v, 50@50);

  var record = (mSynthID:-1, mSprites:List.new);

  button.action_({|thisButton|
    var value = thisButton.value;
    if(value == 1){ // play

      /* creates a synth and store the synthID, this controlled id and the sprites */
      var synth = Synth(("butterfly_"++i).asSymbol);
      record.mSynthID = synth.asNodeID;
      box.value.do({|j|
        var newSprite = spriteFactory.(j);
        record.mSprites.add(newSprite);
      });

    }{ // stop
      s.sendMsg('/n_free', record.mSynthID);
      record.mSprites.clear;
      record.mSynthID = -1;
    };
  });



  /*return*/ record;
}));


/* particle view */
canvas =  UserView.new(window, 700@100);
canvas.background = Color.black;


layout = VLayout(canvas, controllerView);
layout.margins = 0;
window.layout_(layout);




/*------------INSTALL THE OSC FUNCS -------------*/

/* handles the SendTrig messages which have the following format:
['/tr', nodeID, triggerID, TriggerValue ]
*/
oscHandle = OSCFunc.new({|msg|
  var nodeID = msg[1];
  var triggerID = msg[2];
  var triggerVal = msg[3];

  controllers.do({|record, i|
    if(record.mSynthID == nodeID ){
      record.mSprites[triggerID].f_setVal(triggerVal);
    }
  });
}, '/tr');


/*--------------DRAW FUNC -------------------*/
canvas.drawFunc_({|thisView|
  var bounds = thisView.bounds;

  Pen.fillColor_(Color.yellow);
  Pen.strokeColor_(Color.yellow);

  controllers.do({|controllerItem|
    var sprites = controllerItem.mSprites;
    var size = sprites.size;
    /* update and draw sprites */
    sprites.do({|item, i| item.f_updatePos(((bounds.width/size)*i) @ (bounds.height/2))});
    sprites.do(_.f_draw());
  });

});


/*---------------SHOW GUI --------------------*/

/* start the animation */
canvas.animate_(true).frameRate_(60);

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




d.free
(
d =  {
 // the same
 Mix.fill(40, { arg i ;
    var p =  Pulse.ar(Pulse.kr(4+(i*1), mul: 1/40).range(20,100) , width:SinOsc.kr(MouseY.kr(1,100)).range(0.2,0.3))  ;
     p = p.tanh;

    p = LeakDC.ar(p) * MouseX.kr(0,1);

   SendTrig.kr(Impulse.kr(60) , i, p.range(-1,1));

    p * [1,1];
  })

 }.play ;
 )


d = Synth(\mixfill)
d.free
(
SynthDef(\mixfill, {
 // the same
 Mix.fill(40, { arg i ;
    var p =  Pulse.ar(Pulse.kr(4+(i*1), mul: 1/40).range(20,100) , width:SinOsc.kr(MouseY.kr(1,100)).range(0.2,0.3))  ;
     p = p.tanh;

    p = LeakDC.ar(p) * MouseX.kr(0,1);

   SendTrig.kr(Impulse.kr(60) , i, p.range(-1,1));

    Out.ar(0,p * [1,1]);
  })

}).add ;
 )


