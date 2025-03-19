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

module nibble_adder(
    output [3:0] s, output c, 
    input  [3:0] a, b, input i
);
    logic [3:0] cs;
    full_adder fa0(s[0], cs[0], a[0], b[0], i);
    full_adder fa1(s[1], cs[1], a[1], b[1], cs[0]);
    full_adder fa2(s[2], cs[2], a[2], b[2], cs[1]);
    full_adder fa3(s[3], cs[3], a[3], b[3], cs[2]);
  	assign c = cs[3];
endmodule

module bcd_full_adder(
  output [3:0] s, output c,
  input  [3:0] a, b, input i
);
    logic [3:0] bit_sum, cor_sum;
    logic bit_c, dec_c;
    nibble_adder na1(bit_sum, bit_c, a, b, i);
  	assign dec_c = bit_sum[3] && bit_sum[2]
                || bit_sum[3] && bit_sum[1];
    assign c = bit_c || dec_c;
    // in both cases of overflow, adding 6 = (0110)_2 is the right correction
    // cor_sum = corrected_sum, and then we mux between the corrected and
    // original nibble sum
    nibble_adder na2(cor_sum, dummy_c, bit_sum, 4'b0110, 0);
    assign s = cor_sum &  {4{c}}
             | bit_sum & ~{4{c}};
endmodule

module bcd_inveter(
    output [3:0] o, 
    input  [3:0] d
);
    assign o[0] = !d[0];
    assign o[1] = d[1];
    assign o[2] = d[2] ^ d[1];
    assign o[3] = !(d[3] || d[2] || d[1]);
endmodule


module bcd_two_digit_adder(
    output [7:0] o,
    input  [7:0] a, b, input sub
);
    logic [7:0] binv;
    logic c;
    bcd_inverter bi0(binv[3:0], b[3:0], sub);
    bcd_inverter bi1(binv[7:4], b[7:4], sub);
    bcd_full_adder ba0(o[3:0], c, a[3:0], binv[3:0], sub);
    bcd_full_adder ba1(o[7:4], dummy_c, a[7:4], binv[7:4], c);
endmodule

// NOTES
/*  A bcd digit adder (with optional increment and carry) can
*   be implemented with a nibble adder and a decimal correction.
*
*   Overflow detection: BCD addition of two digits with possible increment
*   can give at most 19 as a result, so we don't have to worry about
*   difficulties with mult-digit carry. So, we have a decimal carry iff we
*   have a binary carry or the result is larger than 10 = (1010)_2.*/

