// Lights up the selected one hot for half second, then delays for half second
module PulseAnim
#(parameter CLOCK_FREQUENCY = 50000000)(
    input clock,
    input reset,
    input start,

    input wire [9:0] oneHot,

    output [9:0] LIGHTS,
    output wire done,

    output wire [2:0] currentState,
    output wire [5:0] curTime
);
    //Every half second, shift ledrs
    wire timerDone, timerStart;
    wire [1:0] timerSpeed;
    wire [9:0] val;

    assign LIGHTS = val;

    //Debug
    // wire [2:0] currentState;
    PulseAnimControl C(
        .clock(clock),
        .reset(reset),
        .start(start),
    
        .timerDone(timerDone),

        .oneHot(oneHot),

        .timerStart(timerStart),
        .timerSpeed(timerSpeed),
        .val(val),
        .done(done),

        .currentState(currentState)
    );

    Timer #(.CLOCK_FREQUENCY(CLOCK_FREQUENCY)) T1(
    .clock(clock),
    .reset(rest),
    .start(timerStart),
    .stop(1'b0), //Stop is not used here
    .speed(timerSpeed),
    .maxTime(6'd1),

    .curTime(curTime),
    .done(timerDone)
    );
endmodule

module PulseAnimControl(
    input clock,
    input reset,
    input start,
    input timerDone,

    input [9:0] oneHot,
    
    output reg timerStart,
    output reg [1:0] timerSpeed,
    output reg [9:0] val,
    output reg done,

    //Debugging
    output reg [5:0] currentState
);
    /*===================== FSM ======================== */
    reg [2:0] nextState;

    localparam  S_IDLE = 3'd1,
                S_INIT = 3'd2,
                S_ANIM_1 = 3'd3,
                S_WAIT_1 = 3'd4,
                S_ANIM_2 = 3'd5,
                S_WAIT_2 = 3'd6,
                S_DONE = 3'd7;

    // Next state logic aka our state table
    always@(*)
    begin: state_table
            case (currentState)
                S_IDLE: nextState = start ? S_INIT : S_IDLE;
                S_INIT: nextState = S_ANIM_1;
                S_ANIM_1: nextState = S_WAIT_1;
                S_WAIT_1:begin
                    if(timerDone)
                        nextState = S_ANIM_2;
                    else
                        nextState = S_WAIT_1;
                end
                S_ANIM_2: nextState = S_WAIT_2;
                S_WAIT_2:begin
                    if(timerDone)
                        nextState = S_DONE;
                    else
                        nextState = S_WAIT_2;
                end
                S_DONE: nextState = S_IDLE;
            default: nextState = S_IDLE;
        endcase
    end


    // Output logic aka all of our datapath control signals
    always @(*)
    begin
        // By default make all our signals 0
        timerStart <= 1'b0;
        done <= 1'b0;
        case (currentState)
            S_IDLE: begin
                timerSpeed <= 2'd0;
                val <= 10'd0;
            end
            S_INIT: begin
                timerSpeed <= 2'd2;
            end
            S_ANIM_1: begin
                timerStart <= 1'b1; //Pulse timer to start
                val <= oneHot;
            end
            S_ANIM_2: begin
                timerStart <= 1'b1; //Pulse timer to start
                val <= 10'd0;
            end
            S_DONE: begin
                done <= 1'b1;
            end
        endcase
    end

    // currentState registers
    always@(posedge clock)
    begin
        if(reset == 1'b1)
            currentState <= S_IDLE;
        else
            currentState <= nextState;
    end

    /*===================== FSM ======================== */
endmodule