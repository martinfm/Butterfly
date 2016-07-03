(
//The following synth is an excerpt of Miguel Negrao' Pan Sonic emulation - Katodivaihe - lahetys
// adapted to work with Butterfly
//http://sccode.org/1-4TP

// 12 UGens
SynthDef(\butterfly_0, {|x , y|
  var n,e;

  n = 12;
  e = (
    (
      {
        var saw ;
        saw= Saw.ar( 40*(1..n) * ({ LFNoise1.ar(0.1).range(1,1.01)  * x.linlin(0,1,0.4,1)} ! n) ) *
        ({ LFNoise1.ar(0.1).range(0.0,1.0) }!n);
        saw = saw * y;
        SendTrig.kr(Impulse.kr(60), (0..n-1), saw);
        saw;
      }.();
    )
  ).sum * 10;
  e = CombC.ar(e, 0.1, 0.1, 4) + e;
  e = e.tanh * 0.3 * SinOsc.ar(0.05).range(0.5,1.0);
  e = e.dup;
  e = e * SinOsc.ar(0.03).range(0.2,1.0) * 0.5;

  Out.ar(0,e);
}).add();

)
