module two_or_three(output o, input [3:0] i);
 	logic all, any, one;
  	assign all = &i;
    assign any = |i;
    assign one =  i[0] && !(i[1] || i[2] || i[3])
               || i[1] && !(i[0] || i[2] || i[3])
               || i[2] && !(i[0] || i[1] || i[3])
               || i[3] && !(i[0] || i[1] || i[2]);
    assign o = any && !all && !one;
endmodule
