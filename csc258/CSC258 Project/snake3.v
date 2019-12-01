// Part 2 skeleton

module snake
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
      SW,
		KEY,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B,   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(~SW[9]),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";

		
	combination u0(.CLOCK_50(CLOCK_50),
						.resetn(~SW[9]),
						.rate(SW[1:0]),
						.up(~KEY[3]),
						.down(~KEY[2]),
						.left(~KEY[1]),
						.right(~KEY[0]),
						.x_out(x),
						.y_out(y),
						.colour_out(colour),
						.plot(writeEn)
						);
    

endmodule


//combine
module combination(CLOCK_50, resetn, rate, up, down, left, right, x_out, y_out, colour_out, plot);
	input CLOCK_50, resetn, up, down, left, right;
	input [1:0]rate;
	wire [7:0]x_in;
	wire [6:0]y_in;
	wire [2:0]colour_in;
	wire ld_x, ld_y, erase, draw;
	wire [7:0]data_x;
	wire [6:0]data_y;
	wire [2:0]data_colour;
	wire [7:0]restart_x;
	wire [6:0]restart_y;
	wire [2:0]restart_colour;
	wire restart;
	reg [23:0]rate_rate;
	output [7:0]x_out;
	output [6:0]y_out;
	output [2:0]colour_out;
	output plot;
	
	always@(*)
		begin
			case(rate)
				2'b00: rate_rate <= 24'd15000000;
				2'b01: rate_rate <= 24'd10000000;
				2'b10: rate_rate <= 24'd7500000;
				2'b11: rate_rate <= 24'd5000000;
				default: rate_rate <= 24'd15000000;
			endcase
		end				

	control u0(
				 .CLOCK_50(CLOCK_50),
				 .resetn(resetn), 
				 .up(up), 
				 .down(down), 
				 .left(left), 
				 .right(right),
				 .x_count(x_in), 
				 .y_count(y_in), 
				 .colour(colour_in), 
				 .ld_x(ld_x), 
				 .ld_y(ld_y), 
				 .erase(erase), 
				 .draw(draw), 
				 .plot(plot),
				 .restart(restart),
				 .rate_rate(rate_rate),
				 );
	
	
				 
	datapath u1(
					.x_in(x_in), 
					.y_in(y_in), 
					.colour_in(colour_in), 
					.clock(CLOCK_50), 
					.resetn(resetn), 
					.ld_x(ld_x), 
					.ld_y(ld_y), 
					.draw(draw), 
					.erase(erase), 
					.x_out(data_x), 
					.y_out(data_y), 
					.colour_out(data_colour)
					);

					
	restart u2(
				  .resetn(resetn), 
				  .clock(CLOCK_50), 
				  .x_out(restart_x), 
				  .y_out(restart_y), 
				  .colour_out(restart_colour)
				  );
				  
	assign colour_out = (restart) ? restart_colour : data_colour;
	assign x_out = (restart) ? restart_x : data_x;
	assign y_out = (restart) ? restart_y : data_y;
endmodule

