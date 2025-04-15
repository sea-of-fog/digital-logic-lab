module Multiplier(
    output [7:0] o, 
    input  [7:0] i, input [2:0] fac
);
    logic [7:0] mul [1:0];
    assign mul[0] = fac[0] ? i : 8'b0;
    assign mul[1] = fac[1] ? i << 1 : 8'b0;
    assign o = fac[2] ? i << 2 : mul[1] + mul[0];
endmodule
