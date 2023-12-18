// Display 6-bit number(Up to 127) in decimal format on 3 7-seg displays
module DecimalDisplay(
    input [5:0] val,

    output wire [6:0] d0,
    output wire [6:0] d1
);
    //d0 is the right most digit in decimal format
    //d1 is the left most digit in decimal format
   reg [5:0] temp;
	reg [3:0] digit0, digit1;
    always@(*)
    begin
        temp = val;
        digit0 = temp%4'd10;
        temp = temp/4'd10;
        digit1 = temp%4'd10;
    end
    HexDecoder D0(digit0, d0);
    HexDecoder D1(digit1, d1);
endmodule