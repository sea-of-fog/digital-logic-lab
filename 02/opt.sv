module two_or_three(output o, input [3:0] i);
 	logic all, two;
  	assign all = &i;
  	assign two =  i[0] && i[1]
               || i[0] && i[2]
               || i[0] && i[3]
               || i[1] && i[2]
               || i[1] && i[3]
               || i[2] && i[3];
  	assign o = two && !all;
endmodule
