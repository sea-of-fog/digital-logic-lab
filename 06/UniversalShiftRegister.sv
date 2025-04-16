// Rising-edge-enabled, transcribed from the lecture notes
module DFlipFlop(
    output q, nq, 
    input  clk, d
);
    logic n0, n1, n2, n3;
    // the first layer
    nand na0(n0, n1, n3), na1(n1, n0, clk), na2(n2, n1, clk, n3), na3(n3, n2, d);
    // the scond layer
    nand gq(q, nq, n1), gnq(nq, q, n2);
endmodule

// works by choosing the input signal for each flip-flop:
// d for parallel loading, the older flip-flop's out for left loading,
// the younger flip-flop for right loading, and itself for keeping the state
module UniversalShiftRegister(
    output [7:0] q, 
    input  i, c, l, r, input [7:0] d
);
    logic [7:0] in, nq;
    assign in = l ? (r ? d : {i, q[7:1]})
                  : (r ? {q[6:0], i} : q);
    for (genvar j = 0; j < 8; j = j + 1)
        DFlipFlop dff(q[j], nq[j], c, in[j]);
endmodule
