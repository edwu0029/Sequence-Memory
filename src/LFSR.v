// 64-bit LSFR to generate a pseudo random 2-bit number

//Used Resources in:
//https://www.youtube.com/watch?v=Ks1pw1X22y4
//https://www.analog.com/en/design-notes/random-number-generation-using-lfsr.html
module LFSR#(parameter SEED = 64'b0011101011111110011000000010100111110001010110100101001010011000)(
  input clock,
  input reset,
  input start, 
  
  output [1:0] num
);
  reg [63:0] q;
  always@(posedge clock)
  begin
    if(reset==1'b1)
      q <= SEED;
    else
    begin
      q <= {q[62:0], q[63]^q[62]^q[60]^q[59]};
      // q <= 64'd1;
    end
  end
  assign num = q[1:0]; //Take bottom 2 bits from q
endmodule