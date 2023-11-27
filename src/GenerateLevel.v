//Generates a level based on the 
module GenerateLevel(
    input clock,
    input [4:0] levelNum,
    input start,
    input reset,

    output done,
    output wire [4:0] address,
    output wire [15:0] dataIn,
    output wire wren
);
    wire [4:0] totalMoves;
    assign totalMoves = (levelNum/5'd2); //move 0, 1, 2, ... levelNum/2

    wire regen;
    wire [4:0] moves;

    wire gen, load, moveIncr;
    wire [5:0] currentState, nextState;


    GenerateLevelControl GLC(clock, reset, start, totalMoves,
    regen, moves,
    gen, load, moveIncr, done
    );
    
    wire [15:0] temp;
    wire [15:0]oneHotCode;

    GenerateLevelDatapath DP(clock, reset,
    gen, load, moveIncr,
    moves, regen, temp, oneHotCode, address, dataIn, wren);
endmodule

module GenerateLevelControl(
    input clock,
    input reset,
    input start,
    input [4:0] totalMoves,

    input regen, 
    input [4:0] moves,

    output reg gen,
    output reg load,
    output reg moveIncr,
    output reg done
);

    reg [5:0] currentState, nextState;

    localparam  S_IDLE         = 5'd0,
                S_GEN          = 5'd1,
                S_LOAD         = 5'd2,
                S_NEXT_MOVE    = 5'd3,
                S_FINISH       = 5'd4;

    // Next State Logic
    always@(*)
    begin
            case (currentState)
                S_IDLE:
                begin
                    if(start)
                        nextState = S_GEN;
                    else
                        nextState = S_IDLE;
                end
                S_GEN:
                begin
                    if(regen==1'b0) // No need to regenerate
                        nextState = S_LOAD;
                    else
                        nextState = S_GEN;
                end
                S_LOAD: nextState = S_NEXT_MOVE;
                S_NEXT_MOVE:
                begin
                    if(moves<totalMoves)
                        nextState = S_GEN;
                    else
                        nextState = S_FINISH;
                end
                S_FINISH: nextState = S_IDLE;
            default:     nextState = S_IDLE;
        endcase
    end // state_table


    // Output logic aka all of our datapath control signals
    always @(*)
    begin
        gen <= 1'b0;
        load <= 1'b0;
        moveIncr <= 1'b0;
        done <= 1'b0;
        case (currentState)
            S_GEN:
                gen <= 1'b1;
            S_LOAD:
                load <= 1'b1;
            S_NEXT_MOVE:
                moveIncr <= 1'b1;
            S_FINISH:
                done <= 1'b1;
        endcase
    end

    // Current state register
    always@(posedge clock)
    begin
      if(reset==1'b1)
      begin
         currentState <= S_IDLE;
      end
      else
         currentState <= nextState;
    end
endmodule


module GenerateLevelDatapath(
    input clock,
    input reset,

    input gen,
    input load,
    input moveIncr,
    
    output reg [4:0] moves,
    output reg regen,
    output wire [15:0] temp,
    output reg [15:0] oneHotCode,

    //For Storing to BRAM
    output reg [4:0] loadAddress,
    output reg [15:0] loadData,
    output reg loadWREN
    );

    wire [3:0] genNum;
    reg [15:0] prev;

    LFSR #(.SEED(64'd2854292432761329182)) PRNG(clock, reset, gen, genNum);
    DecToOneHot Conv(genNum, temp);

    always@(posedge clock)
    begin
        loadWREN <= 1'b0;
        if(reset)
        begin
            regen <= 1'b0;
            moves <= 5'b0;
        end
        else if(gen)
            if(temp==prev) //Need to regenerate
                regen <= 1'b1;
            else
                oneHotCode <= temp;
        else if(load)
        begin
            prev <= oneHotCode;
            loadAddress <= moves;
            loadData <= oneHotCode;
            loadWREN <= 1'b1; //Write
        end
        else if(moveIncr)
            moves <= moves+1'b1;
    end
endmodule
