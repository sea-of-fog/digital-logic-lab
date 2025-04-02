module FunnelShifter(
    output [7:0] o, 
    input  [7:0] a, b, input [3:0] n
);
    // the widths of the shift_k vector are calculated in reverse: if we need
    // 8 bits on the output (so, on shift 4), then we need 8 + 4 on the input
    // to "shifting by 4" etc.
    logic [14:0] ab = 15'({a,b});
    logic [13:0] shift1 = n[0] ? ab[14:1] : ab[13:0];
    logic [11:0] shift2 = n[1] ? shift1[13:2] : shift1[11:0];
    logic [7 :0] shift4 = n[2] ? shift2[11:4] : shift2[7:0];
    assign o = n[3] ? a : shift4;
endmodule

module GeneralShifter(
    output [7:0] o, 
    input  [7:0] i, input [3:0] n, input ar, lr, rot
);
    // It is easiest to see that these inputs work by drawing
    // a picture of what the funnel shifter will do for each combination of
    // rot/lr/ar.
    // These formulas were developed by conisdering each case separately and,
    // in some cases, consolidating.
    logic [7:0] a = (rot || lr)  ? i : (ar ? {8{i[7]}} : 0);
    logic [7:0] b = (rot || !lr) ? i : 8'b0;
    logic [3:0] in_n = lr ? 8 - n : n;
    FunnelShifter fs(o, a, b, in_n);
endmodule
