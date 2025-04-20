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

// The implementation is based on two properties:
// 1. When incrementing a binary number, a given bit should be flipped iff all
//    previous bits are 1
// 2. When decrementing a binary numbe, a given bit should be flipped iff all
//    previous bits are 0
// These properties make it easy to implement an up/down counter using
// T flip-flops.
// 
// To handle the variable step, notice that increasing/decreasing a number 
// by 2 consists in:
// 1. Keeping the youngest bit constant
// 2. Incrementing/decrementing the number formed 
//    by all bits except the youngest
module Counter#(parameter N = 4)(
    output [N-1:0] out,
    input  nrst, step, down, clk
);
    logic [N-1:0] is_zero; // is_zero[N-1] purposefully ignored so as to not complicate the loop
    logic [N-2:0] all_ones, all_zeros;
  	logic [N-1:1] flip;
    TFlipFlop b0(out[0], is_zero[0], clk, ~step, 1'b1, nrst); 
    genvar i;
  	assign all_ones[0] = 1'b1;
  	assign all_zeros[0] = 1'b1;
    for (i = 1; i < N; i = i + 1) begin
        assign flip[i] = step ? (down ? all_zeros[i-1]               : all_ones[i-1])
                              : (down ? all_zeros[i-1] && is_zero[0] : all_ones[i-1] && out[0]);
        TFlipFlop tff(out[i], is_zero[i], clk, flip[i], 1'b1, nrst);
        if (i < N - 1) assign all_zeros[i] = all_zeros[i-1] && is_zero[i];
        if (i < N - 1) assign all_ones[i]  = all_ones[i-1]  && out[i];
    end
endmodule
