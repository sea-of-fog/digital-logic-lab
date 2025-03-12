module two_or_three(output o, input [3:0] i);
    // two checks if two or more bits are fired
 	logic all, two;
  	assign all = &i;
    assign two =  (i[1] || i[2] || i[3])
               && (i[0] || i[2] || i[3])
               && (i[0] || i[1] || i[3])
               && (i[0] || i[1] || i[2]);
    assign o = !all && two;
    // Short argument that this is non-glitching (NG):
    // Fact 1.  The NOT of an NG circuit is NG.
    // Fact 2.  The AND of two NG circuits can happen
    //          only when switching from (0, 1) to (1, 0)
    //  The CNF formula for 'two' is nonglithing (by Karnaugh map),
    //  as is !all. Therefore, a glitch can happen iff the valuation
    //  of (two, all) changes between (1,1) and (0,0). That requires
    //  that at least three input bits change.
endmodule