//datapath
module datapath(x_in, y_in, colour_in, clock, resetn, ld_x, ld_y, draw, erase, x_out, y_out, colour_out);
	input [7:0]x_in;
	input [6:0]y_in;
	input [2:0]colour_in;
	input clock, resetn, ld_x, ld_y, draw, erase;
	output [7:0]x_out;
	output [6:0]y_out;
	output [2:0]colour_out;
	reg [1:0]count;
	initial begin
		count = 2'b00;
		end
	
	assign x_out = x_in + count[0];
	assign y_out = y_in + count[1];
	assign colour_out = (draw) ? colour_in : 3'b000;
	
		
	always@(posedge clock)
		begin
			if(!resetn)
				count <= 2'b00;
			else if(draw || erase)
				begin
					if(count == 2'b11)
						count <= 2'b00;
					else
						count <= count + 1'b1;
				end
		end
endmodule



//control
module control(CLOCK_50,resetn, up, down, left, draw, right, x_count, y_count, colour, ld_x, ld_y, erase, plot, restart, rate_rate);
	input CLOCK_50, resetn, up, down, left, right;
	input [23:0]rate_rate;
	output reg [7:0]x_count;
	output reg [6:0]y_count;
	output reg ld_x, ld_y, erase, plot, restart, draw;
	output reg [2:0] colour;
	
	reg [1:0]direction; //up:00, down:01, left:10, right:11
	reg [3:0]current_state, next_state;
	
	reg [14:0] snake[0:127]; //stores postions for the snake, it 
	reg [6:0] length;
	reg [3:0] frame_count;
	reg [23:0] delay_count;
	reg [14:0] restart_count;
	reg collision,eat;
	reg [14:0] apple;
	
	wire [7:0] random_x;
	wire [6:0] random_y;
	wire [7:0] random_apple_x;
	wire [6:0] random_apple_y;

	integer index;
	
//	assign random_apple_x = {random_x, 2'b00};
//	assign random_apple_y = {random_y, 2'b00};
	assign random_apple_x = random_x;
	assign random_apple_y = random_y;

	
	random_x_counter u0(
							 .clock(CLOCK_50),
							 .resetn(resetn),
							 .random_x(random_x)
							 );
	random_y_counter u1(
							 .clock(CLOCK_50),
							 .resetn(resetn),
							 .random_y(random_y)
							 );
	
	localparam  START = 5'd0,
					DRAWH = 5'd1,
					DRAWB1 = 5'd2,
					DRAWB2 = 5'd3,
					DRAWT = 5'd4,
					WAIT = 5'd5,
					ET = 5'd6,
					SHIFT = 5'd7,
					UPDATEP1 = 5'd8,
					UPDATEP2 = 5'd9,
					CHECK = 5'd10,
					UPDATE_HEAD = 5'd11,
					DELAY = 5'd12,
					RESTART = 5'd13,
					DRAWA = 5'd14,
					DRAWS = 5'd15,
					DRAWS2 = 5'd16,
					DRAWS3 = 5'd17,
					DRAWNEWH = 5'd18,
					DRAWNEWB1 = 5'd19,
					DRAWNEWB2 = 5'd20,
					DRAWNEWT = 5'd21,
					UPDATE_APPLE = 5'd22;
					
					
					
	initial begin
		snake[0] = {8'd80, 7'd30};
		snake[1] = {8'd80, 7'd32};
		snake[2] = {8'd80, 7'd34};
		snake[3] = {8'd80, 7'd36};
		for (index = 4; index < 128; index = index +1) begin
			snake[index] = {8'd80, 7'd36};
		end
		collision = 0;
		length = 7'd4;
		direction = 2'b00;  // r_direction 
		current_state = START;
		frame_count = 4'b0;
		delay_count = 24'b0;
		restart = 0;
		eat = 0;
		apple = {8'd100, 7'd100};
	end
	
	
	always @(*)
		begin: states
			case (current_state)
				START: next_state = DRAWH;
				DRAWH: next_state = (frame_count == 4'd12) ? DRAWB1 : DRAWH;
				DRAWB1: next_state = (frame_count == 4'd12) ? DRAWB2 : DRAWB1;
				DRAWB2: next_state = (frame_count == 4'd12) ? DRAWT : DRAWB2;
				DRAWT: next_state = (frame_count == 4'd12) ? DRAWS : DRAWT;
				DRAWS: next_state = (frame_count == 4'd12) ? DRAWS2 : DRAWS;
				DRAWS2: next_state = (frame_count == 4'd12) ? DRAWS3 : DRAWS2;
				DRAWS3: next_state = (frame_count == 4'd12) ? DRAWA : DRAWS3;
				DRAWA: next_state = (frame_count == 4'd12) ? WAIT : DRAWA;
				WAIT: next_state = (|{up, down, left, right}) ? ET : WAIT;
				ET: next_state = (frame_count == 4'd12) ? SHIFT : ET;
				SHIFT: next_state = UPDATEP1;
				UPDATEP1: next_state = UPDATEP2;
				UPDATEP2: next_state = CHECK;
				CHECK: if (collision) 
							next_state = RESTART;
						else if(eat)
							next_state = DRAWNEWH;
						 else 
							next_state = UPDATE_HEAD;
				DRAWNEWH: next_state = (frame_count == 4'd12) ? DRAWNEWB1 : DRAWNEWH;
				DRAWNEWB1: next_state = (frame_count == 4'd12) ? DRAWNEWB2 : DRAWNEWB1;
				DRAWNEWB2: next_state = (frame_count == 4'd12) ? DRAWNEWT : DRAWNEWB2;
				DRAWNEWT: next_state = (frame_count == 4'd12) ?  UPDATE_HEAD: DRAWNEWT;

							
				UPDATE_HEAD: next_state = (frame_count == 4'd12) ? UPDATE_APPLE : UPDATE_HEAD;
				
				UPDATE_APPLE: next_state = (frame_count == 4'd12) ? DELAY : UPDATE_APPLE;
		
				DELAY: next_state = (delay_count == rate_rate) ? ET : DELAY;
				
				RESTART: next_state = (restart_count == 15'd20000) ? START: RESTART;
				default: next_state = DRAWH;
			endcase
		end
	
		always@(posedge CLOCK_50)
		begin
			if(up && direction != 2'b01) 
				direction <= 2'b00;
			else if(down && direction != 2'b00)
				direction <= 2'b01;
			else if(left && direction != 2'b11)
				direction <= 2'b10;
			else if(right && direction != 2'b10)
				direction <= 2'b11;
			if (current_state == UPDATEP1)  
					begin
					case(direction)
						2'b00: if(snake[1][6:0] == 7'd0)
									collision = 1;
								 else
									snake[0] <= {snake[1][14:7], snake[1][6:0] - 7'd2};
						2'b01: if(snake[1][6:0] == 7'd118)
									collision = 1;
								 else
									snake[0] <= {snake[1][14:7], snake[1][6:0] + 7'd2};
						2'b10: if(snake[1][14:7] == 8'd4)
									collision = 1;
								 else
									snake[0] <= {snake[1][14:7] - 8'd2, snake[1][6:0]};
						2'b11: if(snake[1][14:7] == 8'd158)
									collision = 1;
								 else
									snake[0] <= {snake[1][14:7] + 8'd2, snake[1][6:0]};
					endcase
					end
			if (current_state == SHIFT) begin
				for (index = 0; index < 126; index = index + 1) begin
					snake[index + 1] <= snake[index];
				end
			end
			if (current_state == UPDATEP2) begin
				for (index = 1; index < length; index = index + 1) begin
					if (snake[index] == snake[0])
						collision = 1;
				end
				if (snake[0] == {8'd30, 7'd40} || snake[0] == {8'd80, 7'd40} || snake[0] == {8'd90, 7'd60})
					collision = 1;
				if (snake[0]  == apple) begin
					eat = 1;
					length <= length + 7'd4;
					apple <= {random_apple_x, random_apple_y};
				end
			end
			
			if (current_state == DRAWNH)
				eat = 0;
		
			if (current_state == RESTART) begin
						snake[0] = {8'd80, 7'd30};
						snake[1] = {8'd80, 7'd32};
						snake[2] = {8'd80, 7'd34};
						snake[3] = {8'd80, 7'd36};
			for (index = 4; index < 128; index = index +1) begin
				snake[index] = {8'd80, 7'd36};
			end
						collision = 0;
						direction <= 2'b00;
						apple <= {8'd100, 7'd100};
						eat = 0;
						length <= 7'd4;
				end
		end
	
	always@(*)
		begin: signals 
			ld_x = 1'b0;
			ld_y = 1'b0;
			erase = 1'b0;
			draw = 1'b0;
			plot = 1'b0;
			restart = 1'b0;
			
			case(current_state)
				START: begin
					colour <= 3'b010;
					end
					
				DRAWH: begin
					ld_x = 1'b1;
					ld_y = 1'b1;
					draw = 1'b1;
					plot = 1'b1;
					x_count <= snake[0][14:7];
					y_count <= snake[0][6:0];
					end
					
				DRAWB1: begin
					ld_x = 1'b1;
					ld_y = 1'b1;
					draw = 1'b1;
					plot = 1'b1;
					x_count <= snake[1][14:7];
					y_count <= snake[1][6:0];
					end
					
				DRAWB2: begin
					ld_x = 1'b1;
					ld_y = 1'b1;
					draw = 1'b1;
					plot = 1'b1;
					x_count <= snake[2][14:7];
					y_count <= snake[2][6:0];
					end
					
				DRAWT: begin
					ld_x = 1'b1;
					ld_y = 1'b1;
					draw = 1'b1;
					plot = 1'b1;
					x_count <= snake[3][14:7];
					y_count <= snake[3][6:0];
					end
				
				DRAWA: begin
					ld_x = 1'b1;
					ld_y = 1'b1;
					draw = 1'b1;
					plot = 1'b1;
					x_count <= apple[14:7];
					y_count <= apple[6:0];
					colour <= 3'b100;
					end
				
				DRAWS1: begin
					ld_x = 1'b1;
					ld_y = 1'b1;
					draw = 1'b1;
					plot = 1'b1;
					x_count <= 8'd30;
					y_count <= 7'd40;
					colour <= 3'b111;
					end
			
				DRAWS2: begin
					ld_x = 1'b1;
					ld_y = 1'b1;
					draw = 1'b1;
					plot = 1'b1;
					x_count <= 8'd80;
					y_count <= 7'd40;
					colour <= 3'b111;
					end

				DRAWS3: begin
					ld_x = 1'b1;
					ld_y = 1'b1;
					draw = 1'b1;
					plot = 1'b1;
					x_count <= 8'd90;
					y_count <= 7'd60;
					colour <= 3'b111;
					end
					
//				DRAWS4: begin
//					ld_x = 1'b1;
//					ld_y = 1'b1;
//					draw = 1'b1;
//					plot = 1'b1;
//					x_count <= 8'd30;
//					y_count <= 7'd40;
//					colour <= 3'b111;
//					end
					
				ET: begin
					ld_x = 1'b1;
					ld_y = 1'b1;
					erase = 1'b1;
					plot = 1'b1;
					x_count <= snake[length - 7'd1][14:7];
					y_count <= snake[length - 7'd1][6:0];
					end
				
				DRAWNH: begin
					ld_x = 1'b1;
					ld_y = 1'b1;
					draw = 1'b1;
					plot = 1'b1;
					x_count <= snake[length - 7'd4][14:7];
					y_count <= snake[length - 7'd4][6:0];
					colour <= 3'b010;
					end
					
				DRAWNB1: begin
					ld_x = 1'b1;
					ld_y = 1'b1;
					draw = 1'b1;
					plot = 1'b1;
					x_count <= snake[length - 7'd3][14:7];
					y_count <= snake[length - 7'd3][6:0];
					colour <= 3'b010;
					end
					
				DRAWNB2: begin
					ld_x = 1'b1;
					ld_y = 1'b1;
					draw = 1'b1;
					plot = 1'b1;
					x_count <= snake[length - 7'd2][14:7];
					y_count <= snake[length - 7'd2][6:0];
					colour <= 3'b010;
					end
					
				DRAWNT: begin
					ld_x = 1'b1;
					ld_y = 1'b1;
					draw = 1'b1;
					plot = 1'b1;
					x_count <= snake[length - 7'd1][14:7];
					y_count <= snake[length - 7'd1][6:0];
					colour <= 3'b010;
					end
			
				UPDATE_HEAD: begin
					ld_x = 1'b1;
					ld_y = 1'b1;
					draw = 1'b1;
					plot = 1'b1;
					x_count <= snake[0][14:7];
					y_count <= snake[0][6:0];
					colour <= 3'b010;
					end
				
				UPDATE_APPLE: begin
					ld_x = 1'b1;
					ld_y = 1'b1;
					draw = 1'b1;
					plot = 1'b1;
					x_count <= apple[14:7];
					y_count <= apple[6:0];
					colour <= 3'b100;
					end
				
				RESTART: begin
					restart = 1'b1;
					plot = 1'b1;
					end
			endcase
		end	
		
	always@(posedge CLOCK_50)
		begin
			if(current_state == START)
				frame_count <= 4'd0;
			else if(current_state != START && current_state != WAIT && current_state != UPDATEP1 && 
						current_state != DELAY && current_state != SHIFT && current_state != UPDATEP2 && 
						current_state != CHECK)
				begin
					if (frame_count == 4'd12)
						frame_count <= 4'd0;
					else
						frame_count <= frame_count + 1'd1;
				end
		end
	
	always@(posedge CLOCK_50)
		begin
			if(current_state == START)
				delay_count <= 24'd0;
			else if(current_state == DELAY)
				begin
					if (delay_count == rate_rate)
						delay_count <= 24'd0;
					else
						delay_count <= delay_count + 1'd1;
				end
		end
		
		
	always@(posedge CLOCK_50)
		begin
			if(current_state == START)
				restart_count <= 15'd0;
			else if(current_state == RESTART)
				begin
					if (restart_count == 15'd20000)
						restart_count <= 15'd0;
					else
						restart_count <= restart_count + 1'd1;
				end
		end
	
	always @(posedge CLOCK_50)
		begin 
        if(!resetn)
            current_state <= START;
        else
            current_state <= next_state;
		end 
	
endmodule

//restart
module restart(resetn, clock, x_out, y_out, colour_out);
	input resetn, clock;
	output [7:0]x_out;
	output [6:0]y_out;
	output [2:0]colour_out;
	reg [7:0]x_count;
	reg [6:0]y_count;
	initial
		begin
			x_count = 8'd0;
			y_count = 7'd0;
		end
	
	always@(posedge clock)
		begin
			if(!resetn)
				x_count <= 8'd0;
			else
				begin
					if(x_count == 8'd160)
						x_count <= 8'd0;
					else
						x_count <= x_count + 8'd1;
				end
		end
		
	always@(posedge clock)
		begin
			if(!resetn)
				y_count <= 7'd0;
			else
				begin
					if(y_count == 7'd120)
						y_count <= 7'd0;
					else if(x_count == 8'd0)
						y_count <= y_count + 7'd1;
				end
		end
		
	assign x_out = x_count;
	assign y_out = y_count;
	assign colour_out = 3'b000;
endmodule

//random_x,y_counter
module random_x_counter(clock, resetn, random_x);
	input clock;
	input resetn;
	output [7:0]random_x;
	reg [7:0]count;
	initial begin
		count = 8'd0;
		end
	always@(posedge clock)
		begin
		if (!resetn)
			count <= 8'd0;
		else 
			begin
				if (count == 8'd160)
					count <= 8'd0;
			else
				count <= count + 1'd1;
			end
		end
	assign random_x = count;
endmodule

module random_y_counter(clock, resetn, random_y);
	input clock;
	input resetn;
	output [6:0]random_y ;
	reg [6:0]count;
	initial begin
		count = 7'd0;
		end
	always@(posedge clock)
		begin 
		if (!resetn)
			count <= 7'd0;
		else
			begin
				if (count == 7'd120)
					count <= 7'd0;
				else
					count <= count + 1'd1;
			end
		end
	assign random_y = count;
endmodule
