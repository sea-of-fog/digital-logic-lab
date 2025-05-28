module RAM(
    output logic [7:0] dataout, 
    input [7:0] datain, input [2:0] read_addr, write_addr, input wr, clk
);
    logic [7:0] mem [2:0];
    always_ff @ (posedge clk) begin
        if (wr) mem[write_addr] <= datain;
    end
    always_ff @ (posedge clk) begin
        dataout <= mem[read_addr];
    end
endmodule

module Ctlpath(
    // Steering signals
    output ready, wr, i_set_zero, i_inc, j_set, j_inc, jm_set_i, jm_set_j,
    m_overwrite, c_set_d0, c_set_di, c_set_di1, c_set_dj1, write_addr_sel,
    // Status signals from the datapath
    input  i_full, j_full, c_lt_m, i_eq_jm,
    start, nrst, clk
);
    // automaton state encoding and transitions
    const logic [2:0] READY = 3'b100, OUTER = 3'b001,
        INNER = 3'b010, END = 3'b011, SWAP = 3'b000;
    logic [2:0] st;
    always_ff @ (posedge clk or negedge nrst) begin
        if (!nrst) st <= READY;
        else unique case (st)
            READY: if (start) st <= OUTER;
            OUTER: if (i_full) st <= READY; else st <= INNER;
            INNER: if (i_full) st <= END;
            END:   if (i_eq_jm) st <= OUTER; else st <= SWAP;
            SWAP:   st <= OUTER;
        endcase
    end

    assign ready = (st == READY);
    assign i_set_zero = (st == READY) && start;
    assign i_inc = (st == END) && i_eq_jm
                 || (st == SWAP);
    assign wr =  (st == END) && !i_eq_jm
              || (st == SWAP);
    assign m_overwrite =  (st == OUTER) && !i_full
                       || (st == INNER) && c_lt_m;
    assign j_set = (st == OUTER) && !i_full;
    assign j_inc = (st == INNER) && !c_lt_m && !j_full;
    assign jm_set_i = (st == INNER) && !i_full;
    assign jm_set_j = (st == INNER) && c_lt_m;
    assign c_set_d0 = (st == READY) && start;
    assign c_set_di = (st == INNER) && !c_lt_m && j_full;
    assign c_set_di1 = (st == END) && i_eq_jm || (st == SWAP) || (st == OUTER) && !i_full;
    assign c_set_dj1 = (st == INNER) && !c_lt_m && !j_full;
    assign write_addr_sel = (st == SWAP);
endmodule

module Datapath(
    // Status signals
    output i_full, j_full, c_lt_m, i_eq_jm,
    // Memory interface
    output logic [2:0] read_addr, write_addr,
    output [7:0] datain,
    input  [7:0] dataout,
    // Steering signals
    input i_set_zero, i_inc, j_set, j_inc, jm_set_i, jm_set_j, m_overwrite, c_set_d0, c_set_di, c_set_di1, c_set_dj1, write_addr_sel,
    clk
);

    logic [7:0] m, c;
    logic [2:0] i, j, jm, old_read_addr;

    assign c = dataout;

    always_ff @ (posedge clk) begin
        if (i_set_zero) i <= 3'b000;
        else if (i_inc) i <= i + 1;
    end

    always_ff @ (posedge clk) begin
        if (j_set) j <= i + 1;
        else if (j_inc) j <= j + 1;
    end

    always_ff @ (posedge clk) begin
        if (jm_set_i) jm <= i;
        else if (jm_set_j) jm <= j;
    end

    always_ff @ (posedge clk) begin
        if (m_overwrite) m <= c;
    end

    // Memory interface
    always_ff @ (posedge clk) begin
        if (c_set_d0) old_read_addr <= 0;
        else if (c_set_di) old_read_addr <= i;
        else if (c_set_di1) old_read_addr <= i + 1;
        else if (c_set_dj1) old_read_addr <= j + 1;
    end
    always_comb begin
        read_addr = old_read_addr;
        if (c_set_d0) read_addr = 0;
        else if (c_set_di) read_addr = i;
        else if (c_set_di1) read_addr = i + 1;
        else if (c_set_dj1) read_addr = j + 1;
    end
    assign write_addr = write_addr_sel ? i : jm;
    assign datain = write_addr_sel ? m : c;

    // Computing status signals
    assign i_full = (i == 7);
    assign j_full = (j == 7);
    assign c_lt_m = (c < m);
    assign i_eq_jm = (i == jm);

endmodule

// This module arbitrates the memory interface
module Arbiter(
    output wr, output [7:0] datain, output [2:0] read_addr, write_addr, 
    input  [7:0] out_datatin, in_datain,
    input [2:0] out_addr, in_read_addr, in_write_addr, 
    input out_wr, in_wr, ready
);
    assign wr = ready ? out_wr : in_wr;
    assign datain = ready ? out_datatin : in_datain;
    assign read_addr = ready ? out_addr : in_read_addr;
    assign write_addr = ready ? out_addr : in_write_addr;
endmodule

module SelectionSort(
    output [7:0] dataout, output ready, 
    input  [7:0] datain, input [2:0] addr, input wr, nrst, start, clk
);
    // Steering signals
    logic i_set_zero, i_inc, j_set, j_inc, jm_set_i, jm_set_j, m_overwrite, c_set_d0, c_set_di, c_set_di1, c_set_dj1, write_addr_sel;
    // Status signals
    logic i_full, j_full, c_lt_m, i_eq_jm;
    // Memory interface
    logic arbitrated_wr, internal_wr;
    logic [2:0] arbitrated_read_addr, arbitrated_write_addr,
                internal_read_addr, internal_write_addr;
    logic [7:0] arbitrated_datain, internal_datain;

    Ctlpath cp(
        // Steering signals 
        ready, internal_wr, i_set_zero, i_inc, j_set, j_inc, jm_set_i, jm_set_j,
        m_overwrite, c_set_d0, c_set_di, c_set_di1, c_set_dj1, write_addr_sel,
        // Status signals
        i_full, j_full, c_lt_m, i_eq_jm,
        start, nrst, clk);
    Datapath dp(
        // Status signals
        i_full, j_full, c_lt_m, i_eq_jm,
        //  Memory interface
        internal_read_addr, internal_write_addr,
        internal_datain,
        dataout,
        // Steering signals
        i_set_zero, i_inc, j_set, j_inc, jm_set_i, jm_set_j, m_overwrite, 
        c_set_d0, c_set_di, c_set_di1, c_set_dj1, write_addr_sel,
    clk);
    Arbiter arb(
        arbitrated_wr, arbitrated_datain, arbitrated_read_addr, arbitrated_write_addr,
        datain, internal_datain, addr, internal_read_addr, internal_write_addr, wr, internal_wr, ready);
    RAM memory(dataout, arbitrated_datain, arbitrated_read_addr, arbitrated_write_addr, arbitrated_wr, clk);
endmodule
