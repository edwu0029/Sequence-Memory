//Generate level with moves stored in bram
// GeneralLevel G(
//     .clock(),
//     .reset(),
//     .start(),
//     .level(),

//     .done(),
//     .addressS(),
//     .dataS(),
//     .wrenS()
// );
module GenerateLevel(
    input clock,
    input reset,
    input start,
    input [2:0] level, //level 0, 1, 2, .. 7

    output wire done,
    output wire [4:0] addressS,
    output wire [3:0] dataS,
    output wire wrenS
);
    wire [2:0] totalMoves;
    assign totalMoves = level; //Moves are 0, 1, 2, ... level
    
    wire [2:0] moveNum;

    wire [3:0] moveOneHot;

    wire gen, load, moveIncr;

    GenerateControl C(
        .clock(clock),
        .reset(reset),
        .start(start),

        .totalMoves(totalMoves),
        .moveNum(moveNum),

        .gen(gen),
        .load(load),
        .moveIncr(moveIncr),
        .done(done)
    );

    GenerateDatapath D(
        .clock(clock),
        .start(start),
        
        .gen(gen),
        .load(load),
        .moveIncr(moveIncr),
        
        .moveNum(moveNum),
        .moveOneHot(moveOneHot),

        .addressS(addressS),
        .dataS(dataS),
        .wrenS(wrenS)
    );
endmodule

module GenerateControl(
    input clock,
    input reset,
    input start,

    input [2:0] totalMoves,
    input [2:0] moveNum,

    output reg gen,
    output reg load,
    output reg moveIncr,
    output reg done
);
    

    /*===================== FSM ======================== */
    reg [2:0] currentState, nextState;

    localparam  S_IDLE      = 3'd1,
                S_GEN       = 3'd2,
                S_LOAD      = 3'd3,
                S_NEXT_MOVE = 3'd4,
                S_DONE      = 3'd5;

    // Next state logic aka our state table
    always@(*)
    begin: state_table
            case (currentState)
                S_IDLE: nextState = start ? S_GEN : S_IDLE;
                S_GEN: nextState = S_LOAD;
                S_LOAD: nextState = S_NEXT_MOVE;
                S_NEXT_MOVE: begin
                    if(moveNum < totalMoves)
                        nextState = S_GEN;
                    else
                        nextState = S_DONE;
                end
                S_DONE: nextState = S_IDLE;
            default: nextState = S_IDLE;
        endcase
    end


    // Output logic aka all of our datapath control signals
    always @(*)
    begin
        // By default make all our signals 0
        gen <= 1'b0;
        load <= 1'b0;
        moveIncr <= 1'b0;
        done <= 1'b0;
        case (currentState)
            S_IDLE: begin
            end
            S_GEN: begin
                gen <= 1'b1;
            end
            S_LOAD: begin
                load <= 1'b1;
            end
            S_NEXT_MOVE: begin
                moveIncr <= 1'b1;
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
endmodule

module GenerateDatapath(
    input clock,
    input start,
    
    input gen,
    input load,
    input moveIncr,

    output reg [2:0] moveNum,
    output reg [3:0] moveOneHot,

    output reg [4:0] addressS,
    output reg [3:0] dataS,
    output reg wrenS
);

    wire [1:0] genNum;
    wire [3:0] oneHot;
    
    LFSR PRNG(
        .clock(clock),
        .start(start),
        .reset(rest),
        
        .num(genNum)
    );
    GetOneHot Conv(genNum, oneHot);

    always@(posedge clock)
    begin
        addressS <= 5'd0;
        dataS <= 4'd0;
        wrenS <= 1'b0;
        if(start==1'b1) begin
            moveNum <= 3'b0;
        end
        if(gen) begin
            moveOneHot <= oneHot;
        end
        if(load) begin
            addressS <= moveNum;
            dataS <= moveOneHot;
            wrenS <= 1'b1;
        end
        if(moveIncr) begin
            moveNum <= moveNum + 2'b1;
        end
    end
endmodule