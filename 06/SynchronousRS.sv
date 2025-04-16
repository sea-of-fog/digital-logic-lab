module GatedSRLatch(output q, nq, input s, r, en);
  logic r1, r2, s1;
  nor gq(q, r1, nq), gnq(nq, s1, q);
  and ar(r1, r, en), as(s1, s, en);
endmodule

// avoid the pitfall of oscillating in the "normal" SR latch, which happens
// when r = s = 1 and en goes from 1 to 0
// in general, an asynchronous SR Latch starts oscillating when 
module GatedSRSafeLatch(output q, nq, input s, r, en);
  logic r1, r2, s1;
  nor gq(q, r2, nq), gnq(nq, s1, q);
  and ar(r1, r, en), as(s1, s, en);
  and gt(r2, r1, ~s);
endmodule
