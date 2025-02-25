module i2sOutput (
	input							CLK50MHZ,
	input 	[15:0]		sampleL,
	input		[15:0]		sampleR,
	input							txEnable,
	output	reg				BitClk,
	output	reg				LrClk,
	output	wire			i2sData,
	output	reg				txBegin
);

//generate the bit clock
reg [5:0] BitClkAccumulator;	//counts up to alternating 35/36 master clock cycles
reg  BitClkAccToggle;					//tracks the alternation
always @(posedge CLK50MHZ) begin
		case (BitClkAccumulator + 1 + BitClkAccToggle)
			6'd36: begin
					BitClkAccumulator <= 6'd0;
					BitClk <= 0;
					BitClkAccToggle <= ~BitClkAccToggle;
				end
			6'd18: begin
					BitClk <= 1;
					BitClkAccumulator <= BitClkAccumulator + 1'd1;
				end
			default:
				BitClkAccumulator <= BitClkAccumulator + 1'd1;
			endcase
end

reg[7:0] state = 8'd0;
reg [32:0] sampleShiftReg;	//shift register is an extra bit wide
															//data must be delayed 1 BitClk w/ respect to LrClk
always @(negedge BitClk) begin
	case (state)
		8'd00:	//idle
			if (txEnable) begin
				state <= state + 1'd1;
				LrClk <= 0;
				sampleShiftReg[15:0] <= sampleR;
				sampleShiftReg[31:16] <= sampleL;
				txBegin <= 1;
			end
		8'd16: begin
				sampleShiftReg <= (sampleShiftReg << 1);
				state <= state + 1'd1;
				LrClk = 1;
			end
		8'd31: begin
				state <= 8'd0;
				sampleShiftReg <= (sampleShiftReg << 1);
			end
		default begin
				txBegin <= 0;
				sampleShiftReg <= (sampleShiftReg << 1);
				state <= state + 1'd1;
			end
	endcase
end

assign i2sData = sampleShiftReg[32];

endmodule