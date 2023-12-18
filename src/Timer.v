module Timer #(parameter CLOCK_FREQUENCY = 50000000) (
    input clock, 
    input reset,
    input start,
    input stop, 
    input wire [1:0] speed,
    input wire [5:0] maxTime, 

    output reg [5:0] curTime, 
    output reg done
);

    wire enable;
    RateDivider #(.CLOCK_FREQUENCY(CLOCK_FREQUENCY))  RD(
        .clock(clock),
        .reset(reset),
        .start(start),
        .speed(speed),

        .enable(enable)
    );
    reg stopped;
    always@(posedge clock)
    begin
        done <= 1'b0;
        if(start==1'b1)
        begin
            curTime <= 6'b0;
            done <= 1'b0;
            stopped <= 1'b0;
        end
        else if(stop==1'b1)
            stopped <= 1'b1;
        else if(~stopped && curTime >= maxTime)
        begin
            done <= 1'b1;
        end
        else if(~stopped && enable==1'b1)
            curTime <= curTime + 1'b1;
    end
endmodule

// Timer #(.CLOCK_FREQUENCY(CLOCK_FREQUENCY)) T(
//     .clock(),
//     .reset(),
//     .start(),
//     .speed(),
//     .maxTime(),

//     .curTime(),
//     .done()
// )