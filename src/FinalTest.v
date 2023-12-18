module FinalTest(
    input CLOCK_50,
    input [3:0] KEY,
    input [9:0] SW,

    output wire [9:0] LEDR,
    output wire [6:0] HEX0, HEX1, HEX2, HEX4, HEX5
);
    wire [3:0] moveNum, qSeq;
    wire [5:0] qRes;
    wire done;
    wire [5:0] gameTime;
    wire [4:0] address2;
    wire [3:0] statsLetter;
    wire [7:0] statsDisplay;
    GameLogic GLLLL(
        CLOCK_50,
        ~KEY[0],
        ~KEY[1],
        ~KEY[2],
        SW[3:0],
        LEDR[9:0],
        done,
        gameTime,
        moveNum,
		qSeq,
        qRes,
        statsLetter,
        statsDisplay,
    );
    DecimalDisplay D(
        gameTime, HEX4, HEX5
    );
    // DecimalDisplay D1(
    //     qSeq, HEX2, HEX3
    // );
    HexDecoder H0(statsLetter, HEX2);
    DecimalDisplay D2(
        statsDisplay, HEX0, HEX1
    );
endmodule