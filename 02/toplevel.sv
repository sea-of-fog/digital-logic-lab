module two_or_three(output o, input [3:0] i);
    assign o =  (i[1]  || i[2] || i[3])
             && (i[0]  || i[2] || i[3])
             && (i[0]  || i[1] || i[3])
             && (i[0]  || i[1] || i[2])
  			 && |~i;
    /*
    Why does this solution not glitch?

    This is a CNF of the given boolean function. On the Karnaugh map,
    the zeroes of the function form two components. One of the corresponds
    to inputs with less then two bits on, and the other -- to the input
    with all bits on.

    A CNF can glitch only in the following way: if the outermost AND
    should stay at 0, but its inputs are temporarily all one and only 
    after a moment one of them falls down to 0.

    In either "component" of the CNF, a glitch cannot happen because
    of the Karnaugh map property ("intersecting groups"). So the only
    glitch that could happen would be when changing between components,
    but for that to happen at least three bits of the input have to change.
    */
endmodule
