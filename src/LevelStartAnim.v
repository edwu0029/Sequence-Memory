// Individually lights up each LED, quarter second each
module LevelStartAnim
#(parameter CLOCK_FREQUENCY = 50000000)(
    input clock,
    input reset,
    input start,

    output wire [9:0] LIGHTS,
    output wire done,

    output wire [2:0] currentState,
    output wire [5:0] curTime
);
    //Every quarter second, shift ledrs
    wire timerDone, init, timerStart, valShift;
    wire [1:0] timerSpeed;
    wire [9:0] val;

    assign LIGHTS = val;

    //Debug
    // wire [2:0] currentState;
    LevelStartControl CLevelStart(
        .clock(clock),
        .reset(reset),
        .start(start),
        
        .timerDone(timerDone),
        .val(val),

        .init(init),
        .timerStart(timerStart),
        .timerSpeed(timerSpeed),
        .valShift(valShift),
        .done(done),

        .currentState(currentState)
    );
    LevelStartDatapath DLevelStart(
        .clock(clock),
        .reset(reset),

        .init(init),
        .valShift(valShift),
        .done(done),
        
        .val(val)
    );

    Timer #(.CLOCK_FREQUENCY(CLOCK_FREQUENCY)) T(
    .clock(clock),
    .reset(rest),
    .start(timerStart),
    .speed(timerSpeed),
    .maxTime(6'd1),

    .curTime(curTime),
    .done(timerDone)
    );
endmodule

module LevelStartControl(
    input clock,
    input reset,
    input start,
    input timerDone,
    input [9:0] val,

    output reg init,
    output reg timerStart,
    output reg [1:0] timerSpeed,
    output reg valShift,
    output reg done,

    //Debugging
    output reg [5:0] currentState
);
    /*===================== FSM ======================== */
    reg [2:0] nextState;

    localparam  S_IDLE = 3'd1,
                S_INIT = 3'd2,
                S_ANIM = 3'd3,
                S_WAIT = 3'd4,
                S_SHIFT = 3'd5,
                S_DONE = 3'd6;

    // Next state logic aka our state table
    always@(*)
    begin: state_table
            case (currentState)
                S_IDLE: nextState = start ? S_INIT : S_IDLE;
                S_INIT: nextState = S_ANIM;
                S_ANIM: nextState = S_WAIT;
                S_WAIT:begin
                    if(timerDone)
                        if(val==10'd512)
                            nextState = S_DONE;
                        else
                            nextState = S_SHIFT;
                    else
                        nextState = S_WAIT;
                end
                S_SHIFT: nextState = S_ANIM;
                S_DONE: nextState = S_IDLE;
            default: nextState = S_IDLE;
        endcase
    end // state_table


    // Output logic aka all of our datapath control signals
    always @(*)
    begin
        // By default make all our signals 0
        timerStart <= 1'b0;
        done <= 1'b0;
        init <= 1'b0;
        valShift <= 1'b0;
        case (currentState)
            S_IDLE: begin
                timerSpeed <= 2'd0;
            end
            S_INIT: begin
                init <= 1'b1;
                timerSpeed <= 2'd3;
            end
            S_ANIM: begin
                timerStart <= 1'b1; //Pulse timer to start
            end
            S_SHIFT: begin
                valShift <= 1'b1;
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
    end // state_FFS

    /*===================== FSM ======================== */
endmodule

module LevelStartDatapath(
    input clock,
    input reset,
    
    input init,
    input valShift,
    input done,

    output reg [9:0] val
);
    always@(posedge clock)
    begin
        if(init)
            val = 10'b1;
        else if(valShift)
            val = (val << 10'b1);
        else if(done)
            val = 10'd0;
    end
endmodule