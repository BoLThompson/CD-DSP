module CounterAsyncReset #(
	parameter DATA_WIDTH = 8,
	parameter VAL_RST = {DATA_WIDTH{1'b0}},
	parameter VAL_MAX = 2^(DATA_WIDTH-1),
	parameter AUTO_RESET = 0
)(
	input 												rst,
	input 												clk,
	input													clkInhibit,
	output reg [DATA_WIDTH-1:0] 	out
);

always @(posedge clk or posedge rst) begin
	if (rst)
		out <= VAL_RST;
	else
		if (~clkInhibit)
			if (out < VAL_MAX)
				out <= out + 1'b1;
			else if ((out == VAL_MAX) && (AUTO_RESET == 1))
				out <= VAL_RST;
end

endmodule