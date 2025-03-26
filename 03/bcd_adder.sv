module FullAdder(
        output s, c,
        input  a, b, c0 
);
    assign s = a ^ b ^ c0;
    assign c = a  && b
            || b  && c0 
            || c0 && a;
endmodule

module NibbleAdder(
    output [3:0] s, output c, 
    input  [3:0] a, b, input c0 
);
    logic [3:0] cs;
    FullAdder fa0(s[0], cs[0], a[0], b[0], c0);
    FullAdder fa1(s[1], cs[1], a[1], b[1], cs[0]);
    FullAdder fa2(s[2], cs[2], a[2], b[2], cs[1]);
    FullAdder fa3(s[3], cs[3], a[3], b[3], cs[2]);
  	assign c = cs[3];
endmodule

/*  NOTES
*
*   A bcd digit adder (with optional increment and carry) can
*   be implemented with a nibble adder and a decimal correction.
*
*   Carry detection: BCD addition of two digits with possible increment
*   can give at most 19 as a result, so we don't have to worry about
*   difficulties with mult-digit carry. So, we have a decimal carry iff we
*   have a binary carry (the result is larger than 15)
*   or the result fits in a nibble, but is than 9 = (1001)_2.
*
*   In both cases, the correction is to add 6 (which is -10 modulo 16!).
*   */
module BCDFullAdder(
  output [3:0] s, output c,
  input  [3:0] a, b, input c0 
);
    logic [3:0] bit_sum;
    logic bit_c;
    NibbleAdder na(bit_sum, bit_c, a, b, c0);
    assign c = bit_c
            || bit_sum[3] && bit_sum[2]
            || bit_sum[3] && bit_sum[1];
    // now adding 6 (when c is 1) or nothing (when c is 0)
    // These are formulas optimized by hand
    // Remember: overflow only possible for sums 10-19, which gives values 0-3,
    // 10-15 modulo 16
    assign s[0] = bit_sum[0];
    assign s[1] = bit_sum[1] ^ c;
    assign s[2] = (bit_sum[2] || c) && (bit_sum[2] || !bit_sum[1]) && (!bit_sum[2] || bit_sum[1] || !c);
    assign s[3] = (bit_sum[3] || c) && (bit_sum[1] || !c) && (!bit_sum[3] || !c);
endmodule

// the formulas in this module are hand-optimized
module BCDInverter(
    output [3:0] o, 
    input  [3:0] d, input sub
);
    assign o[0] = d[0] ^ sub;
    assign o[1] = d[1];
    assign o[2] = sub ? d[2] ^ d[1] : d[2];
    assign o[3] = sub ? !(d[3] || d[2] || d[1]) : d[3];
endmodule

module BCDTwoDigitAdder(
    output [7:0] o,
    input  [7:0] a, b, input sub
);
    logic [7:0] binv;
    logic c;
    BCDInverter bi0(binv[3:0], b[3:0], sub);
    BCDInverter bi1(binv[7:4], b[7:4], sub);
    BCDFullAdder ba0(o[3:0], c, a[3:0], binv[3:0], sub);
    BCDFullAdder ba1(o[7:4], , a[7:4], binv[7:4], c);
endmodule

