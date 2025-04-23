// T flip-flop with asynchronous set and reset
// The set and reset pins are negated!
// State changes on the rising clock edge
// Implemented as a D flip-flop with additional logic
module TFlipFlop(
    output q, nq, 
    input  clk, t, nset, nreset
);
    logic d = t ^ q;
    logic n0, n1, n2, n3;
    // the first layer
    nand na0(n0, n1, n3, nset), na1(n1, n0, clk, nreset), na2(n2, n1, clk, n3), na3(n3, n2, d, nreset);
    // the second layer
    nand gq(q, nq, n1, nset), gnq(nq, q, n2, nreset);
endmodule

module LoadCounter#(parameter N=3)(
    output [N-1:0] q, 
    input  [N-1:0] d, input load, clk, nrst
);
    logic [N-2:0] all_ones;
    assign all_ones[0] = q[0];
    TFlipFlop tff(q[0], , clk, load ? d[0] : 1'b1, 1, nrst);
    genvar j;
    for (j = 1; j < N; j = j + 1) begin
        TFlipFlop tff(q[j], , clk, load ? d[j] ^ q[j] : all_ones[j-1], 1, nrst);
        if (j < N - 1) assign all_ones[j] = all_ones[j-1] && q[j];
    end
endmodule
