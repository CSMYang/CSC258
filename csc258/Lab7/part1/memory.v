module memory(SW, KEY, HEX);
	input [9:0] SW;
	input KEY[0];
	wire [3:0] dataOut;
	output [6:0] HEX0, HEX2, HEX4, HEX5;
	ram32x4 r0(.address(SW[8:4]),
						.clock(KEY[0]),
						.data(SW[3:0]),
						.wren(SW[9]),
						.q(dataOut[3:0]));
	decoder d0(.SW(SW[3:0]), .HEX(HEX2));
	decoder d1(.SW(dataOut[3:0]), .HEX(HEX0));
	decoder d2(.SW(SW[7:4]), .HEX(HEX4));
	decoder d3(.SW(3b'000, SW[8]), .HEX(HEX5));

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
