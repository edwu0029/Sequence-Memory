// 64-bit LSFR to generate a pseudo random 4-bit number

//Used Resources in:
//https://www.youtube.com/watch?v=Ks1pw1X22y4
//https://www.analog.com/en/design-notes/random-number-generation-using-lfsr.html
module LFSR#(parameter SEED = 64'd2854292432761329182)(
  input clock, 
  input reset, 
  input get, 
  
  output [3:0] num
);
  reg [63:0] q;
  always@(posedge clock)
  begin
    if(reset==1'b1)
      q <= SEED;
    else
    begin
      q <= {q[62:0], q[63]^q[0]};
    end
  end
  assign num = q[3:0]; //Take bottom 4 bits from q
endmodule