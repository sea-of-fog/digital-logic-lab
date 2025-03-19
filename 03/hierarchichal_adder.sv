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
