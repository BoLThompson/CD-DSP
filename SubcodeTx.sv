module SubcodeTx #(
	parameter LISTEN_BIT = 6
)(
	input 				frameLatch,
	input [7:0]		frameWord,
	input					CLK50MHZ,
	input					S0,
	input					S1,
	output				TxO,
	output reg [95:0] qBits	//latches the qBitShiftReg when S0+frameLatch rises (end of subcode block)
);


reg [95:0] qBitShiftReg;		//shift register that takes bit 6 (q) of all the control bytes in a frame			
reg [15:0] crc;
//reg [7:0] bitCnt;
reg txRst = 0;
															//read by the qTransmitter while the new subcode block is recorded

always @(posedge frameLatch)										//on the rise of frameLatch,
	if (~S0 && ~S1) begin														//if S0 and S1 are low,
		qBitShiftReg <= (qBitShiftReg << 1) + frameWord[LISTEN_BIT]; //capture the next qBit of the subcode block
		crc[ 0] <= frameWord[LISTEN_BIT] ^ crc[15];
		crc[ 1] <= crc[ 0];
		crc[ 2] <= crc[ 1];
		crc[ 3] <= crc[ 2];
		crc[ 4] <= crc[ 3];
		crc[ 5] <= (crc[15]) ^ crc[ 4];
		crc[ 6] <= crc[ 5];
		crc[ 7] <= crc[ 6];
		crc[ 8] <= crc[ 7];
		crc[ 9] <= crc[ 8];
		crc[10] <= crc[ 9];
		crc[11] <= crc[10];
		crc[12] <= (crc[15]) ^ crc[11];
		crc[13] <= crc[12];
		crc[14] <= crc[13];
		crc[15] <= crc[14];
		txRst <= 0;
	end
	else if (S0) begin
		qBits[95:16] <= qBitShiftReg[95:16];	//freeze the shift register into the latch that the UART reads from
		qBits[15:0] <= ~crc;
		txRst <= 1;
		crc <= 16'd0;
	end
	else
		txRst <= 0;

wire [11:0][7:0] qBytes;
always
	for (int i = 0; i < 96; i++) begin
		qBytes[11-i/8][i%8] <= qBits[i];
	end
	
Tx12Bytes transmitter(
	.MsgIn			(qBytes),
	.rst				(txRst),
	.CLK50MHZ		(CLK50MHZ),
	.TxO				(TxO)
);


endmodule