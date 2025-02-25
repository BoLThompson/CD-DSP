//takes 11 bytes of q subcode as input
//outputs a formatted uart 8 bit-byte string of human readable hex to represent the input
module Tx12Bytes (
  input	[11:0][7:0]			MsgIn,
  input									rst,
  input 								CLK50MHZ,
  output								TxO
);

//get 115200 baud from the clock input
//BaudTick is high for one clk every 115.2KHz
reg [8:0] BaudCnt;
always @(posedge CLK50MHZ)
  if (rst)
    BaudCnt <= 0;
  else begin	
    if (BaudCnt <= 9'd434)
      BaudCnt <= BaudCnt + 1'b1;
    else
      BaudCnt <= 0;
  end
wire BaudTick = (BaudCnt == 9'd433);

//37 character string to output
wire [36:0][7:0] FmtdMsg;

//turn the 11 bytes of input into a human readable 37 character string
QSubcodeFormatter qNice(
  .qWords			(MsgIn),
  .outChars		(FmtdMsg)
);

//rises with each sent byte, used to count out the sent bytes of our message
wire byteSent;

//output of the below counter
wire [5:0] charIndex;

//asynchronous counter from zero to 37 (each byte + idle)
CounterAsyncReset #(
  .DATA_WIDTH		(6),
  .VAL_RST 			(6'd0),
  .VAL_MAX			(37)
)
charCounter(
  .rst				(rst),
  .clk				(byteSent),
  .clkInhibit (1'd0),
  .out				(charIndex)
);

//connect the following mux to the tx module
wire [7:0] curChar;

//use the counter value to connect each byte from the string to the tx module
MuxManyToOne #(
  .DATA_WIDTH (8),
  .BUS_COUNT	(37),
  .SEL_WIDTH (6)
)
stringMux(
  .inputBus 	(FmtdMsg),
  .sel				(charIndex),
  .outputBus 	(curChar)
);

//actually output the UART waveform
Rs232TxD TxModule(
  .TxD_in			(curChar),
  .TxD_start	(charIndex < 37),
  .clk				(BaudTick),
  .TxD				(TxO),
  .busy				(byteSent)
);

endmodule