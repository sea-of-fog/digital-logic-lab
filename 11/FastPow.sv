// Parameters are widths of arguments and exponents
module FastPow#(X=16, N=8)(
    output [X-1:0] out, output ready, 
    input  [X-1:0] inx, input [N-1:0] inn, input clk, nrst, start
);

    const logic READY = 1, BUSY = 0; // automaton states
    logic st, even, zero;
    logic [X-1:0] x, a, mul;
    logic [N-1:0] n;

    assign even = !n[0];
    assign zero = !(|n);
    // using just one multiplier: both times we multiply one of the factors is
    // x, and the other one is x or a depending on the branch
  	assign mul  = x * (even ? x : a);

    always_ff @ (posedge clk or negedge nrst) begin
        if (!nrst) st <= READY;
        else begin unique case (st)
            READY: if (start) st <= BUSY;
            BUSY:  if (zero) st <= READY;
        endcase end
    end

    always_ff @ (posedge clk) begin
        case (st)
            READY: if (start) a <= 1; 
          	BUSY:  if (!zero && !even) a <= mul;
        endcase
    end

    always_ff @ (posedge clk) begin
        unique case (st)
            READY: if (start) x <= inx;
          	BUSY:  if (!zero && even) x <= mul;
        endcase
    end

    always_ff @ (posedge clk) begin
        unique case (st)
            READY: if (start) n <= inn;
            BUSY:  if (!zero) begin
              	if (even) n <= {1'b0, n[N-1:1]}; // this is a bitshift
              	else n <= {n[N-1:1], 1'b0}; // subtracting one from an odd number
                                            // is the same as setting the lowest bit to 0
            end
        endcase
    end

    assign out = a;
  	assign ready = st;
        
endmodule
