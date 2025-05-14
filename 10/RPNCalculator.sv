// parameters are:
// N - operand width
// M - stack size

// RAM with an asynchronous read port and a synchronous write port
module AsyncRAM#(parameter N = 16, M = 10)(
    output [N-1:0] out, 
    input  [N-1:0] in, input [M-1:0] raddr, waddr, input wr, clk
);
    logic [N-1:0] mem [2**M - 1:0];
    assign out = mem[raddr];
    always_ff @(posedge clk)
        if (wr) mem[waddr] <= in;
endmodule

// UNDEFINED BEHAVIOUR: when pushing to full stack, applying unary minus on
// empty stack or any binary operation on a stack of size <= 1, neither cnt,
// out nor the memory state change
//
// Note that the stack is empty only until the first push, so out <= -out does
// not change the initial value of out, which is 0 (no if is needed)
module RPNCalculator#(parameter N = 16, M = 10)(
    output logic [N-1:0] out, output logic [M-1:0] cnt,
    input  nrst, step, push, input [1:0] op, input [N-1:0] d
);
    // constants for opcodes
    const logic [1:0] NONE = 2'b00, NEG = 2'b01,
        ADD = 2'b10, MUL = 2'b11;

    logic [N-1:0] bot; // second element from the top of the stack (first in memory)
    logic full = &cnt; // high iff the stack is full

    // cnt is the amount of stack elements, so there are (cnt - 1)
    // elements of the stack in memory (because we don't keep the top element in memory)
    //
    // we use the memory from index 1 -- mem[0] will be written to during the
    // first push and never read from, but this tiny wastefullness simplifies
    // the addressing logic (and we don't have to check for empty stack when
    // pushing)
    //
    // we only read when we need the second operand of a binary operation, 
    // so the read address is always cnt - 1
    //
    // similarly, we only write when pushing to the stack, and in that case
    // the write address is cnt
    AsyncRAM#(N, M) ar(bot, out, cnt - 1, cnt, push && !full, step);

    always_ff @(posedge step or negedge nrst) begin
        if (!nrst) cnt <= 0;
        else if (push) begin
            if (!full) cnt <= cnt + 1;
        end
        else unique case (op)
            ADD: cnt <= cnt - 1;
            MUL: cnt <= cnt - 1;
        endcase
    end

    always_ff @(posedge step or negedge nrst) begin
        if (!nrst) out <= 0;
        else if (push) out <= d;
        else unique case (op)
            NEG:  out <= -out;
            ADD:  if (cnt >= 2) out <= out + bot;
            MUL:  if (cnt >= 2) out <= out * bot;
        endcase
    end

endmodule
