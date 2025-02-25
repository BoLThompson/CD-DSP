module MuxManyToOne #(
  parameter DATA_WIDTH = 8,
  parameter BUS_COUNT = 2,
  parameter SEL_WIDTH = 1
)(
  input [BUS_COUNT-1:0][DATA_WIDTH-1:0] inputBus,
  input [SEL_WIDTH-1:0] sel,
  output [DATA_WIDTH-1:0]	outputBus
);

always begin
  outputBus[DATA_WIDTH-1:0] <= inputBus[sel][DATA_WIDTH-1:0];
end

endmodule