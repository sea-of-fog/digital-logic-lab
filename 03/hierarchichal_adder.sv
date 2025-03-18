// the i input parameter is for "increment", i.e. a carry incoming from
// previous positions
module full_adder(
        output s, c,
        input  a, b, i
);
    assign s = a ^ b ^ i;
    assign c = a && b
            || b && i
            || i && a;
endmodule

// this is a slightly different nibble adder, it includes the propagation bit
module nibble_adder(
    output [3:0] s, output g, p, 
    input  [3:0] a, b, input i
);
    logic [3:0] cs;
    full_adder fa0(s[0], cs[0], a[0], b[0], i);
    full_adder fa1(s[1], cs[1], a[1], b[1], cs[0]);
    full_adder fa2(s[2], cs[2], a[2], b[2], cs[1]);
    full_adder fa3(s[3], cs[3], a[3], b[3], cs[2]);
  	assign c = cs[3];
endmodule

module twobyte_adder(
    output [15:0] o,
    input  [15:0] a, b
);
    assign o = {16{1}};
endmodule
