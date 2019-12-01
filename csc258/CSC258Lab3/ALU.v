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

module fullAdder(A, B, cin, S, cout);
	input A, B, cin;
	output S, cout;
	assign cout = ((A ^ B) &cin) | (A & B);
	assign S = A ^ B ^ cin;
endmodule

module fourBitAdder(SW, LEDR);
	input [7:0] SW;
	output [4:0] LEDR;
	wire FA1to2, FA2to3, FA3to4;
	fullAdder FA1(SW[7], SW[3], 1'b0, LEDR[3], FA1to2);
	fullAdder FA2(SW[6], SW[2], FA1to2, LEDR[2], FA2to3);
	fullAdder FA3(SW[5], SW[1], FA2to3, LEDR[1], FA3to4);
	fullAdder FA4(SW[4], SW[0], FA3to4, LEDR[0], LEDR[4]);
endmodule 

module ALU(SW, KEY, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
	input [7:0] SW;
	input [2:0] KEY;
	output [7:0] LEDR;
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	wire f0sum, f0out, f1sum, f1out, f2sum, f2out, f3sum, f3out;
	wire [4:0] fbaOut;
	reg [7:0] ALUout;
	decoder d0(.SW(SW[3:0]), .HEX(HEX0[6:0]));
	decoder d1(.SW(4'b0000), .HEX(HEX1[6:0]));
	decoder d2(.SW(SW[7:4]), .HEX(HEX2[6:0]));
	decoder d3(.SW(4'b0000), .HEX(HEX3[6:0]));
	fullAdder f0(SW[4], 1'b1, 1'b0, f0sum, f0out);
	fullAdder f1(SW[5], 1'b0, f0out, f1sum, f1out);
	fullAdder f2(SW[6], 1'b0, f1out, f2sum, f2out);
	fullAdder f3(SW[7], 1'b0, f2out, f3sum, f3out);
	fourBitAdder fba(.SW(SW), .LEDR(fbaOut[4:0]));
	always @(*)
	begin
		case (KEY[2:0])
			3'b111: ALUout = {3'b000, f3out, f3sum, f2sum, f1sum};
			3'b110: ALUout = {3'b000, fbaOut[4], fbaOut[3:0]};
			3'b101: ALUout = {4'b0000, SW[7:4] + SW[3:0]};
			3'b100: ALUout = {SW[7:4]|SW[3:0], SW[7:4] ^ SW[3:0]};
			3'b011: ALUout = {7'b0000000, SW[0]|SW[1]|SW[2]|SW[3]|SW[4]|SW[5]|SW[6]|SW[7]};
			3'b010: ALUout = {SW[7:4], SW[3:0]};
			default: ALUout = 8'b00000000;
		endcase
	end
	assign LEDR = ALUout;
	decoder d4(.SW(ALUout[3:0]), .HEX(HEX4[6:0]));
	decoder d5(.SW(ALUout[7:4]), .HEX(HEX5[6:0]));
endmodule 