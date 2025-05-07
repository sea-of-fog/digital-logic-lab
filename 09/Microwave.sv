module Microwave(
    output heat, light, bell, 
    input  door, start, finish, clk, nrst
);
    // This is a "clever" encoding of states to simplify the output function.
    // BELL is the only state in which we set the bell output, so it is
    // encoded as the only state with the 4 bit on
    // The light output is high in OPEN, COOK, PAUSE, so they are the nonzero
    // numbers, and COOK is encoded as 3, because it is the only state with
    // heat on
    
    const logic [2:0] CLOSED = 3'b000,
        OPEN = 3'b001, COOK = 3'b011,
        BELL = 3'b100, PAUSE = 3'b010;

    // Moore machine state
    logic [2:0] st;

    always_ff @ (posedge clk or negedge nrst) begin
        if (!nrst) st <= CLOSED;
        else unique case (st)
            CLOSED: if (door) st <= OPEN; else if (start) st <= COOK;
            OPEN: if (!door) st <= CLOSED;
            BELL: if (door) st <= OPEN;
            COOK: if (door) st <= PAUSE; else if (finish) st <= BELL;
            PAUSE: if (!door) st <= COOK;
        endcase
    end
    assign bell  = st[2];
    assign light = st[0] || st[1];
    assign heat  = st[0] && st[1];
endmodule
