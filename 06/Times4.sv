module DFlipFlop(
    output q, nq, 
    input  clk, d, nset, nreset
);
    logic n0, n1, n2, n3;
    // the first layer
    nand na0(n0, n1, n3, nset), na1(n1, n0, clk, nreset), na2(n2, n1, clk, n3), na3(n3, n2, d, nreset);
    // the scond layer
    nand gq(q, nq, n1, nset), gnq(nq, q, n2, nreset);
endmodule

// sets and resets are neccessary -- otherwise there is no way to actually
// "start" the clock
module Times4(output clk_4, input clk, input [1:0] set);
  logic clk_2, feed_1, feed_2;
  DFlipFlop dff1(clk_2, feed_1, clk, feed_1, set[0], 1);
  DFlipFlop dff2(clk_4, feed_2, clk_2, feed_2, set[0], 1);
endmodule
