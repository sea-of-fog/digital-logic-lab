module InsertSort(
    output [15:0] o, 
    input  [15:0] i
);
  	function [7:0] SwapCompare(input [3:0] a, b);
    	SwapCompare = a > b ? {a, b} : {b, a};
    endfunction
    integer k, l;
    logic [3:0] line [3:0];
    always_comb begin
        for (k = 0; k < 4; k = k + 1) line[k] = i[4*k +: 4]; 
        for (l = 1; l < 4; l = l + 1) begin
          for (k = l; k > 0; k = k - 1) {line[k], line[k-1]} = SwapCompare(line[k], line[k-1]);
        end
    end
  assign o = {line[3], line[2], line[1], line[0]};
endmodule
