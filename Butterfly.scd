(
/*
Butterfly - an audio visualizer for SuperCollider inspired by the butterfly effect

Copyright (C) 2015 Fiore Martin


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

/*-------------------CONFIGURATION-----------------------------*/

var kUGENS_PER_SYNTH = [3, 40, 40, 1];
var kBUTTERFLY_COLORS = [Color.yellow, Color.green, Color.red, Color.blue];
var kFULL_SCREEN = true;


/*-----------------------INIT----------------------------------*/
var window, canvas, layout, spriteFactory, sprites, butterflyFactory, movingController = nil,
oscHandle, kNUM_CONTROLLERS = 4, controllers, kCONTROLLER_VIEW_HEIGHT = 200;



window = Window.new("Butterfly", 700@450, border:true);
canvas =  UserView.new(window, 700@450);

canvas.background = Color.black;


window.acceptsMouseOver = true;
layout = VLayout(canvas);
layout.margins = 0;
window.layout_(layout);


/*-----------------------SPRITE CREATION-------------------------*/

spriteFactory = {|tID, canvas, pos, area|
  var mPos = pos;
  var mVal = 0.0;
  var mArea = area;
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
      mPos = pos;
      self;
    },

    f_updateArea:{|self, area|
      mArea = area;
      self;
    },

    f_draw: {|self|
      /* pos is the centre of the drawing */
      var middle = mPos.y;
      var oscill = (mPos.x+(100 * mVal))@middle;

      //var halfHeight = canvas.bounds.height /2 ;
      //Pen.moveTo(pos.x@(halfHeight - (halfHeight*mVal))); // starting drawing point
      //Pen.curveTo(pos.x@halfHeight + (halfHeight*mVal) ,oscill,oscill);

      var halfScreen = (canvas.bounds.height/2);

      Pen.width = mArea.width/3;
      Pen.moveTo(mPos.x @ (mPos.y - (mVal * halfScreen)) ) ;
      Pen.lineTo(mPos.x@ (mPos.y + (mVal * halfScreen)));

      Pen.stroke;
      self;
    }
  );
};

/* the i determines the secotr in the view where this butterly operates */
butterflyFactory = {| i, canvas |
  var size = 15;
  var mPos = Rect(0,0,1,1);
  var mArea;
  var mOn = false;

  var butterfly = (

    f_contains:{|self, x, y|
      mPos.contains(x@y);
    },

    f_move:{|self, x, y|
      if(mArea.contains(x@y)){
        var newPos = mPos.moveTo(x, y);
        newPos.left = newPos.left - (size/2);
        newPos.top = newPos.top - (size/2);
        mPos = newPos;

      }
    },

    f_draw:{|self|
      Pen.fillColor = if(mOn) { kBUTTERFLY_COLORS[i] } { Color.grey } ;

      Pen.moveTo(mPos.leftTop);
      Pen.lineTo(mPos.rightBottom);
      Pen.lineTo(mPos.rightTop);
      Pen.lineTo(mPos.leftBottom);
      Pen.lineTo(mPos.leftTop);
      Pen.fill;
    },

    f_updateArea:{|self|
      var vBounds = canvas.bounds;
      var halfSize = size/2;

      mPos = Rect(
        /* left */
        if( (i==0).or(i==2)){ 0 - halfSize }{ 0 +(vBounds.width/2) - halfSize },

        /* top */
        if( (i==0).or(i==1)){ (vBounds.height/2) - halfSize }{ vBounds.height-halfSize },

        /* w */
        size,

        /* h */
        size);

      mArea = Rect(
        /* left */
        if( (i==0).or(i==2)){ 0 }{ vBounds.bounds.width/2 } ,

        /* top */
        if( (i==0).or(i==1)){ 0 }{ vBounds.height/2 },

        /* w */
        vBounds.width / 2 ,

        /* h */
        vBounds.height / 2
      ) ;
    },

    f_switch:{|self|
      mOn = mOn.not;
      self;
    },

    f_isOn:{|self|
      mOn;
    },

    f_toNormalCoord:{|self|
      var x = ((mPos.left + (size/2)) - mArea.left) / mArea.width;
      var invertedY = (mPos.top + (size/2)) - mArea.top ;
      y = (mArea.height - invertedY) / mArea.height;

      x@y;
    }
  );

  /*return*/ butterfly;
};

