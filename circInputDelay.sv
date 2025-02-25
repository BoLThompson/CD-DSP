module circInputDelay
#(
	parameter WIDTH = 8,
	parameter WORDS = 32
)(
	input 			[WORDS-1:0][WIDTH-1:0] 	D,
	input 															CLK,
	output	wire	[WORDS-1:0][WIDTH-1:0]	Q			
);

reg [(WORDS/2)-1:0][WIDTH-1:0] int_ltch;

always begin
	for (int i = 0; i < WORDS; i = i + 2)
		Q[i][WIDTH-1:0] <= D[i][WIDTH-1:0];
	for (int i = 1; i < WORDS; i = i + 2)
		Q[i][WIDTH-1:0] <= int_ltch[(i-1)/2][WIDTH-1:0];
	end

always @(posedge CLK) begin
	for (int i = 1; i < WORDS; i = i + 2) begin	//odds delayed
		int_ltch[(i-1)/2][WIDTH-1:0] <= D[i][WIDTH-1:0];
	end
end

endmodule