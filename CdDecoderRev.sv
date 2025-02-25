module cdDecoderRev(
  input       MosiIn,		//'perfect' input from the mcu
  input       SckMosi,  //timing
  input       modeSel,  //connect to ground to select ps1 inputs
  input       NrziIn,		//lousy input from the laser
  input       SckNrzi,  //timing
  input       CLK50MHZ,
  output      TxO,
  output      BitClk,			//1.411200 MHz, or very close at least
  output      LrClk,      //44.1 kHz aligned with BitClk falling edge
  output      i2sData,
  output wire NRZIout,
  output wire MOSIout,
  output wire SCKout,
  output      SYNC,
  output wire [95:0] qBits
);

localparam SYM_PER_FRAME = 33;              //33 8-bit symbols in a frame (one is control byte)
localparam SYM_WIDTH = 8;

wire [7:0]  SYMBOL;
wire ATYPICAL;

/*//takes the SPI output of the teensy and NRZI encodes it
wire NrziMosi;  //just the NRZI form of the MOSI input
spiToNrzi SpiIn (
  .MOSI       (MosiIn),
  .SCK        (SckMosi),
  .NRZIOUT    (NrziMosi)
);*/

//select between the MCU inputs and the laser inputs
reg NRZI;
reg SCK;
assign SCKout = SCK;
assign NRZIout = NRZI;
always @*
  /*if (modeSel) begin  //ungrounded
    NRZI <= NrziMosi; //mcu mode
    SCK <= SckMosi;
  end
  else */begin        //grounded
    NRZI <= NrziIn; //ps1 mode
    SCK <= SckNrzi;
  end

//takes an NRZI input+sck (from the prior module) and makes SPI of it
wire MOSI;
nrziToSPI NrziInterpretor(
  .NRZIin     (NRZI),
  .SCKin      (SCK),
  .MOSI       (MOSI),
  .CLK        (CLK50MHZ)
);
assign MOSIout = MOSI;

wire S0, S1;
wire [32:0][7:0]FRAMEWORD;
wire frameLatch; //goes high when the data from the frameReader is ready to be accepted
frameReader fR(
  .MOSI       (MOSI),
  .SCK        (SCK),
  .frameWords (FRAMEWORD),
  .dataValid  (frameLatch),
  .S0         (S0),
  .S1         (S1),
  .SYNC       (SYNC)
);


//capture all the qData, format it, and fire it out in UART
//wire subcodeWord = FRAMEWORD[0][7:0];
SubcodeTx #(
  .LISTEN_BIT (6)
)
qTx (
  .frameLatch (frameLatch),
  .frameWord  (FRAMEWORD[0][7:0]),
  .CLK50MHZ   (CLK50MHZ),
  .S0         (S0),
  .S1         (S1),
  .TxO        (TxO),
  .qBits      (qBits)
);

wire [SYM_PER_FRAME-2:0][7:0] CIRCINPUT;  //outputs 1-33 of the word shift register
//connect frameword 1 to 33 to circinput 0 to 32
always for (int i = 0; i < SYM_PER_FRAME-1; i ++)
  CIRCINPUT[i][7:0] <= FRAMEWORD[i+1][7:0];

wire [5:0][31:0] CircOutput;
circDecoder Circ(
  .D    (CIRCINPUT),
  .CLK  (frameLatch),
  .Q    (CircOutput)
);

wire txStart;
wire [2:0] sampleIndex;
CounterAsyncReset #(
  .DATA_WIDTH   (3),
  .VAL_RST      (3'd0),
  .VAL_MAX      (6),
  .AUTO_RESET   (0)
)
sampleCounter(
  .rst        (frameLatch),
  .clk        (txStart),
  .clkInhibit (1'd0),
  .out        (sampleIndex)
);

wire [31:0] curSample;
MuxManyToOne #(
  .DATA_WIDTH (32),
  .BUS_COUNT  (6),
  .SEL_WIDTH  (3)
)
sampleMux(
  .inputBus   (CircOutput),
  .sel        (sampleIndex),
  .outputBus  (curSample)
);

wire [15:0] sampleL;
wire [15:0] sampleR;
assign sampleL[15:0] = curSample[31:16];
assign sampleR[15:0] = curSample[15:0];

i2sOutput i2s(
  .CLK50MHZ (CLK50MHZ),
  .sampleL  (sampleL),
  .sampleR  (sampleR),
  .txEnable (sampleIndex < 6),
  .LrClk    (LrClk),
  .i2sData  (i2sData),
  .BitClk   (BitClk),
  .txBegin  (txStart)
);

endmodule