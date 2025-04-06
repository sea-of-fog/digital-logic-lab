module NegToBCD(
    input  [3:0] i,
    output [3:0] o
);
    logic [3:0] i_plus  = {i[3:2], 2'b0};
    logic [3:0] i_minus = {2'b0, i[1:0]};
    assign o = i_plus - i_minus;
endmodule
