module TwosComplement#(parameter N = 4)(
    output logic [N-1:0] neg, 
  	input  [N-1:0] d, input ini, fin, clk
);
    logic c;    
    always_ff @(posedge clk)
      	if (ini) neg <= d;
  		else if (fin) neg <= neg;
  		else neg <= {~neg[0] ^ c, neg[N-1:1]};
    always_ff @(posedge clk)
        if (ini) c <= 1;
        else c <= c && ~neg[0];
endmodule
