A crude CD-Audio Digital Signal Processor designed for the Cyclone II EP2C5T144C8. Specifically those nice little dev boards with the 50MHz crystal.

Takes a logic-level NRZI bitstream and synchronized clock as input, outputs audio via i2s and q-subchannel data via RS232.
A convenient source of logic-level NRZI bitstream is the Playstation 1. There are two input pins on the console's built-in DSP that you can tap into for input to this project.

This is my first time experimenting with SystemVerilog, or actually any kind of hardware description language. The target device was selected for its very low price and availability. I have never touched any other FPGA, so I have no idea how portable this project is.
Notes are minimal, as I had a limited understanding of any of this until it was complete.
No error correction of any kind is implemented: error checking bits in each CIRC frame are unscrambled but ultimately ignored. I am extremely interested in how these bits should be used, and if anyone can share details please email me.

Top level module is CircDecoderRev.sv (that's right, I absolutely did not get this to work on my first try)
Since you probably don't want all of the q-subchannel bits output to your limited GPIO pins, you might consider just commenting those out.
