module circStaggerDelay
#(
  parameter WIDTH = 8,
  parameter WORDS = 28
)(
  input                   CLK,
  input       [WORDS-1:0][WIDTH-1:0]  D,
  output wire [WORDS-1:0][WIDTH-1:0]  Q
);

wire [WORDS-2:0][7:0] delayOut;

genvar i;
generate
for (i = 0; i < 27; i++) begin : delayGenerator
  wordShiftRegister #(
    .WIDTH (8),
    .DEPTH ((27-i)*4)
  )
  delay(
    .CLK    (CLK),
    .D      (D[i][WIDTH-1:0]),
    .Q      (delayOut[i][7:0])
  );
end
endgenerate

always
  for (int j = 0; j < 27; j++)
    Q[j][7:0] <= delayOut[j][7:0];
    
assign Q[27][7:0] = D[27][7:0];


endmodule