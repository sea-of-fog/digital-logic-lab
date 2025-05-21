// Parameter: number width
module datapath#(N = 8)(
  	output [N-1:0] out, output eq, gt,
  	input  [N-1:0] ina, inb, input load, swap, sub, clk
);
    logic [N-1:0] a, b;

    always_ff @ (posedge clk) begin
        if (load) a <= ina;
        else if (swap) a <= b;
      	else if (sub) a <= a - b;
    end

    always_ff @ (posedge clk) begin
        if (load) b <= inb;
        else if (swap) b <= a;
    end

    assign eq = (a == b);
    assign gt = (a < b);
    assign out = a;

endmodule

module ctlpath(
    output logic ready, load, swap, sub,
    input  start, clk, nrst, eq, gt
);
   
    const logic READY = 1, BUSY = 0;
    logic st;

    always_ff @ (posedge clk or negedge nrst) begin
      	if (!nrst) st <= READY;
        else begin unique case (st)
            READY: if (start) st <= BUSY;
            BUSY:  if (eq) st <= READY;
        endcase end
    end

	assign ready = st;
    assign load = ready && start;
    assign swap = !eq && gt;
  	assign sub =  !eq && !gt;
  
endmodule

// Parameter: number width
module GCD#(N = 8)(
    output [N-1:0] out, output ready, 
    input  [N-1:0] ina, inb, input start, clk, nrst
);
    // steering signals for the datapath tell us whether to load, swap or
    // subtract those numbers. the status signals are comparison results
    logic load, swap, sub, eq, gt;
  	datapath#(N) dp(out, eq, gt, ina, inb, load, swap, sub, clk);
  	ctlpath ctl(ready, load, swap, sub, start, clk, nrst, eq, gt);
endmodule
