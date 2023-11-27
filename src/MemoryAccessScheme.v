module MemoryAccessScheme(input user, 
    input [4:0] address1,
    input [15:0]data1,
    input wren1,

    input [4:0] address2,
    input [15:0]data2,
    input wren2,
    
    output reg [4:0] address,
    output reg [15:0] data,
    output reg wren
);
    always@(*)
    begin
        if(user==1'b0)
        begin
            address <= address1;
            data <= data1;
            wren <= wren1;
        end
        else
        begin
            address <= address1;
            data <= data1;
            wren <= wren1;
        end
    end
endmodule