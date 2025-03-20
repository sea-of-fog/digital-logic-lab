module FunnelShifter(
    output [7:0] o, 
    input  [7:0] a, b, input [3:0] n
);
    logic [15:0] ab = {a,b};
    logic [13:0] shift1 = n[0] ? ab[14:1] : ab[13:0];
    logic [11:0] shift2 = n[1] ? shift1[13:2] : shift1[11:0];
    logic [7:0]  shift4 = n[2] ? shift2[11:4] : shift2[7:0];
    assign o = n[3] ? a : shift4;
endmodule

module GeneralShifter(
    output [7:0] o, 
    input  [7:0] i, input [3:0] n, input ar, lr, rot
);
    logic [7:0] a = (rot || lr) ? i : (ar ? {8{i[7]}} : 0);
    logic [7:0] b = (rot || !lr) ? i : 0;
    logic [3:0] in_n = lr ? 8 - n : n;
    FunnelShifter fs(o, a, b, in_n);
endmodule
