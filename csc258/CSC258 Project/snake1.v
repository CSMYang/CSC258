// Part 2 skeleton

module part2
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
		  UNKNOWN_INPUT // input from the keyboard
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
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
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;
	
	wire ld_x, ld_y, enable;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
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
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
    
    // Instansiate datapath
	 // datapath d0(...);


    // Instansiate FSM control
    // control c0(...);


    
endmodule

//datapath
module datapath(
    input clk,
    input resetn,
    input [7:0] x_in,
	 input [6:0] x_in,
    input [2:0] color_in, 
    input ld_x, ld_y,
    input enable, erase,
    output [7:0] x_out,
    output [6:0] y_out,
    output [2:0] color_out
    );
	
	 reg [1:0] xy_count
	 reg [7:0] x;
	 reg [6:0] y;
	 reg [2:0] color;
	 
	 always @ (posedge clk) begin
		if (!resetn) begin
			x <= 7'd80;
			y <= 6'd60;
			color <= 3'd111;
		end
		else begin
			if (ld_x)
				x <= x_in;
			if (ld_y) begin
				y <= y_in;
				color <= color_in;
			end
		end
	end
	
	always @ (posedge clk) begin
		if (!resetn) begin
			xy_count <= 2'd0;
		end
		else if (enable) begin
			if (xy_count == 2'b11)
				xy_count <= 2'b00;
			else
				xy_count <= xy_count + 1'b1;
		end
	end
	
	assign x_out = x + xy_count[0];
	assign y_out = y + xy_count[1];
	assign color_out = (erase) ? 3'd111 : color;

endmodule

//random generate x coordinate
module random_x_counter(
	input clk,
	input resetn,
	output [7:0] random_x
	)；
	
	reg [7:0] count;
	
	initial begin
		count = 8'd0;
	end
	
	always@(posedge clk) begin
		if (!resetn) begin
			count <= 8'd0;
		end
		else begin
			if (count == 8'd158)
				count <= 8'd0;
			else
				count <= count + 1'b1;
		end
	end
	
	assign random_x = count;

endmodule

//random genearate y coordinate
module random_y_counter(
	input clk,
	input resetn,
	output [6:0] random_y
	)；
	
	reg [6:0] count;
	
	initial begin
		count = 7'd0;
	end
	
	always@(posedge clk) begin
		if (!resetn) begin
			count <= 7'd0;
		end
		else begin
			if (count == 7'd118)
				count <= 7'd0;
			else
				count <= count + 1'b1;
		end
	end
	
	assign random_y = count;

endmodule

//control
module control(
	input clk, resetn,
	input up, down, left, right, start,
	output reg ld_x, ld_y, enable, erase, plot, restart,
	output reg [7:0] x,
	output reg [6:0] y,
	output reg [2:0] colour
	);
	
	reg [1:0] direction;
	reg [3:0] current_state, next_state;
	reg [14:0] snake[0:127];
	reg [2:0] frame_count;
	reg [23:0] delay_count;
	reg [14:0] restart_count;
	reg [6:0] length;
	
	integer index;
	
	localparam  START = 5'd0,
					DRAW_HEAD = 5'd1,
					DRAW_BODY1 = 5'd2,
					DRAW_BODY2 = 5'd3,
					DRAW_TAIL = 5'd4,
					DRAW_FOOD = 5'd5,
					WAIT = 5'd6,
					ERASE_TAIL = 5'd7,
					SHIFT = 5'd8,
					UPDATE_POSITION = 5'd9,
					UPDATE_POSITION1 = 5'd10,
					CHECK = 5'd11,
					UPDATE_HEAD = 5'd12,
					DELAY = 5'd13,
					RESTART = 5'd14,
			
	
	initial begin
		snake[0] = {8'd80, 7'd60};
		snake[1] = {8'd80, 7'd58};
		snake[2] = {8'd80, 7'd56};
		snake[3] = {8'd80, 7'd54};
		for (index = 4; index < 512; index = index +1) begin
			snake[index] = {8'd80, 7'd54};
		end
		collide = 0;
		length = 7'd4;
		direction = 2'b00;
		current_state = START;
		frame_count = 3'd0;
		delay_count = 24'd0;
		restart = 0;
	end
	
	always @(*)
		begin: states
			case (current_state)
				START: next_state = DRAW_HEAD;
				DRAW_HEAD: next_state = (frame_count == 3'd7) ? DRAW_BODY1 : DRAW_HEAD;
				DRAW_BODY1: next_state = (frame_count == 3'd7) ? DRAW_BODY2 : DRAW_BODY1;
				DRAW_BODY2: next_state = (frame_count == 3'd7) ? DRAW_TAIL : DRAW_BODY2;
				DRAW_TAIL: next_state = (frame_count == 3'd7) ? DRAW_FOOD : DRAW_TAIL;
				DRAW_FOOD: next_state = (frame_count == 3'd7) ? WAIT : DRAW_FOOD;
				WAIT: next_state = (start) ? ERASE_TAIL : WAIT;
				ERASE_TAIL: next_state = (frame_count == 3'd7) ? SHIFT : ERASE_TAIL;
				SHIFT: next_state = UPDATE_POSITION;
				UPDATE_POSITION: next_state = UPDATE_POSITION1;
				UPDATE_POSITION1: next_state = CHECK;
				CHECK: if (collide) 
							next_state = RESTART;
						 else 
							next_state = UPDATE_HEAD;
				UPDATE_HEAD: next_state = (frame_count == 3'd7) ?UPDATE_FOOD : UPDATE_HEAD;
				UPDATE_FOOD: next_state = (frame_count == 3'd7) ? DELAY : UPDATE_FOOD;
				DELAY: next_state = (delay_count == level_rate) ? ERASE_TAIL : DELAY;
				RESTART: next_state = (restart_count == 15'd20000) ? START: RESTART;
				default: next_state = DRAW_HEAD;
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
			if (current_state == UPDATE_POSITION)  
					begin
					case(direction)
						2'b00: if(snake[1][6:0] == 7'd0)
									collide = 1;
								 else
									snake[0] <= {snake[1][14:7], snake[1][6:0] - 7'd2};
						2'b01: if(snake[1][6:0] == 7'd118)
									collide = 1;
								 else
									snake[0] <= {snake[1][14:7], snake[1][6:0] + 7'd2};
						2'b10: if(snake[1][14:7] == 8'd0)
									collide = 1;
								 else
									snake[0] <= {snake[1][14:7] - 8'd2, snake[1][6:0]};
						2'b11: if(snake[1][14:7] == 8'd158)
									collide = 1;
								 else
									snake[0] <= {snake[1][14:7] + 8'd2, snake[1][6:0]};
					endcase
					end
			if (current_state == SHIFT) begin
				for (index = 0; index < 512; index = index + 1) begin
					snake[index + 1] <= snake[index];
				end
			end
			if (current_state == UPDATE_POSITION1) begin
				for (index = 1; index < length; index = index + 1) begin
					if (snake[index] == snake[0])
						collide = 1;
				end
			end
	
			if (current_state == RESTART) begin
						snake[0] = {8'd80, 7'd60};
						snake[1] = {8'd80, 7'd58};
						snake[2] = {8'd80, 7'd56};
						snake[3] = {8'd80, 7'd54};
						for (index = 4; index < 512; index = index +1) begin
							snake[index] = {8'd80, 7'd54};
						end
						collide = 0;
						length <= 7'd4;
						direction <= 2'b00;
				end
		end
	
	always@(*)
		begin: signals 
			ld_x = 1'b0;
			ld_y = 1'b0;
			erase = 1'b0;
			enable = 1'b0;
			plot = 1'b0;
			restart = 1'b0;
			
			case(current_state)
				START: begin
					colour <= 3'b010;
					end
					
				DRAW_HEAD: begin
					ld_x = 1'b1;
					ld_y = 1'b1;
					enable = 1'b1;
					plot = 1'b1;
					x_count <= snake[0][14:7];
					y_count <= snake[0][6:0];
					end
					
				DRAW_BODY1: begin
					ld_x = 1'b1;
					ld_y = 1'b1;
					enable = 1'b1;
					plot = 1'b1;
					x_count <= snake[1][14:7];
					y_count <= snake[1][6:0];
					end
					
				DRAW_BODY2: begin
					ld_x = 1'b1;
					ld_y = 1'b1;
					enable = 1'b1;
					plot = 1'b1;
					x_count <= snake[2][14:7];
					y_count <= snake[2][6:0];
					end
					
				DRAW_TAIL: begin
					ld_x = 1'b1;
					ld_y = 1'b1;
					enable = 1'b1;
					plot = 1'b1;
					x_count <= snake[3][14:7];
					y_count <= snake[3][6:0];
					end

				ERASE_TAIL: begin
					ld_x = 1'b1;
					ld_y = 1'b1;
					erase = 1'b1;
					enable = 1'b1;
					plot = 1'b1;
					x_count <= snake[length - 7'd1][14:7];
					y_count <= snake[length - 7'd1][6:0];
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

				RESTART: begin
					restart = 1'b1;
					plot = 1'b1;
					end
			endcase
		end	
		
	always@(posedge CLOCK_50)
		begin
			if(current_state == START)
				frame_count <= 3'd0;
			else if(current_state != START && current_state != WAIT && current_state != UPDATE_POSITION && 
						current_state != DELAY && current_state != SHIFT && current_state != UPDATE_POSITION1 && 
						current_state != CHECK)
				begin
					if (frame_count == 3'd7)
						frame_count <= 3'd0;
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
					if (delay_count == level_rate)
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
