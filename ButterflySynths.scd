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

SynthDef(\butterfly_0, {|out=0, mod1= 8, mod2= 20000, mod3= 400, amp= 0.5, gate1=1, x, y|

	var sig,noise, tick, env;

	env= EnvGen.kr(Env.adsr(0.01, 0.3, 0.5, 0.1), gate1, doneAction:2);
  noise= Mix.fill(3, { arg i;
		var bpf = BPF.ar(WhiteNoise.ar(mul: SinOsc.ar(x.linlin(0, 1,
			0,3*i),phase:Rand (0,pi), mul:Rand( 0.1,0.2) )),(y.linlin(0,1,0,20000)) * Rand(0,120)) * env;

    SendTrig.kr(Impulse.kr(60), i, bpf.range(-1,1));
    bpf;
  });
	Out.ar(out, Pan2.ar(noise, 0.01));
	}).add;



///////////////


SynthDef(\butterfly_2, {|out=0, freq1= 50, freq2=10000, spd=10, gate3 = 1, x, y|
	var sig, sum, move, env, amp;
	//env= EnvGen.kr(Env([0, 1, 0],[2, 10 ],[2, 8]), doneAction:2);
	sum=0;
    env= EnvGen.kr(Env.adsr(0.01, 0.3, 0.5, 0.1), gate3, doneAction:2);
	move=LFNoise1.kr(spd);
	Mix.fill(40, {arg i;
		sig= Pulse.ar(
			ExpRand(
				freq1 + (i*1), freq2),
			{SinOsc.kr(ExpRand(1,100)).range(0.2,0.8)},
					LFNoise0.kr(ExpRand(0.3, 1.0)).exprange(0.0001, 0.2));
		sum= sum + sig;
		sum= BPF.ar(sum, x.linlin(0, 1, 100, 12000), 0.5) * env;

		SendTrig.kr(Impulse.kr(60), i, sig.range(0,1));
		amp= y.linlin(0, 1, 0, 10);

	});
	Out.ar(out, Pan2.ar(sum, move, amp));
}).add;
)

