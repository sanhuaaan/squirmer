# Squirmer
Turn your Novation Launch Control into a weird sampler for Sonic Pi

Squirmer is a messily-coded midi sampler for Sonic Pi 3.0+ and Novation Launch Control. Just edit the first line of the file to make the "sample_source" var point to your sample folder and run the code.


# Guide

Once its running, you can use the Launch Control as follows:

 - There is room for 12 samples. These are triggered by the first six pads (left to right) of the launch control. When a sample is triggered, it's related pad is lighted yellow.
 - For changing the sample "page", press the 7th pad. You'll be able to access the next 6 samples. This 7th pad's light indicates the sample page you're on at each time.
 - The six first pair of knobs control the starting and ending point of each sample. The one above marks the starting point, and the one below marks the ending point.
 - The seventh pair of knobs control the sample pan (below), and the ring modulator frequency (above). Turn this last one to zero for deactivating the ring modulation.
 - The eighth pair of knobs control the pitch (above) and amp (below).
 - The eighth pad is used for changing the loop mode. When it's lighted red, the selected sample will not be replayed at end. When green lighted, the sample will be loop-played until the mode changes.
 - The four little knobs at right with arrow marks are used to activate/deactivate bitcrusher, echo, reverb and flanger effects.
 
 Have fun with this little mutant!
