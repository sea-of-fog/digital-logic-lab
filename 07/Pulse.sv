module Pulse(
    output o, 
    input  s, clk
);
    logic [3:0] cnt;
    always_ff @(posedge clk)
      	if (s) cnt <= 4'b1100;
        else if (cnt != 0) cnt <= cnt - 1;
    assign o = |cnt;
endmodule
