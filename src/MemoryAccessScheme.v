//2 bit mux that allows 2 users access to a bram
// MemoryAcessScheme MAS(
//     .user(),

//     .address1(),
//     .data1(),
//     .wren1(),

//     .address2(),
//     .data2(),
//     .wren2(),

//     .address(),
//     .data(),
//     .wren(),
// );

module MemoryAccessScheme(
    input [1:0] user,

    input [4:0] address1,
    input [3:0] data1,
    input wren1,

    input [4:0] address2,
    input [3:0] data2,
    input wren2,
    
    output reg [4:0] address,
    output reg [3:0] data,
    output reg wren
);
    always@(*)
    begin
        case(user)
            2'd1: begin
                address <= address1;
                data <= data1;
                wren <= wren1;
            end
            2'd2: begin
                address <= address2;
                data <= data2;
                wren <= wren2;
            end
            default: begin
                address <= 5'd0;
                data <= 3'd0;
                wren <= 1'b0;
            end

        endcase
    end
endmodule