// Display 7-bit number(Up to 127) in decimal format on 3 7-seg displays
module DecimalDisplay(
    input [6:0] val,

    output wire [6:0] d0,
    output wire [6:0] d1,
    output wire [6:0] d2
);
    //d0 is the right most digit in decimal format
    //d2 is the left most digit in decimal format
    reg [6:0] temp;
	reg [3:0] digit0, digit1, digit2;
    always@(val)
    begin
        temp = val;
        digit0 = temp%10;
        temp = temp/4'd10;
        digit1 = temp%10;
        temp = temp/4'd10;
        digit2 = temp%10;
    end

    HexDecoder D0(digit0, d0);
    HexDecoder D1(digit1, d1);
    HexDecoder D2(digit2, d2);
endmodule
module HexDecoder(c, display);
    input [3:0] c;
    output [6:0] display;
    assign display[0] = ((~c[3]&~c[2]&~c[1]&c[0])|(~c[3]&c[2]&~c[1]&~c[0])|(c[3]&~c[2]&c[1]&c[0])|(c[3]&c[2]&~c[1]&c[0]));
    assign display[1] = ((~c[3]&c[2]&~c[1]&c[0])|(~c[3]&c[2]&c[1]&~c[0])|(c[3]&~c[2]&c[1]&c[0])|(c[3]&c[2]&~c[1]&~c[0])|(c[3]&c[2]&c[1]&~c[0])|(c[3]&c[2]&c[1]&c[0]));
    assign display[2] = ((~c[3]&~c[2]&c[1]&~c[0])|(c[3]&c[2]&~c[1]&~c[0])|(c[3]&c[2]&c[1]&~c[0])|(c[3]&c[2]&c[1]&c[0]));
    assign display[3] = ((~c[3]&~c[2]&~c[1]&c[0])|(~c[3]&c[2]&~c[1]&~c[0])|(~c[3]&c[2]&c[1]&c[0])|(c[3]&~c[2]&c[1]&~c[0])|(c[3]&c[2]&c[1]&c[0])  );
    assign display[4] = ((~c[3]&~c[2]&~c[1]&c[0])|(~c[3]&~c[2]&c[1]&c[0])|(~c[3]&c[2]&~c[1]&~c[0])|(~c[3]&c[2]&~c[1]&c[0])|(~c[3]&c[2]&c[1]&c[0])|(c[3]&~c[2]&~c[1]&c[0]));
    assign display[5] = ((~c[3]&~c[2]&~c[1]&c[0])|(~c[3]&~c[2]&c[1]&~c[0])|(~c[3]&~c[2]&c[1]&c[0])|(~c[3]&c[2]&c[1]&c[0])|(c[3]&c[2]&~c[1]&c[0])  );
    assign display[6] = ((~c[3]&~c[2]&~c[1]&~c[0])|(~c[3]&~c[2]&~c[1]&c[0])|(~c[3]&c[2]&c[1]&c[0])|(c[3]&c[2]&~c[1]&~c[0]));
endmodule