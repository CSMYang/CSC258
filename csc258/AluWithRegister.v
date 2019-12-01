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

module register(d, clock, reset_n, q);
	input [7:0] d;
	input clock;
	input reset_n;
	output reg [7:0] q;

	always @(posedge clock)
	begin
		if (reset_n == 1'b0)
			q <= 0;
		else
			q <= d;
	end
endmodule

module fourBitAdder(A, B, cin, S, cout);
	input [3:0] A;
	input [3:0] B;
	input cin;
	output [3:0] S;
	output cout;
	
	wire [2:0] con;
	
	fullAdder f0(.A(A[0]), .B(B[0]), .cin(cin),.S(S[0]), .cout(con[0]));
	fullAdder f1(.A(A[1]), .B(B[1]), .cin(con[0]), .S(S[1]), .cout(con[1]));
	fullAdder f2(.A(A[2]), .B(B[2]), .cin(con[1]), .S(S[2]), .cout(con[2]));
	fullAdder f3(.A(A[3]), .B(B[3]), .cin(con[2]), .S(S[3]), .cout(cout));
endmodule

module AluWithRegister(SW, KEY, LEDR, HEX0, HEX4, HEX5);
	input [9:0] SW;
	input [1:0] KEY;
	output [7:0] LEDR;
	output [6:0] HEX0, HEX4, HEX5;
	reg [7:0] ALUout;
	wire [3:0] r;
   wire [3:0] addA1;
	wire addA2;
	fourBitAdder add1(.A(SW[3:0]), .B(4'b0001), .cin(1'b0), .S(addA1), .cout(addA2));
	wire [3:0] ab1;
	wire ab2;
	fourBitAdder add2(.A(SW[3:0]), .B(r[3:0]), .cin(1'b0), .S(ab1), .cout(ab2));
	register reg0(.d(ALUout), .clock(KEY[0]), .reset_n(SW[9]), .q(r));
	always @(*)
	begin
		case (SW[7:5])
			3'b111: ALUout = {8'b00000000, addA2, addA1};
			3'b110: ALUout = {8'b00000000, ab2, ab1};
			3'b101: ALUout = {8'b00000000, (SW[3:0] + r[3:0])};
			3'b100: ALUout = {8'b00000000, SW[3:0] | r[3:0], SW[3:0] ^ r[3:0]};
			3'b011: ALUout = {8'b00000000, SW[0] | SW[1] | SW[2] | SW[3] | r[3] | r[2] | r[1] | r[0]};
			3'b010: ALUout = {8'b00000000, (r[3:0] << SW[3:0])};
			3'b001: ALUout = {8'b00000000, (r[3:0] >> SW[3:0])};
			3'b000: ALUout = {8'b00000000, (SW[3:0] * r[3:0])};
			default: ALUout = 8'b00000000;
		endcase
	end
	assign LEDR = ALUout;
	decoder d0(.SW(SW[3:0]), .HEX(HEX0[6:0]));
	decoder d4(.SW(ALUout[3:0]), .HEX(HEX4[6:0]));
	decoder d5(.SW(ALUout[7:4]), .HEX(HEX5[6:0]));
endmodule 