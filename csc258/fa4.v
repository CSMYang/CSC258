module fullAdder(A, B, cin, S, cout);
	input A, B, cin;
	output S, cout;
	assign cout = ((A ^ B) &cin) | (A & B);
	assign S = A ^ B ^ cin;
endmodule

module fourBitAdder(SW, LEDR);
	input [8:0] SW;
	output [4:0] LEDR;
	wire FA1to2, FA2to3, FA3to4;
	fullAdder FA1(SW[7], SW[3], SW[8], LEDR[3], FA1to2);
	fullAdder FA2(SW[6], SW[2], FA1to2, LEDR[2], FA2to3);
	fullAdder FA3(SW[5], SW[1], FA2to3, LEDR[1], FA3to4);
	fullAdder FA4(SW[4], SW[0], FA3to4, LEDR[0], LEDR[4]);
endmodule 
