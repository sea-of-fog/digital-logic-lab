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
module UniversalShiftRegister#(parameter N = 8)(
    output [N-1:0] q, 
    input  i, c, l, r, input [N-1:0] d
);
    logic [N-1:0] in, nq;
    assign in = l ? (r ? d : {i, q[N-1:1]})
                  : (r ? {q[N-2:0], i} : q);
    for (genvar j = 0; j < N; j = j + 1)
        DFlipFlop dff(q[j], nq[j], c, in[j]);
endmodule
