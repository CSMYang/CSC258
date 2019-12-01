`timescale 1ns / 1ns

module HexCounter(SW, HEX0, CLOCK_50);
	input [3:0] SW;
	output [6:0] HEX0;
	input CLOCK_50;
	wire [27:0] rd0_out, rd1_out, rd2_out, rd3_out;
	reg Enable;
	wire [3:0] dc0_out;
	
	RateDivider rd00(CLOCK_50, rd0_out, SW[2], 1'b0, 28'b0000000000000000000000000000, SW[3]);
	RateDivider rd01(CLOCK_50, rd1_out, SW[2], 1'b1, 28'b0010111110101111000001111111, SW[3]);
	RateDivider rd10(CLOCK_50, rd2_out, SW[2], 1'b1, 28'b0101111101011110000011111111, SW[3]);
	RateDivider rd11(CLOCK_50, rd3_out, SW[2], 1'b1, 28'b1011111010111100000111111111, SW[3]);
	//RateDivider rd11(CLOCK_50, rd3_out, SW[2], 1'b1, 28'b0000000000000000000000000001, SW[3]);
	
	always @(*)
	begin
		case(SW[1:0])
			2'b00: Enable = (rd0_out == 28'b0000000000000000000000000000) ? 1'b1 : 1'b0;
			2'b01: Enable = (rd1_out == 28'b0000000000000000000000000000) ? 1'b1 : 1'b0;
			2'b10: Enable = (rd2_out == 28'b0000000000000000000000000000) ? 1'b1 : 1'b0;
			2'b11: Enable = (rd3_out == 28'b0000000000000000000000000000) ? 1'b1 : 1'b0;
			default: Enable = 1'b0;
		endcase
	end
	
	counterIncrementor IC(CLOCK_50, dc0_out, SW[2], Enable);
	decoder d0(dc0_out, HEX0);
endmodule

module RateDivider(clk, Q, clear, enable, d, ParLoad);
	input clk, enable, clear, ParLoad;
	input [27:0] d;
	output [27:0] Q;
	reg [27:0] Q;
	always @(posedge clk)
	begin
		if(clear == 1'b0)
			Q <= 0;
		else if(ParLoad == 1'b1)
			Q <= d;
		else if(Q == 28'b0000000000000000000000000000)
			Q <= d;
		else if(enable == 1'b1)
			Q <= Q - 1'b1;
		else if(enable == 1'b0)
			Q <= Q;
	end
endmodule

module counterIncrementor(clk, Q, clear, enable);
	input clk, enable, clear;
	output [3:0] Q;
	reg [3:0] Q;
	always @(posedge clk)
	begin
		if(clear == 1'b0)
			Q <= 0;
		else if(enable == 1'b1)
			Q <= Q + 1'b1;
		else if(enable == 1'b0)
			Q <= Q;
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
