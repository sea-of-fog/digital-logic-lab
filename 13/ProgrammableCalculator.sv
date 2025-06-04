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
    output logic signed [N-1:0] out, output logic [M-1:0] cnt,
    input  en, nrst, clk, push, input [2:0] op, input [N-1:0] d
);
    // constants for opcodes
    const logic [2:0] GREATER = 3'b000, NEG = 3'b001,
        ADD = 3'b010, MUL = 3'b011, SWAP = 3'b100,
        LOAD = 3'b101, POPA = 3'b110, POPB = 3'b111;

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
    logic wr = push && !full & (cnt > 0) || (op == SWAP);
    logic [M-1:0] mem_raddr = (op == LOAD) ? cnt - 1 - out[M-1:0] : cnt - 1;
    logic [M-1:0] mem_waddr = (op == SWAP) && !push ? cnt - 1 : cnt;
    AsyncRAM#(N, M) ar(bot, out, mem_raddr, mem_waddr, wr && en, clk);

    always_ff @(posedge clk or negedge nrst) begin
        if (!nrst) cnt <= 0;
        else if (en) begin
            if (push) begin
                if (!full) cnt <= cnt + 1;
            end
            else unique case (op)
                ADD: cnt <= cnt - 1;
                MUL: cnt <= cnt - 1;
                POPA: cnt <= cnt - 1;
                POPB: cnt <= cnt - 1;
            endcase
        end
    end
  
  	logic signed [N-1:0] signed_zero = {N{1'b0}};

    always_ff @(posedge clk or negedge nrst) begin
        if (!nrst) out <= 0;
        else if (en) begin
            if (push) out <= d;
            else unique case (op)
              	GREATER: out <= (out > signed_zero);
                NEG:  out <= -out;
                ADD:  if (cnt >= 2) out <= out + bot;
                MUL:  if (cnt >= 2) out <= out * bot;
                SWAP: if (cnt >= 2) out <= bot;
                LOAD: out <= bot;
                POPA: out <= bot;
                POPB: out <= bot;
            endcase
        end
    end

endmodule

module SteeringModule#(parameter N = 16, M = 10)(
    output [N-1:0] out, output ready, 
    input  [N-1:0] datain, input [M-1:0] addr, input start, wr, nrst, clk
);

    logic [M-1:0] pc;
    logic [N-1:0] insn;

    AsyncRAM#(N, M) code(insn, datain, pc, addr, ready && !start && wr, clk);

    logic st;
    const logic READY = 1, BUSY = 0;

    logic pc_inc, pc_overwrite, finish;
  	assign finish = insn[N-1] && insn[N-2];
  	assign pc_overwrite = insn[N-1] && !insn[N-2] && &insn[2:0];
  	assign pc_inc = !finish && !pc_overwrite;

    always_ff @ (posedge clk or negedge nrst) begin
        if (!nrst) st <= READY;
        else unique case (st)
            READY: if (start) st <= BUSY;
            BUSY:  if (finish) st <= READY;
        endcase
    end

    always_ff @ (posedge clk or negedge nrst) begin
        if (!nrst) pc <= 0;
        else unique case (st)
            READY: if (start) pc <= 0;
            BUSY:  if (pc_inc) pc <= pc + 1;
                   else if (pc_overwrite) pc <= out[M-1:0];
      endcase
    end

    logic en = !ready && !finish;
    logic push = !ready && !insn[N-1];

    // TODO: actually implement en
    RPNCalculator#(N, M) calc(out, , en, nrst, clk, push, insn[2:0], insn);
    assign ready = (st == READY);

endmodule
