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


// 40 UGens
SynthDef(\butterfly_1, {|x, y, gate = 1|
  var env = EnvGen.kr(Env.adsr(0.01, 0.3, 0.5, 0.1), gate, doneAction:2);

  var m = Mix.fill(40, { arg i ;
    var p =  Pulse.ar(
      Pulse.kr(4+(i),
        mul: 1/40).range(20,100),
      width:SinOsc.kr(x.linlin(0,1,1,100)).range(0.2,0.3)
    ) * env;

    p = p.tanh;
    p = LeakDC.ar(p) * y;

    SendTrig.kr(Impulse.kr(60) , i, p.range(-1,1));
    p;
  });

  Out.ar(0,m * [1,1]);
}).add ;



)
