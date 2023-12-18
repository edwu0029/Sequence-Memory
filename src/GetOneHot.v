//Transforms Val to One Hot code
//Val = 0 -> 0001
//Val = 1 -> 0010
//Val = 2 -> 0100
//Val = 3 -> 1000
module GetOneHot(
    input [1:0] val,
    output reg [3:0] oneHot
);
    always@(*)
    begin
        oneHot <= (4'b1) << val;
    end
endmodule