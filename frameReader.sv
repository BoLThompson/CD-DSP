//listens for a sync pattern, then records all the 8 bit symbols of the smallframe.
  //outputs all 33 frame symbols
  //outputs a flag for S0 and S1
  //dataValid goes high once a frame is completely read and output is acceptable
module frameReader(
  input MOSI,
  input SCK,
  output [32:0][7:0] frameWords,
  output reg dataValid,
  output reg S0,
  output reg S1,
  output wire SYNC
);

//detects sync patterns from an spi stream, output Pulse rises on sck falling edge before
  //the first merging bit after a sync pattern
//wire SYNC;
wire ATYPICAL;

syncCatcher SyncCatcher(
  .MOSI				(MOSI),
  .SCK				(SCK),
  .Pulse 			(SYNC)
);

//reset by the sync pulse. alternates between ignoring three bits and capturing fifteen bits
  //for 33 iterations. outputs 8-bit symbols corresponding to the captured efm pattern.
  //atypical goes high for S0, S1, or unrecognized efm codes.
  //latch out goes high on the falling sck edge before the first merging bit after an efm code
wire [7:0] SYMBOL;
wire finalSymbol;
wire SYMBOL_LATCH;
codewordDemodulator Demodulator(
  .SYNC				(SYNC),
  .MOSI				(MOSI),
  .SCK				(SCK),
  .SYMBOL_OUT (SYMBOL),
  .ATYPICAL 	(ATYPICAL),
  .LATCH_OUT	(SYMBOL_LATCH),
  .finalSymbol(finalSymbol)
);

//clears S0 and S1 at every sync pulse.
  //sets S0 or S1 as soon as the codewordDemodulator outputs those patterns,
  //which remain set until the end of the frame
always @ (posedge SYNC or posedge SYMBOL_LATCH) begin
  if (SYNC) begin
    S0 <= 0;
    S1 <= 0;
  end
  else if ((ATYPICAL) && (SYMBOL == 8'd0))
    S0 <= 1;
  else if ((ATYPICAL) && (SYMBOL == 8'd1))
    S1 <= 1;
end

wordShiftRegister //control byte is bus zero of frameword
  #(
    .WIDTH(8),
    .DEPTH(33)
  )
  FrameWordReg(
    .D					(SYMBOL),
    .CLK				(SYMBOL_LATCH),
    .Q					(frameWords)
);

//delay the finalSymbol flag by one SCK before sending out our dataValid flag
  //this needs to be done in order for the wordShiftRegister to catch up and output valid data
always @(negedge SCK)
  if (finalSymbol) dataValid <= 1;
  else dataValid <= 0;

endmodule