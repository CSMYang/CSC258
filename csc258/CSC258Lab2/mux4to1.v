//SW[2:0] data inputs
//SW[9] select signal

//LEDR[0] output display

module mux(LEDR, SW);
    input [9:0] SW;
    output [9:0] LEDR;

    mux4to1 u0(
        .u(SW[0]),
        .v(SW[1]),
        .w(SW[2]),
		  .x(SW[3]),
		  .s0(SW[8]),
		  .s1(SW[9]),
        .m(LEDR[0])
        );
endmodule

module mux2to1(x, y, s, m);
    input x; //selected when s is 0
    input y; //selected when s is 1
    input s; //select signal
    output m; //output
  
    assign m = s & y | ~s & x;
    // OR
    // assign m = s ? y : x;

endmodule


module mux4to1(u, v, w, x, s0, s1, m);
	input u, v, w, x, s0, s1;
	output m;
	wire uw_to_s0, vx_to_s0;
	mux2to1 m1(u, w, s1, uw_to_s0); // Creates a multiplexer connecting u and w by the switch s1.
	mux2to1 m2(v,x,s1, vx_to_s0); // Creates a multiplexer connecting v and x by switch s1.
	mux2to1 m3(uw_to_s0, vx_to_s0, s1, m);
endmodule
