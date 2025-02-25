module nrziToSPI(
  input NRZIin,
  input SCKin,
  input CLK,
  output reg MOSI
);

reg [7:0] highTime;
reg NrziFilter;
always @(posedge CLK)
  if (SCKin) begin
    if (highTime < 2)
      highTime <= highTime + 1'b1;
    else
      NrziFilter <= NRZIin;
  end
  else begin
    highTime <= 0;
  end

/*
reg readWinner;
reg [7:0] readHighs;
reg [7:0] readLows;
always @(posedge CLK) begin
  if ((SCKin) && (readHighs < 8'hFF) && (readLows < 8'hFF)) //if sck is high and we're able to count further on both registers
    if (NRZIin)                   //count the NRZIin state
      readHighs <= readHighs + 1;
    else
      readLows <= readLows + 1;
  if ((~SCKin) && (readHighs != 8'd0) && (readLows != 8'd0)) begin //if sck is low and the counters are not reset yet
    if (readLows > readHighs) //record the winner
      readWinner <= 0;
    else
      readWinner <= 1;
    readHighs <= 8'd0;        //reset counters
    readLows <= 8'd0;
  end
end*/
/*
reg readWinner;
reg [7:0] readHighs;
reg [7:0] readLows;
always @(posedge CLK)   //at each clk edge,
  if (SCKin)              //if sck is high,
    if ((readHighs < 8'hFF) && (readLows < 8'hFF))
      if (NRZIin)             //if NRZIin is high,
        readHighs <= readHighs + 1; //add one to the high counter
      else
        readLows <= readLows + 1; //add one to the low counter
  else                  //else(sck low)
    if ((readHighs > 8'd0) || (readLows > 8'd0)) begin  //if this is the first low pulse
      if (readLows > readHighs) //record the winner, reset our counts
        readWinner <= 0;
      else
        readWinner <= 1;
      readHighs <= 8'd0;
      readLows <= 8'd0;
    end*/

//slightly after SCK falling edge, readWinner will reflect the value that NRZIin held during high SCK


reg NRZIlatch;
always @(posedge SCKin) begin
  NRZIlatch <= NrziFilter;
  end
  

always begin
  MOSI <= NRZIlatch^NrziFilter; 
  end

endmodule