/* ---------------- INIT CONTROLLERS --------------------- */

/* controllers is an array of records (mSynthID, mSprites, mButterflies) */

controllers = Array.fill(kNUM_CONTROLLERS, ({|i|
  (mSynthID:-1, mSprites:List.new, mButterfly: butterflyFactory.(i, canvas) );
}));


canvas.mouseDownAction_{|thisCanvas, x, y, modifiers, buttonNumber, clickCount|
  controllers.do({|controller, i|
    if(controller.mButterfly.f_contains(x, y)){

      if(buttonNumber == 0){ // left click moves
        movingController = controller;
      };

      if(buttonNumber == 1){ // right click turns on/off
        movingController = nil;
        controller.mButterfly.f_switch();


        if(controller.mButterfly.f_isOn()){
          /* turn the synth on */
          var normCoord = controller.mButterfly.f_toNormalCoord();
          var synth = Synth(("butterfly_"++i).asSymbol, [\x, normCoord.x, \y, normCoord.x] );
          var sprites = controller.mSprites;
          var bounds = canvas.bounds;
          var offset = bounds.width / (kUGENS_PER_SYNTH[i] * 2);

          controller.mSynthID = synth.asNodeID;
          kUGENS_PER_SYNTH[i].do({|j|
            var position = (offset+ ((bounds.width/kUGENS_PER_SYNTH[i])*j)) @ (bounds.height/2);
            var area = Rect(position.x-offset, 0, 2*offset, bounds.height);

            var newSprite = spriteFactory.(j,canvas, position, area);
            sprites.add(newSprite);

          });

        }{
          /* turn the synth off */
          //s.sendMsg('/n_set', controller.mSynthID, "gate", 0);
          s.sendMsg('/n_free', controller.mSynthID);
          controller.mSprites.clear;
          controller.mSynthID = -1;
        }
      };
    }
  });
};

canvas.mouseMoveAction_({|thisCanvas, x, y|
  if(movingController.notNil){
    var normalCoord;

    movingController.mButterfly.f_move(x , y);

    if(movingController.mButterfly.f_isOn()){
      normalCoord = movingController.mButterfly.f_toNormalCoord();
      s.sendMsg('/n_set', movingController.mSynthID, \x, normalCoord.x, \y, normalCoord.y);
    }
  };
});

canvas.mouseUpAction_({|thisCanvas, x, y, modifiers|
  movingController = nil;
});

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



  controllers.do({|controller, i|
    var sprites = controller.mSprites;
    var butterfly = controller.mButterfly;
    var numSprites = sprites.size;

    Pen.fillColor = kBUTTERFLY_COLORS[i];
    Pen.strokeColor = kBUTTERFLY_COLORS[i];
    Pen.alpha = 0.5;
    /* update and draw sprites */
    sprites.do({|sprite, i|
      //sprite.f_updatePos(((bounds.width/numSprites)*i) @ (bounds.height/2) );
      sprite.f_draw();
    });

    /* draw butterfly */
    butterfly.f_draw();

  });

});


/*---------------SHOW GUI --------------------*/

/* start the animation */
canvas.animate_(true).frameRate_(60);
canvas.onResize_({
  controllers.do({|controller, i|
    var sprites = controller.mSprites;
    var numSprites = sprites.size;
    var offset = canvas.bounds.width / (kUGENS_PER_SYNTH[i] * 2);
    var bounds = canvas.bounds;

    /* resize the butterfly areas */
    controller.mButterfly.f_updateArea();

    /* reposition the sprites to cover the new bounds */
    sprites.do({|sprite, j|
      var position = offset+( (bounds.width/numSprites)*j) @ (bounds.height/2);
      sprite.f_updatePos(position);
      sprite.f_updateArea(Rect(position.x-offset, 0, 2*offset, bounds.height));
    });
  });
});

window.onClose_({
  oscHandle.free;
  controllers.do({|controller, i|
    if(controller.mSynthID != -1){
      s.sendMsg('/n_free', controller.mSynthID);
    }
  });
});

/* show GUI */

if(kFULL_SCREEN){
  window.fullScreen;
};

window.front;

)




