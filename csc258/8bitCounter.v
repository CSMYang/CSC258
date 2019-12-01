`timescale 1ns / 1ns

module eightBitCounter (SW, KEY, HEX0, HEX1);
	input [1:0] SW;
	input [1:0] KEY;
	output [6:0] HEX0, HEX1;
	wire [7:0] Q;
	wire f1_in, f2_in, f3_in, f4_in, f5_in, f6_in, f7_in;
	
	MyTFF f0 (
		.T(SW[1]),
		.Q(Q[0]),
		.clk(KEY[0]),
		.clear(SW[0])
	);
	
	and(f1_in, Q[0], SW[1]);
	
	MyTFF f1 (
		.T(f1_in),
		.Q(Q[1]),
		.clk(KEY[0]),
		.clear(SW[0])
	);
	
	and(f2_in, Q[1], f1_in);
	
	MyTFF f2 (
		.T(f2_in),
		.Q(Q[2]),
		.clk(KEY[0]),
		.clear(SW[0])
	);
	
	and(f3_in, Q[2], f2_in);
	
	MyTFF f3 (
		.T(f3_in),
		.Q(Q[3]),
		.clk(KEY[0]),
		.clear(SW[0])
	);
	
	and(f4_in, Q[3], f3_in);
	
	MyTFF f4 (
		.T(f4_in),
		.Q(Q[4]),
		.clk(KEY[0]),
		.clear(SW[0])
	);
	
	and(f5_in, Q[4], f4_in);
	
	MyTFF f5 (
		.T(f5_in),
		.Q(Q[5]),
		.clk(KEY[0]),
		.clear(SW[0])
	);
	
	and(f6_in, Q[5], f5_in);
	
	MyTFF f6 (
		.T(f6_in),
		.Q(Q[6]),
		.clk(KEY[0]),
		.clear(SW[0])
	);

	and(f7_in, Q[6], f6_in);
	
	MyTFF f7 (
		.T(f7_in),
		.Q(Q[7]),
		.clk(KEY[0]),
		.clear(SW[0])
	);
	
	decoder d0 (
		.SW(Q[7:4]),
		.HEX(HEX0[6:0])
	);
	
	decoder d1 (
		.SW(Q[3:0]),
		.HEX(HEX1[6:0])
	);
	
endmodule

module MyTFF (T, Q, clk, clear);
	input T, clk, clear;
	output Q;
	reg Q;
	
	always @(posedge clk, negedge clear)
	begin
		if (clear == 1'b0) 
			Q <= 1'b0;
		else
		begin
			if (T == 1'b1)
				Q <= ~Q;
			else
				Q <= Q;
		end
	end
endmodule

module decoder(SW,HEX);
	input [3:0]SW;
	output [6:0]HEX;
	assign HEX[0]=(~SW[3]&~SW[2]&~SW[1]&SW[0])|
		(~SW[3]&SW[2]&~SW[1]&~SW[0])|
		(SW[3]&SW[2]&~SW[1]&SW[0])|
		(SW[3]&~SW[2]&SW[1]&SW[0]);
	assign HEX[1]=(~SW[3]&SW[2]&~SW[1]&SW[0])|
		(SW[3]&SW[1]&SW[0])|
		(SW[3]&SW[2]&~SW[0])|
		(SW[2]&SW[1]&~SW[0]);
	assign HEX[2]=(~SW[3]&~SW[2]&SW[1]&~SW[0])|
		(SW[3]&SW[2]&~SW[0])|
		(SW[3]&SW[2]&SW[1]);
	assign HEX[3]=(~SW[3]&SW[2]&~SW[1]&~SW[0])|
		(~SW[2]&~SW[1]&SW[0])|
		(SW[2]&SW[1]&SW[0])|
		(SW[3]&~SW[2]&SW[1]&~SW[0]);
	assign HEX[4]=(~SW[3]&SW[2]&~SW[1])|
		(~SW[2]&~SW[1]&SW[0])|
		(~SW[3]&SW[0]);
	assign HEX[5]=(SW[3]&SW[2]&~SW[1]&SW[0])|
		(~SW[3]&~SW[2]&SW[0])|
		(~SW[3]&SW[1]&SW[0])|
		(~SW[3]&~SW[2]&SW[1]);
	assign HEX[6]=(~SW[3]& ~SW[2]& ~SW[1])|
		(SW[3]&SW[2]&~SW[1]&~SW[0])|
		(~SW[3]&SW[2]&SW[1]&SW[0]);
endmodule