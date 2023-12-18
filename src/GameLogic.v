//50000000
module GameLogic #(parameter CLOCK_FREQUENCY = 50000000)(
    input clock,
    input reset,
    input start,

    input wire hasInput,
    input wire [3:0] inputOneHot,

    output wire [9:0] outputLIGHTS,
    output wire done,
    
    output wire [5:0] gameTime,
    output wire [2:0] moveNum,
    output wire [3:0] qSeq,
    output wire [5:0] qRes,
    output wire [3:0] statsLetter,
    output wire [7:0] statsDisplay
);
    wire generateDone, pulseAnimDone, generateStart, pulseAnimStart, moveIncr, levelStartAnimDone, levelStartAnimStart;
    wire goodInput, gameTimerStart, gameTimerDone, inputStart, goodAnimStart, goodAnimDone, badAnimStart, badAnimDone, levelIncr, levelDone;
    wire storeTime;
    wire statsInit, statsAvg;

    wire [3:0] level, maxLevel;

    wire [4:0] currentState;
    //Sequence Memory
    wire [1:0] userSeq;
    wire [4:0] addressSeq, address1Seq, address2Seq;
    wire [3:0] dataSeq, data1Seq;
    wire wrenSeq, wren1Seq, wren2Seq;

    //Results Memory
    wire [4:0] addressRes;
    wire [5:0] dataRes;
    wire wrenRes;

    GameLogicControl CGameLogic(
        .clock(clock),
        .reset(reset),
        .start(start),
        .level(level),
        .maxLevel(maxLevel),
        
        .moveNum(moveNum),
        .levelStartAnimDone(levelStartAnimDone),
        .generateDone(generateDone),
        .pulseAnimDone(pulseAnimDone),
        .hasInput(hasInput),
        .goodInput(goodInput),
        .gameTimerDone(gameTimerDone),
        .goodAnimDone(goodAnimDone),
        .badAnimDone(badAnimDone),

        .userSeq(userSeq),
        .levelStartAnimStart(levelStartAnimStart),
        .generateStart(generateStart),
        .pulseAnimStart(pulseAnimStart),
        .moveIncr(moveIncr),
        .gameTimerStart(gameTimerStart),
        .inputStart(inputStart),
        .goodAnimStart(goodAnimStart),
        .badAnimStart(badAnimStart),
        .storeTime(storeTime),
        .levelIncr(levelIncr),
        .levelDone(levelDone),
        .statsInit(statsInit),
        .statsAvg(statsAvg),
        .done(done),

        .currentState(currentState)
    );


    GameLogicDatapath #(.CLOCK_FREQUENCY(CLOCK_FREQUENCY)) DGameLogic(
        .clock(clock),
        .reset(reset),
        .start(start),

        .levelStartAnimStart(levelStartAnimStart),
        .generateStart(generateStart),
        .pulseAnimStart(pulseAnimStart),
        .moveIncr(moveIncr),
        .inputStart(inputStart),
        .goodAnimStart(goodAnimStart),
        .badAnimStart(badAnimStart),
        .storeTime(storeTime),
        .levelIncr(levelIncr),
        .gameTimerStart(gameTimerStart),
        .levelDone(levelDone),
        .statsInit(statsInit),
        .statsAvg(statsAvg),

        .inputOneHot(inputOneHot), // From player, to be replaced with keyboard TODO

        .level(level),
        .maxLevel(maxLevel),
        .levelStartAnimDone(levelStartAnimDone),
        .generateDone(generateDone),
        .pulseAnimDone(pulseAnimDone),
        .goodInput(goodInput),
        .goodAnimDone(goodAnimDone),
        .badAnimDone(badAnimDone),
        .gameTimerDone(gameTimerDone),

        .moveNum(moveNum),
        
        .address1Seq(address1Seq),
        .data1Seq(data1Seq),
        .wren1Seq(wren1Seq),
        .address2Seq(address2Seq),
        .wren2Seq(wren2Seq),
        .qSeq(qSeq),

        .addressRes(addressRes),
        .dataRes(dataRes),
        .wrenRes(wrenRes),
        .qRes(qRes),

        .LIGHTS(outputLIGHTS),
        .gameTime(gameTime),
        .statsLetter(statsLetter),
        .statsDisplay(statsDisplay)
    );

    MemoryAccessScheme MAS(
        .user(userSeq),

        .address1(address1Seq),
        .data1(data1Seq),
        .wren1(wren1Seq),

        .address2(address2Seq),
        .data2(4'd0), //Not used
        .wren2(wren2Seq),

        .address(addressSeq),
        .data(dataSeq),
        .wren(wrenSeq)
    );
    SequenceMemory RAM1(addressSeq, clock, dataSeq, wrenSeq, qSeq);
    ResultsMemory RAM2(addressRes, clock, dataRes, wrenRes, qRes);
endmodule

module GameLogicControl(
    input clock,
    input reset,
    input start,

    input [3:0] level,
    input [3:0] maxLevel,
    input [2:0] moveNum,
    input levelStartAnimDone,
    input generateDone,
    input pulseAnimDone,
    input hasInput, //Recieved input
    input goodInput, // 0 = Incorrect, 1 = Correct
    input gameTimerDone,
    input goodAnimDone,
    input badAnimDone,

    output reg [1:0] userSeq, //user for the sequence bram
    output reg levelStartAnimStart,
    output reg generateStart,
    output reg pulseAnimStart,
    output reg moveIncr,
    output reg gameTimerStart,
    output reg inputStart,
    output reg goodAnimStart,
    output reg badAnimStart,
    output reg storeTime,
    output reg levelIncr,
    output reg levelDone,
    output reg statsInit,
    output reg statsAvg,

    output reg done,

    output reg [4:0] currentState, nextState
);
    localparam  S_IDLE                  = 5'd1,
                //Level Start
                S_LEVEL_START_ANIM       = 5'd2,
                S_LEVEL_START_WAIT       = 5'd3,

                //Generate
                S_GENERATE              = 5'd4,
                S_WAIT_GEN              = 5'd5,

                //Display Sequence
                S_READ_MOVE             = 5'd6,
                S_DISPLAY               = 5'd7,
                S_WAIT_DISPLAY          = 5'd8,
                S_DISPLAY_NEXT          = 5'd9,

                //Getting inputs
                S_INPUTS_INIT           = 5'd10, //Init input stage of game
                S_WAIT_INPUT            = 5'd11,
                S_CHECK_INPUT           = 5'd12,
                S_GOOD_ANIM             = 5'd13,
                S_BAD_ANIM              = 5'd14,
                S_GOOD_ANIM_WAIT        = 5'd15,
                S_BAD_ANIM_WAIT         = 5'd16,
                S_NEXT_INPUT            = 5'd17,
                S_STORE_TIME            = 5'd18, //Store the time that the level ended
                S_NEXT_LEVEL            = 5'd19, //Storing Results of time

                //Display Stats
                S_STATS_INIT            = 5'd20,
                S_STATS_AVG             = 5'd21,
                S_STATS_AVG_WAIT        = 5'd22,
                S_DONE                  = 5'd25;
    
    // Next state logic aka our state table
    always@(*)
    begin
            case (currentState)
                S_IDLE: nextState = start ? S_LEVEL_START_ANIM : S_IDLE;
                S_LEVEL_START_ANIM: nextState = S_LEVEL_START_WAIT;
                S_LEVEL_START_WAIT: begin
                    if(levelStartAnimDone)
                        nextState = S_GENERATE;
                    else
                        nextState = S_LEVEL_START_WAIT;
                end
                S_GENERATE: nextState = S_WAIT_GEN;
                S_WAIT_GEN: begin
                    if(generateDone)
                        nextState = S_READ_MOVE;
                    else
                        nextState = S_WAIT_GEN;
                end
                S_READ_MOVE:begin
                    nextState = S_DISPLAY;
                end
                S_DISPLAY: begin
                    nextState = S_WAIT_DISPLAY;
                end
                S_WAIT_DISPLAY:begin
                    if(pulseAnimDone)
                        nextState = S_DISPLAY_NEXT;
                    else
                        nextState = S_WAIT_DISPLAY;
                end
                S_DISPLAY_NEXT:begin
                    if(moveNum < level)
                        nextState = S_READ_MOVE;
                    else
                        nextState = S_INPUTS_INIT;
                end
                S_INPUTS_INIT: begin
                    nextState = S_WAIT_INPUT;
                end
                S_WAIT_INPUT: begin
                    if(gameTimerDone) nextState = S_STATS_INIT;
                    else
                    if(hasInput)
                        nextState = S_CHECK_INPUT;
                    else
                        nextState = S_WAIT_INPUT;
                end
                S_CHECK_INPUT: begin
                    if(goodInput)
                        nextState = S_GOOD_ANIM;
                    else
                        nextState = S_BAD_ANIM;
                end
                S_GOOD_ANIM: begin
                    nextState = S_GOOD_ANIM_WAIT;
                end
                S_BAD_ANIM: begin
                    nextState = S_BAD_ANIM_WAIT;
                end
                S_GOOD_ANIM_WAIT: begin
                    if(goodAnimDone)
                        nextState = S_NEXT_INPUT;
                    else
                        nextState = S_GOOD_ANIM_WAIT;
                end
                S_BAD_ANIM_WAIT: begin
                    if(badAnimDone)
                        nextState = S_WAIT_INPUT;
                    else
                        nextState = S_BAD_ANIM_WAIT;
                end
                S_NEXT_INPUT: begin
                    if(moveNum<level)
                        nextState = S_WAIT_INPUT;
                    else
                        nextState = S_STORE_TIME;
                end
                S_STORE_TIME: begin
                    nextState = S_NEXT_LEVEL;
                end
                S_NEXT_LEVEL: begin
                    if(level<3'd7) //Max level is 7
                        nextState = S_LEVEL_START_ANIM;
                    else
                        nextState = S_STATS_INIT;
                end
                S_STATS_INIT: begin
                    nextState = S_STATS_AVG;
                end
                S_STATS_AVG: begin
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
        levelStartAnimStart <= 1'b0;
        generateStart <= 1'b0;
        pulseAnimStart <= 1'b0;
        moveIncr <= 1'b0;
        gameTimerStart <= 1'b0;
        inputStart <= 1'b0;
        goodAnimStart <= 1'b0;
        badAnimStart <= 1'b0;
        levelIncr <= 1'b0;
        levelDone <= 1'b0;
        storeTime <= 1'b0;
        statsInit <= 1'b0;
        statsAvg <= 1'b0;
        done <= 1'b0;
        case (currentState)
                S_IDLE:begin
                    // userSeq <= 2'd0;
                end
                S_LEVEL_START_ANIM: begin
                    userSeq <= 2'd1;
                    levelStartAnimStart <= 1'b1;
                end
                // Generate
                S_GENERATE:begin
                    userSeq <= 2'd1; //Writing for Generate
                    generateStart <= 1'b1;
                end
                S_WAIT_GEN:begin
                    
                end
                // Show Sequence
                S_READ_MOVE:begin
                    userSeq <= 2'd2; //Reading for display
                end
                S_DISPLAY: begin
                    pulseAnimStart <= 1'b1;
                end
                S_WAIT_DISPLAY:begin
                    
                end
                S_DISPLAY_NEXT:begin
                    moveIncr <= 1'b1;
                end

                //Get Inputs part
                S_INPUTS_INIT: begin
                    userSeq <= 2'd2; //Reading for checking
                    gameTimerStart <= 1'b1;
                    inputStart <= 1'b1;
                end
                S_WAIT_INPUT: begin
                end
                S_CHECK_INPUT: begin

                end
                S_GOOD_ANIM: begin
                    goodAnimStart <= 1'b1;
                end
                S_GOOD_ANIM_WAIT: begin
                    
                end
                S_BAD_ANIM: begin
                    badAnimStart <= 1'b1;
                end
                S_BAD_ANIM_WAIT: begin
                    
                end
                S_NEXT_INPUT: begin
                    moveIncr <= 1'b1;
                end
                S_STORE_TIME: begin
                    storeTime <= 1'b1;
                end
                S_NEXT_LEVEL: begin
                    levelDone <= 1'b1;
                    levelIncr <= 1'b1;
                end
                S_STATS_INIT: begin
                    statsInit <= 1'b1;
                end
                S_STATS_AVG: begin
                    statsAvg <= 1'b1;
                end



                S_DONE:begin
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

module GameLogicDatapath #(parameter CLOCK_FREQUENCY = 50000000) (
    input clock,
    input reset,
    input start,
    
    input wire levelStartAnimStart,
    input wire generateStart,
    input wire pulseAnimStart,
    input wire moveIncr,
    input wire inputStart,
    input wire goodAnimStart,
    input wire badAnimStart,
    input wire storeTime,
    input wire levelIncr,
    input gameTimerStart,
    input levelDone,
    input statsInit,
    input statsAvg,

    input wire [3:0] inputOneHot, //Input from player, one hot

    output reg [3:0] level,
    output reg [3:0] maxLevel,
    output wire levelStartAnimDone,
    output wire generateDone,
    output wire pulseAnimDone,
    output reg goodInput,
    output wire goodAnimDone,
    output wire badAnimDone,
    output wire gameTimerDone,

    output reg [2:0] moveNum,

    //Sequence Memory
    //Write
    output wire [4:0] address1Seq,
    output wire [3:0] data1Seq,
    output wire wren1Seq,

    //Read
    output reg [4:0] address2Seq,
    output reg wren2Seq,
    input wire [3:0] qSeq,

    //Results Memory
    //Write
    output reg [4:0] addressRes,
    output reg [3:0] dataRes,
    output reg wrenRes,
    input wire [5:0] qRes,


    output reg [9:0] LIGHTS,
    output reg [5:0] gameTime,
    output reg [3:0] statsLetter,
    output reg [5:0] statsDisplay
);
    reg levelStartAnimRunning, pulseAnimRunning, goodAnimRunning, badAnimRunning;

    wire [9:0] levelStartLIGHTS, pulseLIGHTS, goodAnimLIGHTS, badAnimLIGHTS;

    wire [5:0] gameTimerTime;
    always@(posedge clock)
    begin
        gameTime = 6'd20-gameTimerTime;
    end

    reg [8:0] totalTime, avg;
    always@(posedge clock)
    begin
        goodInput <= (qSeq==inputOneHot);
        address2Seq <= moveNum; //Address2 should always equal moveNum

        addressRes <= 5'd1;
        dataRes <= 5'd0;
        wrenRes <= 1'b0;
        if(start) begin
            moveNum <= 3'd0;
            level <= 4'd0;
            maxLevel <= 4'd0;
            address2Seq <= 5'd0;

            totalTime <= 8'd0;
            statsLetter <= 4'h0;
            statsDisplay <= 8'd0;
            
        end
        if(levelStartAnimStart) begin
            levelStartAnimRunning <= 1'b1;
            pulseAnimRunning <= 1'b0;
            goodAnimRunning <= 1'b0;
            badAnimRunning <= 1'b0;
        end
        else if(generateStart) begin
            moveNum <= 3'd0; //Reset moveNum for generate
        end
        else if(pulseAnimStart) begin
            levelStartAnimRunning <= 1'b0;
            pulseAnimRunning <= 1'b1;
            goodAnimRunning <= 1'b0;
            badAnimRunning <= 1'b0;
            wren2Seq <= 1'b0;
        end
        else if(moveIncr) begin
            moveNum <= moveNum + 3'd1;
        end
        // Input part of game
        else if(inputStart) begin
            moveNum <= 3'd0;
            wren2Seq <= 1'b0;
        end
        else if(goodAnimStart) begin
            levelStartAnimRunning <= 1'b0;
            pulseAnimRunning <= 1'b0;
            goodAnimRunning <= 1'b1;
            badAnimRunning <= 1'b0;
            wren2Seq <= 1'b0;
        end
        else if(badAnimStart) begin
            levelStartAnimRunning <= 1'b0;
            pulseAnimRunning <= 1'b0;
            goodAnimRunning <= 1'b0;
            badAnimRunning <= 1'b1;
            wren2Seq <= 1'b0;
        end
        else if(levelIncr) begin
            level <= level + 3'd1;
            maxLevel <= level + 3'd1;
            moveNum <= 3'd0;
            address2Seq <= 5'd0;
        end
        else if(storeTime) begin
            addressRes <= level;
            dataRes <= gameTimerTime;
            wrenRes <= 1'b1;
            totalTime <= totalTime + gameTimerTime;
        end
        else if(statsInit) begin
            level <= 3'd0;
            if(maxLevel==3'd0)
                avg <= 8'd0;
            else
                avg <= totalTime/maxLevel;
        end
        else if(statsAvg) begin
            statsLetter <= 4'hA;
            statsDisplay <= avg;
        end
    end

    always@(posedge clock)
    begin
        if(levelStartAnimRunning)
            LIGHTS <= levelStartLIGHTS;
        else if(pulseAnimRunning)
            LIGHTS <= pulseLIGHTS;
        else if(goodAnimRunning)
            LIGHTS <= goodAnimLIGHTS;
        else if(badAnimRunning)
            LIGHTS <= badAnimLIGHTS;
    end

    Timer #(.CLOCK_FREQUENCY(CLOCK_FREQUENCY)) gameTimer(
    .clock(clock),
    .reset(reset),
    .start(gameTimerStart),
    .stop(levelDone), //Stop when level is cleared
    .speed(2'd1), // 1 sec
    .maxTime(6'd20), //20 seconds per level

    .curTime(gameTimerTime),
    .done(gameTimerDone)
    );

    LevelStartAnim #(.CLOCK_FREQUENCY(CLOCK_FREQUENCY)) LSA(
        .clock(clock),
        .reset(rest),
        .start(levelStartAnimStart),

        .LIGHTS(levelStartLIGHTS),
        .done(levelStartAnimDone)
    );

    GenerateLevel GGGGG(
    .clock(clock),
    .reset(reset),
    .start(generateStart),
    .level(level),

    .done(generateDone),
    .addressS(address1Seq),
    .dataS(data1Seq),
    .wrenS(wren1Seq)
    );

    PulseAnim #(.CLOCK_FREQUENCY(CLOCK_FREQUENCY)) ShowSequence(
        .clock(clock),
        .reset(reset),
        .start(pulseAnimStart),

        .oneHot(qSeq),
        .LIGHTS(pulseLIGHTS),
        .done(pulseAnimDone)
    );
    PulseAnim #(.CLOCK_FREQUENCY(CLOCK_FREQUENCY)) GoodAnim(
        .clock(clock),
        .reset(reset),
        .start(goodAnimStart),

        .oneHot(qSeq),
        .LIGHTS(goodAnimLIGHTS),
        .done(goodAnimDone)
    );
    PulseAnim #(.CLOCK_FREQUENCY(CLOCK_FREQUENCY)) BadAnim(
        .clock(clock),
        .reset(reset),
        .start(badAnimStart),

        .oneHot(10'd1023), //Full lights on
        .LIGHTS(badAnimLIGHTS),
        .done(badAnimDone)
    );
endmodule