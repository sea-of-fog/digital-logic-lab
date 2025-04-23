// High ini means loading the number
// The module does not know when to stop computing -- the user should 
// set fin to high N + 1 cycles after ini
module TwosComplement#(parameter N = 4)(
    output logic [N-1:0] neg, 
  	input  [N-1:0] d, input ini, fin, clk
);
    logic carry;    
    always_ff @(posedge clk)
      	if (ini) neg <= d;
  		else if (fin) neg <= neg;
  		else neg <= {~neg[0] ^ carry, neg[N-1:1]};
    always_ff @(posedge clk)
        if (ini) carry <= 1;
        else carry <= carry && ~neg[0];
endmodule
