module GrayDecoder(output [31:0] o, input [31:0] i);
    logic [31:0] step;
  	integer k;
    always_comb begin
        step = i;
        for (k = 0; k < 5; k = k + 1) begin
            step = step ^ (step >> 2**k);
  		end
    end
    assign o = step;
endmodule
/* This almost implements a formula given in the lecture for the inverse Gray coding,
 * but the shift values are in reverse. I like this version better, because
 * it is easier to see what it does.
 *
 * A short proof can be given by writing the encoded number as
 * x = a_n (a_n ^ a_{n-1}) (a_{n-1} ^ a_{n-2}) ... (a_1 ^ a_0),
 * where a_i are the digits of the encoded number.
 *
 * Denoting f_k(x) := x ^ (x >> 2^k), we have that
 * G(x) = f_0(x) (proof in the excercises),
 * and, by induction, f_k (f_k(x)) = f_{k+1} (x).
 *
 * So, f_4 (f_3 ( ... f_0 (G(x))) =
 *     f_4 (f_3 ( ... f_0 (f_0(x)))) =
 *     f_4 (f_3 ( ... f_1(x) )) =
 *     = ... = f_5(x) = x,
 *     since x >> 2^5 = 0.
 */
