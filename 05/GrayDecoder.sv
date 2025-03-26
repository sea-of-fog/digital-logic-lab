module GrayDecoder(output [31:0] o, input [31:0] i);
    logic [31:0] step;
  	integer k;
    always_comb begin
        step = i;
        for (k = 4; k >= 0; k = k - 1) begin
            step = step ^ (step >> 2**k);
  		end
    end
    assign o = step;
endmodule
