module CircFinalDelay #(
  parameter WIDTH = 8,
  parameter WORDS = 24
)(
  input 			[WORDS-1:0][WIDTH-1:0]	D,
  input 															CLK,
  output wire [WORDS-1:0][WIDTH-1:0]	Q
);

reg [(WORDS/2)-1:0][WIDTH-1:0] int_ltch1;
reg [(WORDS/2)-1:0][WIDTH-1:0] int_ltch2;

always begin
  for (int i = 0; i < WORDS; i = i + 8) begin
    Q[i  ][WIDTH-1:0] <= D[i  ][WIDTH-1:0];
    Q[i+1][WIDTH-1:0] <= D[i+1][WIDTH-1:0];
    Q[i+2][WIDTH-1:0] <= D[i+2][WIDTH-1:0];
    Q[i+3][WIDTH-1:0] <= D[i+3][WIDTH-1:0];
    Q[i+4][WIDTH-1:0] <= int_ltch2[(i/8)*4  ][WIDTH-1:0];
    Q[i+5][WIDTH-1:0] <= int_ltch2[(i/8)*4+1][WIDTH-1:0];
    Q[i+6][WIDTH-1:0] <= int_ltch2[(i/8)*4+2][WIDTH-1:0];
    Q[i+7][WIDTH-1:0] <= int_ltch2[(i/8)*4+3][WIDTH-1:0];
  end
end

always @(posedge CLK) begin
  for (int i = 0; i < WORDS; i = i + 8) begin
    int_ltch1[(i/8)*4  ][WIDTH-1:0] <= D[i+4][WIDTH-1:0];
    int_ltch1[(i/8)*4+1][WIDTH-1:0] <= D[i+5][WIDTH-1:0];
    int_ltch1[(i/8)*4+2][WIDTH-1:0] <= D[i+6][WIDTH-1:0];
    int_ltch1[(i/8)*4+3][WIDTH-1:0] <= D[i+7][WIDTH-1:0];
  end
  for (int i = 0; i < WORDS/2; i = i + 1) begin
    int_ltch2[i][WIDTH-1:0] <= int_ltch1[i][WIDTH-1:0];
  end
end

endmodule