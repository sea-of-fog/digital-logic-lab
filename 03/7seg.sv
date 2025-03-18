module display(
    output top, mid, bot, l_top, l_bot, r_top, r_bot, 
    input [3:0] d
);
    assign r_top = (~d[2]) | (~d[1] & ~d[0]) | (d[1] & d[0]);
    assign r_bot = (~d[1]) | (d[0]) | (d[2]);
    assign l_top = (~d[1] & ~d[0]) | (d[2] & ~d[1]) | (d[2] & ~d[0]) | (d[3]);
    assign l_bot = (~d[0]) & (~d[2] | d[1]);
    assign top = (d[3] | d[2] | d[1] | ~d[0]) & (~d[2] | d[1] | d[0]);
    assign mid = (d[3] | d[2] | d[1]) & (~d[2] | ~d[1] | ~d[0]);
    assign bot = (d[3] | d[2] | d[1] | ~d[0]) & (~d[2] | d[1] | d[0]) & (~d[2] | ~d[1] | ~d[0]);
endmodule
