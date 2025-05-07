module PulseWidthModulator(
    output logic [15:0] cnt, cmp, top, output logic out, 
    input  [15:0] d, input [1:0] sel, input clk
);
    always_ff @(posedge clk)
        if (sel == 2'b01) cmp <= d;
    always_ff @(posedge clk)
        if (sel == 2'b10) top <= d;
    always_ff @(posedge clk)
        if (sel == 2'b11) cnt <= d;
        else if (cnt >= top) cnt <= 16'b0;
        else cnt <= cnt + 1; 
    assign out = cnt < cmp;
endmodule
