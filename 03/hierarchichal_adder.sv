// Longest input-output paths (unspecified = no path between given I/O pair)
//
// p_i       -> P    1
// p_{1,2,3} -> G    2
// g_i       -> G    2
// c0        -> c_i  2 (or 0 for i = 0)
// g_i       -> c_j  2 for j > i, 0 otherwise
// p_i       -> c_j  2 for j > i,  0 otherwise

module CarryLookahead(
    output [3:0] c, output G, P,
    input  [3:0] g, p, input c0
);
    assign c[0] = c0;
    assign c[1] = g[0] 
               || p[0] && c0;
    assign c[2] = g[1] 
               || p[1] && g[0] 
               || p[1] && p[0] && c0;
    assign c[3] = g[2] 
               || p[2] && g[1] 
               || p[2] && p[1] && g[0] 
               || p[2] && p[1] && p[0] && c0;
    assign G = g[3] 
            || p[3] && g[2] 
            || p[3] && p[2] && g[1] 
            || p[3] && p[2] && p[1] && g[0];
    assign P = &p;
endmodule

// Longest input-output paths
// c_0      -> s_i  3 (1 for i = 0)
// a_i, b_i -> P    3
// a_i, b_i -> G    3 (apart from i = 0, then no path)
// a_i, b_i -> s_j  1 for j = i, 3 for j > i
module NibbleAdder(
    output [3:0] s, output G, P,
    input  [3:0] a, b, input c0
);
    logic [3:0] p, g, c;
    assign p = a | b;
    assign g = a & b;
    CarryLookahead cl(c, G, P, g, p, c0);
    assign s = a ^ b ^ c;
endmodule

// Calculating paths gets complicated here.
// Observation: in the nibble adder, G and P do not depend on c0!
// Any input nibble only influences more significant output nibbles and only
// throught the carry, but because we use CarryLookahead, the length of the
// path is always 3
// The longest path is from any nibble to any more significant
// output nibble through the carry-lookahead, i.e.
// a[4i+3, 4i] -> G_i -> c_j -> o[4j+3, 4j] (length 3 + 2 + 3 = 8)
module HierarchichalAdder(
    output [15:0] o,
    input  [15:0] a, b
);
    logic [3:0] G, P, c;
    CarryLookahead cl(c, dummy_G, dummy_P, G, P, 0);
    NibbleAdder na0(o[3:0], G[0], P[0], a[3:0], b[3:0], c[0]);
    NibbleAdder na1(o[7:4], G[1], P[1], a[7:4], b[7:4], c[1]);
    NibbleAdder na2(o[11:8], G[2], P[2], a[11:8], b[11:8], c[2]);
    NibbleAdder na3(o[15:12], G[3], P[3], a[15:12], b[15:12], c[3]);
endmodule

// Warning: this circuit is not in fact cyclic, because in CarryLookahead
// c_i is calculated using only G_j, P_j for j < i!
