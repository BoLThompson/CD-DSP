module Rs232TxD(
  input [7:0] TxD_in,
  input				TxD_start,
  input				clk,
  output reg  TxD,
  output 			busy
);

reg [3:0] state = 4'b0000;
reg [7:0] TxD_latch;

assign busy = (state != 4'b0000);

always @(posedge clk) begin
  case(state)
    4'b0000:									//idle
      if (TxD_start) begin
        state <= 4'b0100;				//move to start bit
        TxD_latch <= TxD_in;		//latch the input
        TxD <= 0;							//assert start bit
      end
    4'b0100:									//start bit
      begin
        state <= 4'b1000;				//move to bit 0
        TxD <= TxD_latch[0];		//assert bit 0
      end
    4'b1000:									//bit 0
      begin
        state <= 4'b1001;				//move to bit 1
        TxD <= TxD_latch[1];		//assert bit 1
      end
    4'b1001:									//bit 1
      begin
        state <= 4'b1010;				//move to bit 2
        TxD <= TxD_latch[2];		//assert bit 2
      end
    4'b1010:									//bit 2
      begin
        state <= 4'b1011;				//move to bit 3
        TxD <= TxD_latch[3];		//assert bit 3
      end
    4'b1011:									//bit 3
      begin
        state <= 4'b1100;				//move to bit 4
        TxD <= TxD_latch[4];		//assert bit 4
      end
    4'b1100:									//bit 4
      begin
        state <= 4'b1101;				//move to bit 5
        TxD <= TxD_latch[5];		//assert bit 5
      end
    4'b1101:									//bit 5
      begin
        state <= 4'b1110;				//move to bit 6
        TxD <= TxD_latch[6];		//assert bit 6
      end
    4'b1110:									//bit 6
      begin
        state <= 4'b1111;					//move to bit 7
        TxD <= TxD_latch[7];			//assert bit 7
      end
    4'b1111:									//bit 7
      begin
        state <= 4'b0001;				//move to stop 1
        TxD <= 1;							//assert stop bit
      end
    4'b0001:									//stop 1
      begin
        state <= 4'b0000;				//move to idle        stop 2
      end
    /*4'b0010:									//stop 2
      begin
        state <= 4'b0000;				//move to idle
      end*/
  endcase
end

endmodule