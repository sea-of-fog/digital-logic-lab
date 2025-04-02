/* This is a sorting network based on Insertion Sort,
 * implemented according with the picture found in Wikipedia at:
 * https://en.wikipedia.org/wiki/Sorting_network#Insertion_and_Bubble_networks
 *
 * The variable line[i] is supposed to correspond to the i-th
 * line from the top in the schematic.
 *
 * Idea: in the l-th run of the loop, lines from 0 to l-1 are already sorted.
 * Since we want the lines to be sorted increasingly, we start the insetion
 * from the largest index.
 *
 * Insert Sort was chosed instead of the optimal network, because it has only
 * one comparator more, the same depth, scales to larger inputs and I could
 * practice writing for loops with it. */
module InsertSort(
    output [15:0] o, 
    input  [15:0] i
);
    /* The implementation of the comparator abstraction (in the sense of
    * sorting network theory). It takes two input lines and should be
    * understood as also producing two lines, switching them so that the first
    * is the larger one. 
    *
    * Usage: {max, min} = SwapCompare(a,b). */
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
