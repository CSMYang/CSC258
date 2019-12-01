module shifter(SW, LEDR, KEY);
	input[9:0] SW;
	input[3:0] KEY;
	output[7:0] LEDR;
	
	reg leftMost;
	always @(KEY[3])
	begin
		if (KEY[3] == 0)
			leftMost <= 0;
		else
			leftMost <= LEDR[0];
	end

	oneBitShifter s0(
		.load_val(SW[0]),
		.in(leftMost),
		.shift(KEY[2]),
		.load_n(KEY[1]),
		.clk(KEY[0]),
		.reset_n(SW[9]),
		.out(LEDR[0])
	);
	oneBitShifter s1(
		.load_val(SW[1]),
		.in(LEDR[0]),
		.shift(KEY[2]),
		.load_n(KEY[1]),
		.clk(KEY[0]),
		.reset_n(SW[9]),
		.out(LEDR[1])
	);
	oneBitShifter s2(
		.load_val(SW[2]),
		.in(LEDR[1]),
		.shift(KEY[2]),
		.load_n(KEY[1]),
		.clk(KEY[0]),
		.reset_n(SW[9]),
		.out(LEDR[2])
	);
	oneBitShifter s3(
		.load_val(SW[3]),
		.in(LEDR[2]),
		.shift(KEY[2]),
		.load_n(KEY[1]),
		.clk(KEY[0]),
		.reset_n(SW[9]),
		.out(LEDR[3])
	);
	oneBitShifter s4(
		.load_val(SW[4]),
		.in(LEDR[3]),
		.shift(KEY[2]),
		.load_n(KEY[1]),
		.clk(KEY[0]),
		.reset_n(SW[9]),
		.out(LEDR[4])
	);
	oneBitShifter s5(
		.load_val(SW[5]),
		.in(LEDR[4]),
		.shift(KEY[2]),
		.load_n(KEY[1]),
		.clk(KEY[0]),
		.reset_n(SW[9]),
		.out(LEDR[5])
	);
	oneBitShifter s6(
		.load_val(SW[6]),
		.in(LEDR[5]),
		.shift(KEY[2]),
		.load_n(KEY[1]),
		.clk(KEY[0]),
		.reset_n(SW[9]),
		.out(LEDR[6])
	);
	oneBitShifter s7(
		.load_val(SW[7]),
		.in(LEDR[6]),
		.shift(KEY[2]),
		.load_n(KEY[1]),
		.clk(KEY[0]),
		.reset_n(SW[9]),
		.out(LEDR[7])
	);

endmodule

module oneBitShifter(load_val, in, shift, load_n, clk, reset_n, out);
	input load_val, in, shift, load_n, clk, reset_n;
	output wire out;
	wire mux0to1;
	wire mux1tofl;
	mux2to1 mux0(.x(out), .y(in), .s(shift), .m(mux0to1));
	mux2to1 mux1(.x(load_val), .y(mux0to1), .s(load_n), .m(mux1tofl));
	flipflop fl(.d(mux1tofl), .clock(clk), .reset_n(reset_n), .q(out));
endmodule

module flipflop(d, clock, reset_n, q);
	input d;
	input clock;
	input reset_n;
	
	output reg q;

	always @(posedge clock) // Triggered every time clock rises
				// Note that clock is not a keyword
	begin
		if(reset_n == 1'b0) // When reset n is 0
				// Note this is tested on every rising
				// clock edge
			q <= 0; // Set q to 0
				// Note that the assignment uses <=
				// instead of =
		else		// When reset_n is not 0
			q <= d; //Store the value of d in q
	end
endmodule

module mux2to1(x, y, s, m);
	input x; //selected when s is 0
	input y; //selected when s is 1
	input s; // select signal
	output m; // output

	assign m = s & y | ~s & x;
endmodule