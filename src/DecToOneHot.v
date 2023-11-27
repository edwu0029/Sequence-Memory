//Decodes val into a one hot code with 1 being the val'th bit
module DecToOneHot(input [3:0] val, output [15:0] oneHotCode);
  assign oneHotCode = (16'b1) << val;
endmodule
