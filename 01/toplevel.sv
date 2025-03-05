module select(output o, input a, b, c, d, x, y);
    assign o = a & ~x & ~y
      		 | b & ~x &  y
      		 | c &  x & ~y
      		 | d &  x &  y;
endmodule
