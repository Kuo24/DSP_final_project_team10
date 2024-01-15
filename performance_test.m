sample_rate = 44100;

t = 0: 1/sample_rate:0.1;
f = 880;
y = sin(2.*pi.*f.*t);

pitch = yinPitchDetection(y, sample_rate);
disp(pitch);

