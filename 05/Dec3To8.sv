module Dec2To4(
    output [3:0] o, 
    input  [1:0] i, input en
);
    assign o[0] = en && ~i[1] && ~i[0];
    assign o[1] = en && ~i[1] &&  i[0];
    assign o[2] = en &&  i[1] && ~i[0];
    assign o[3] = en &&  i[1] &&  i[0];
endmodule

module Dec3To8(
    output [7:0] o, 
    input  [2:0] i
);
    Dec2To4 d0(o[3:0], i[1:0], ~i[2]);
    Dec2To4 d1(o[7:4], i[1:0],  i[2]);
endmodule
