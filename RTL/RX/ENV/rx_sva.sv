`ifndef ALU_SVA_SV
`define ALU_SVA_SV

module ALU_SVA(
    input signed [31:0] A,
    input signed [31:0] B,
    input wire [4:0] shift_amt,
    input wire [3:0] AluControlout,
    input logic clk,
    input reg signed [31:0] Result,
    input reg overflow
);

    property overflow_and;
        @(posedge clk) (AluControlout == 2 && A[31] == B[31] && Result[31] != A[31]) |-> overflow == 1'b1; 
    endproperty
    assert1 : assert property(overflow_and);
    cover1 : cover property(overflow_and);
    property overflow_sub;
        @(posedge clk) (AluControlout == 6 && A[31] != B[31] && Result[31] != A[31]) |-> overflow == 1'b1; 
    endproperty
    assert2 : assert property(overflow_sub);
    cover2 : cover property(overflow_sub);
endmodule
`endif