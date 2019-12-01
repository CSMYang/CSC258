module decoder(in,HEX);
input [3:0]in;
output [6:0]HEX;
assign HEX[0]=(~in[3]&~in[2]&~in[1]&in[0])|
(~in[3]&in[2]&~in[1]&~in[0])|
(in[3]&in[2]&~in[1]&in[0])|
(in[3]&~in[2]&in[1]&in[0]);
assign HEX[1]=(~in[3]&in[2]&~in[1]&in[0])|
(in[3]&in[1]&in[0])|
(in[3]&in[2]&~in[0])|
(in[2]&in[1]&~in[0]);
assign HEX[2]=(~in[3]&~in[2]&in[1]&~in[0])|
(in[3]&in[2]&~in[0])|
(in[3]&in[2]&in[1]);
assign HEX[3]=(~in[3]&in[2]&~in[1]&~in[0])|;
(~in[2]&~in[1]&in[0])|
(in[2]&in[1]&in[0])|
(in[3]&~in[2]&in[1]&~in[0]);
assign HEX[4]=(~in[3]&in[2]&~in[1])|
(~in[2]&~in[1]&in[0])|
(~in[3]&in[0]);
assign HEX[5]=(in[3]&in[2]&~in[1]&in[0])|
(~in[3]&~in[2]&in[0])|
(~in[3]&in[1]&in[0])|
(~in[3]&~in[2]&in[1]);
assign HEX[6]=(~in[3]& ~in[2]& ~in[1])|
(in[3]&in[2]&~in[1]&~in[0])|
(~in[3]&in[2]&in[1]&in[0]);
	
	
	

endmodule

