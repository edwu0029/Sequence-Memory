module RateDivider
#(parameter CLOCK_FREQUENCY = 50000000) (
    input clock, 
    input reset,
    input start, 
    input [1:0] speed,
    
    //speed = 1 -> 1 sec
    //speed = 2 -> 0.5 sec
    //speed = 3 -> 0.25 sec
    // NOTE THAT speed must be held for the divider to work!

    output reg enable
);

    reg [25:0] count;
    reg counting;
    always@(posedge clock)
    begin
	    enable <= 1'b0;
        if(reset==1'b1) 
            counting <= 1'b0;
        if(start==1'b1) begin
            count <= 26'd0;
            counting <= 1'b1; //Start counting
        end
        else if(count>=CLOCK_FREQUENCY) begin
            count <= 26'd0;
			enable <= 1'b1;
        end
        else if(counting==1'b1) begin
            case(speed)
                2'd1: count <= count + 26'd1;
                2'd2: count <= count + 26'd2;
                2'd3: count <= count + 26'd4;
                default: count <= count;
            endcase
        end
    end
endmodule

// RateDivider #(.CLOCK_FREQUENCY(CLOCK_FREQUENCY))  RD(
//     .clock(),
//     .reset(),
//     .start(),
//     .speed(),

//     .enable()
// );