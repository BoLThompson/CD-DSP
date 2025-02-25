module wordShiftRegister
  #(
    parameter WIDTH = 8,
    parameter DEPTH = 33
  )
  (
    input				[WIDTH-1:0] 	D,
    input											CLK,
    output	reg	[DEPTH-1:0][WIDTH-1:0]		Q
  );

always @(posedge CLK) begin
  Q[DEPTH-1][WIDTH-1:0] <= D[WIDTH-1:0];
  for (int i = 0; i < (DEPTH-1); i = i + 1) begin
    Q[i][WIDTH-1:0] <= Q[1+i][WIDTH-1:0];
  end
end
      
endmodule