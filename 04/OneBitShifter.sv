module OneBitShifter(
    output [3:0] o, 
    input  [3:0] i, input l, input r
);
    // make L and R wide
    logic [3:0] L = {4{l}};
    logic [3:0] R = {4{r}};
    // extend i both ways
    logic [4:-1] I;
    assign I[3:0] = i[3:0];
    assign I[4]   = 0;
    assign I[-1]  = 0;
    assign o = ~L & ~R & I[3:0]
             |  L & I[2:-1]
             |  R & I[4:1];
endmodule
