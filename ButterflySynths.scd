(
/*
Butterfly - an audio visualizer for SuperCollider inspired by the butterfly effect

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

// 35 UGens

SynthDef(\butterfly_2, {|out=0, freq1= 50, freq2=10000, spd=10, gate3 = 1, x, y|
  var sig, sum, move, env, amp;
  //env= EnvGen.kr(Env([0, 1, 0],[2, 10 ],[2, 8]), doneAction:2);
  sum=0;
  env= EnvGen.kr(Env.adsr(0.01, 0.3, 0.5, 0.1), gate3, doneAction:2);
  move=LFNoise1.kr(spd);
  Mix.fill(35, {arg i;
    sig= Pulse.ar(
      ExpRand(
        freq1 + (i*1), freq2),
      {SinOsc.kr(ExpRand(1,100)).range(0.2,0.8)},
      LFNoise0.kr(ExpRand(0.3, 1.0)).exprange(0.0001, 0.2));
    sum= sum + sig;
    sum= BPF.ar(sum, x.linlin(0, 1, 100, 12000), 0.5, mul:1) * env;

    SendTrig.kr(Impulse.kr(60), i, (sum*10*y).range(-1,1) );


  });
  amp= y.linlin(0, 1, 0, 10);
  Out.ar(out, Pan2.ar(sum, move, amp));
}).add;

//////////


// 3 UGens
SynthDef(\butterfly_3, {|out=0, amp, x, y|

  var noise_feedback, mod, mul, pattern, click, noise, sinFB, env;

  amp= y.linlin(0, 1, 0, 1);

  pattern = /////////////complex pattern
  {TDuty.ar
    (Dxrand(((1/8!8) ++ (1/4!8) ++ [Dseq([1/16, 1/16], Drand([1, 2], inf))]) * 1.25, inf),
      0,
      Dwhite(0.5, 1, inf)
    )
  }!2;

  ///////////////

  click =
  BPF.ar
  (
    PinkNoise.ar(Decay.ar(pattern, 0.001 * LFNoise1.ar(10).abs, mul: 4)),
    15000,
    0.9,
    25 * LFNoise1.ar(8).range(0, 1)
  ).fold(-1, 1);

  ///////////////

  noise =
  BPF.ar
  (
    WhiteNoise.ar(Decay2.ar(pattern * LFNoise1.ar(8, 0.5, 0.5), 0.02, 0.1) * 10), TRand.ar(12000, 15000, pattern),
    0.9
  );

  ///////////////


  //mul= MouseY.kr(0, 0.25);
  mod= x.linlin(0, 1, 1, 5);
  noise_feedback= SinOscFB.ar(pattern, mod, mul:1);

  //////////

  sinFB= {SinOscFB.ar(20, 2, mul:0.7)

    *

    Env.perc(
      0.01, 0.5, 1).ar(0,
      TDuty.ar(Dseq(
        [1/4,1/4,1/4,1/4, 1/4, 1/4, 1/4, 1/4],
        inf)));
  };


  //SendTrig.kr(Impulse.kr(60) , 1, pattern.range(-1,1));
  SendTrig.kr(Impulse.kr(60) , 1, noise.range(-1,1));
  SendTrig.kr(Impulse.kr(60) , 0, noise.range(-1,1));
  SendTrig.kr(Impulse.kr(60) , 2, noise.range(-1,1));


  Out.ar(0, Pan2.ar((noise_feedback + noise + click + sinFB), level:amp));

}).add;



)