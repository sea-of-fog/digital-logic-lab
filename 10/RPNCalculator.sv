// parameters are: operand width and stack size

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

// "empty" space in memory
module RPNCalculator#(parameter N = 16, M = 10)(
    output logic [N-1:0] out, output logic [M-1:0] cnt,
    input  nrst, step, push, input [1:0] op, input [N-1:0] d
);
// constants for opcodes
    const logic [1:0] NONE = 2'b00, NEG = 2'b01,
        ADD = 2'b10, MUL = 2'b11;

    logic [N-1:0] bot;

// cnt is the count amount of stack elements, so it points to the first
    // we only read when we need the second operand, so the read address is
    // always cnt - 1
    // similarly, we only write when pushing to the stack, and in that case
    // the write address is cnt
    AsyncRAM#(N, M) ar(bot, out, cnt - 1, cnt, push, step);

    always_ff @(posedge step or negedge nrst) begin
        if (!nrst) cnt <= 0;
        else if (push) cnt <= cnt + 1;
        else unique case (op)
            NONE: cnt <= cnt;
            NEG: cnt <= cnt;
            ADD: cnt <= cnt - 1;
            MUL: cnt <= cnt - 1;
        endcase
    end

    always_ff @(posedge step or negedge nrst) begin
        if (!nrst) out <= 0;
        else if (push) out <= d;
        else unique case (op)
            NONE: out <= out;
            NEG:  out <= -out;
            ADD:  out <= out + bot;
            MUL:  out <= out * bot;
        endcase
    end

endmodule
