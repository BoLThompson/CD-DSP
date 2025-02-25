//take the 12 byte input and output the 37 character string
module QSubcodeFormatter(
  input [11:0][7:0] qWords,
  output [36:0][7:0] outChars
);

localparam Ascii0 = 8'd48;  //Ascii code for zero
localparam AsciiA = 8'd55;  //(Ascii code for A) - 10
                              //(hex value over 9) + (Ascii a - 10) = ascii code to represent that hex digit

always begin
  for (int i = 0; i < 10; i++) begin
    if (qWords[i][7:4] <= 4'd9)                     //if upper nybble is 0-9
      outChars[i*3][7:0] <= Ascii0 + qWords[i][7:4];    //add that nybble to the ascii code for zero
    else                                            //otherwise, the nybble has made it into the A-F range
      outChars[i*3][7:0] <= AsciiA + qWords[i][7:4];    //add that nybble for ascii a - 10
      
    if (qWords[i][3:0] <= 4'd9)
      outChars[(i*3)+1][7:0] <= Ascii0 + qWords[i][3:0];
    else
      outChars[(i*3)+1][7:0] <= AsciiA + qWords[i][3:0];
  end
  
  if ((qWords[10][7:0] == 8'd0) && (qWords[11][7:0] == 8'd0)) begin
    outChars[30][7:0] <= 8'd32;
    outChars[31][7:0] <= 8'd32;
    outChars[33][7:0] <= 8'd32;
    outChars[34][7:0] <= 8'd32;
  end
  else
    for (int i = 10; i < 12; i++) begin
        if (qWords[i][7:4] <= 4'd9)                     //if upper nybble is 0-9
        outChars[i*3][7:0] <= Ascii0 + qWords[i][7:4];    //add that nybble to the ascii code for zero
      else                                            //otherwise, the nybble has made it into the A-F range
        outChars[i*3][7:0] <= AsciiA + qWords[i][7:4];    //add that nybble for ascii a - 10
        
      if (qWords[i][3:0] <= 4'd9)
        outChars[(i*3)+1][7:0] <= Ascii0 + qWords[i][3:0];
      else
        outChars[(i*3)+1][7:0] <= AsciiA + qWords[i][3:0];
    end
  
  for (int i = 0; i <= 11; i++) begin
    outChars[(i*3)+2][7:0] <= 8'd32;
  end
  
  outChars[35][7:0] <= 8'h0A; //carriage return and line feed
  outChars[36][7:0] <= 8'h0D;
end

endmodule