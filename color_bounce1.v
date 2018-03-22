// Part 2 skeleton

module color_bounce1
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
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
	
	//wire resetn;
	//assign resetn = KEY[0];
	
	
	// Initial input wires
	//wire [7:0] data_in;
	//assign data_in = SW[6:0]; // to datapath: input initial x,y values
	
	//wire go; 
	//assign go = ~KEY[3]; // to controller: go signal for controller to cycle through states
									// controller moves to the next state if either KEY[3] or KEY[1] is pressed.
									// because input is loaded with KEY[3] but writeEnable/plot signal is KEY[1]
									
	wire [2:0] colour;
	
	wire writeEn;
	assign writeEn = 1'b1;// to VGA: writeEnable/plot signal for the VGA	
	
	// Output wires to VGA
	wire [7:0] x; // x output from datapath to VGA
	wire [6:0] y; // y output from datapath to VGA
	

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(1'b1),
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
    
    // Instantiate datapath

    wire[1:0] statesig;
    wire erase_ball, draw_plat, draw_ball;
    // Instantiate FSM control
    control c0(
        .clk(CLOCK_50),
        .resetn(SW[1]),
        .statesig(statesig),
        .erase_ball(erase_ball),
        .draw_ball(draw_ball),
        .draw_plat(draw_plat),
		.idletoerase(adjustedClock1)
    );

	wire gameover;
	wire [7:0] prev_ball_memout, curr_ball_memout, prev_ball_up2mem, curr_ball_up2mem;
	wire [2:0] color_ball_memout, color_ball_up2mem;
	wire [11:0] color_plats_memout,color_plats_up2mem,score_up2mem, score_memout;
	wire [27:0] position_plats_memout, position_plats_up2mem;
	wire idletoerase;
	
	/*
	assign prev_ball_up2mem = 8'd0;
	assign curr_ball_up2mem = 8'b01000010;
	assign color_ball_up2mem = 3'b001;
	assign color_plats_up2mem = 12'b100001010011;
	assign position_plats_up2mem = 28'b0011000000001100001010000111;
   assign score_up2mem = 0;
	*/
	
    updater up_game(
        .curr_ball(curr_ball_memout),
        .position_plats(position_plats_memout),
        .color_plats(color_plats_memout),
        .color_ball(color_ball_memout),
        .statesig(statesig),
        .clk(CLOCK_50),
        .keys(KEY[3:0]),
        .curr_score(score_memout),
        .prev_ball(prev_ball_up2mem),
        .new_curr_ball(curr_ball_up2mem),
        .new_color_plats(color_plats_up2mem),
        .new_color_ball(color_ball_up2mem),
        .gameover(gameover),
        .next_score(score_up2mem),
    );
    
	 
	 memory mem_game(
		.clk(CLOCK_50),
		.reset(SW[0]),
		.prev_ball_in(prev_ball_up2mem),
		.curr_ball_in(curr_ball_up2mem),
		.color_ball_in(color_ball_up2mem),
		.color_plats_in(color_plats_up2mem),
		.position_plats_in(position_plats_up2mem),
		.prev_ball_out(prev_ball_memout),
		.curr_ball_out(curr_ball_memout),
		.color_ball_out(color_ball_memout),
		.color_plats_out(color_plats_memout),
		.position_plats_out(position_plats_memout),
		.score_in(score_up2mem),
		.score_out(score_memout)
	 );
	 
    datapath d0(
        .clk(CLOCK_50),
        .resetn(SW[1]),
        .prev_ball(prev_ball_memout),
        .curr_ball(curr_ball_memout),
        .color_ball(color_ball_memout),
        .color_plats(color_plats_memout),
        .position_plats(position_plats_memout),
        .erase_ball(erase_ball),
        .draw_ball(draw_ball),
        .draw_plat(draw_plat),
        .x_reg(x),
        .y_reg(y),
        .color_reg(colour),
        .statesig(statesig)
    );
	
	wire adjustedClock1;
	rateDivider first(
        .counter(28'd750000),
        .clock(CLOCK_50),
        .out(adjustedClock1)
    );

endmodule


//-----------------------------------------------------------------------------------------

module rateDivider (counter, clock, out);
    input [27:0] counter;
    input clock;
	output reg out;
    reg [27:0] counterMemory;


    always @ ( posedge clock )
    begin
        if (counterMemory == 0) begin
            out <= 1'b1; 
				counterMemory <= counter;
        end else begin
            counterMemory <= counterMemory - 1;
            out <= 1'b0;
			end
        
    end
endmodule

module control(
    input clk,
    input resetn,
    input[1:0] statesig,
	input idletoerase,
    output reg erase_ball,
	output reg draw_ball,
	output reg draw_plat
    );

    reg [1:0] current_state, next_state; 
    
    localparam  S_ERASE_BALL     	= 2'd0,
                S_DRAW_PLAT			= 2'd1,
                S_DRAW_BALL  		= 2'd2,
				S_IDLE				= 2'd3;
                

    
    // Next state logic aka our state table
    always @(*)
    begin: state_table 
            case (current_state)
            
                S_ERASE_BALL: next_state = (statesig == 2'b01) ? S_DRAW_PLAT : S_ERASE_BALL;
				
					S_DRAW_PLAT: next_state = (statesig == 2'b10) ? S_DRAW_BALL : S_DRAW_PLAT;
                
                S_DRAW_BALL: next_state = (statesig == 2'b11) ? S_IDLE : S_DRAW_BALL;
					 
					S_IDLE : next_state = (idletoerase == 1'b1) ? S_ERASE_BALL : S_IDLE;
           
            default:     next_state = S_ERASE_BALL;
        endcase
    end // state_table
       // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
        erase_ball = 1'b0;
        draw_plat = 1'b0;
        draw_ball = 1'b0;

        case (current_state)
         S_ERASE_BALL: erase_ball = 1'b1;
			S_DRAW_BALL: draw_ball = 1'b1;
			S_DRAW_PLAT: draw_plat = 1'b1;
			// default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
   
   
    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= S_ERASE_BALL;
        else
            current_state <= next_state;
    end // state_FFS
endmodule

//---------------------------------------------------------------------------------------


module datapath(
    input clk,
    input resetn,
    input [7:0] prev_ball, curr_ball,
	input [2:0] color_ball,
	input [11:0] color_plats,
	input [27:0] position_plats,
    input erase_ball,  
    input draw_ball,
	input draw_plat,
    output reg [7:0] x_reg,
    output reg [7:0] y_reg,
	output reg [2:0] color_reg,
	output reg [2:0] statesig
    );
    
	// initialize color_reg and statesig
	initial color_reg = 3'b000;
	initial statesig = 2'b00;
	
	// initialize internal values for calculations
	reg [3:0] counter = 4'b0000; // to count how many pixels we've drawn
	reg [1:0] counter_plat = 2'b00; // to count how many platforms we've drawn
	reg [7:0] original_x = 8'd80; // hard-coded x-coordinate for ball
	
    
    always@(posedge clk) begin
        if(!resetn) begin
            x_reg <= 8'b0; 
            y_reg <= 8'b0;
			counter <= 4'b0;
        end
        
        else begin
			if(erase_ball) begin
				if (counter == 4'b1111) begin
					x_reg <= original_x + counter[1:0];
					y_reg <= prev_ball + counter[3:2];
					color_reg <= 3'b000; // erase the ball by drawing it in black
					
					counter <= 4'b0000;
					statesig <= 2'b01; // move to next state
				end
				else begin
					x_reg <= original_x + counter[1:0];
					y_reg <= prev_ball + counter[3:2];
					color_reg <= 3'b000; // erase the ball by drawing it in black
					
					counter <= counter + 1'b1; // increment counter
					statesig <= 2'b00; // stay in current state
				end
			end
			
			if(draw_plat) begin
				// if we have finished drawing all the platforms, reset both counters and move to the next state

			
				// if we have not drawn all the platforms, draw the next platform
				statesig <= 2'b01; // stay in current state
				
				// if we have finished drawing the current platform, reset drawing counter and try to draw the next platform
				if (counter == 4'b1111) begin
					counter <= 4'b0000;
					counter_plat <= counter_plat + 1; // increment counter_plat to try to draw the next platform
					if(counter_plat == 2'b11) begin
						counter_plat <= 2'b00;
						statesig <= 2'b10; // move to next state
						y_reg <= position_plats[27:21];
						color_reg <= color_plats[11:9];
					end
				end
				
				// if we have not finished drawing the current platform, continue
				else begin
					x_reg <= (original_x - 6) + counter; // platform should start 6 pixels to the left of the ball
					case(counter_plat)
						0: begin
								y_reg <= position_plats[6:0];
								color_reg <= color_plats[2:0];
							end
						1: begin
								y_reg <= position_plats[13:7];
								color_reg <= color_plats[5:3];
							end
						2: begin
								y_reg <= position_plats[20:14];
								color_reg <= color_plats[8:6];
							end
						3: begin
								y_reg <= position_plats[27:21];
								color_reg <= color_plats[11:9];
							end	
					endcase
					//y_reg <= position_plats[: (counter_plat * 8)]; // ex: start y-coordinate for platform 1 will be in [7:0],
																						// start y-coordinate for platform 2 will be in [15:8], etc.
																						// platforms are only 1 pixel high
					//color_reg <= color_plats[(counter_plat * 3) + 2: (counter_plat * 3)]; // ex: colours for platform 1 will be in [2:0],
																						  // colours for platform 2 will be in [5:3], etc.
					
					counter <= counter + 1'b1; // increment drawing counter to draw next pixel
				end
			end
			
			if(draw_ball) begin
				if (counter == 4'b1111) begin
					x_reg <= original_x + counter[1:0];
					y_reg <= curr_ball + counter[3:2];
					color_reg <= color_ball;
					
					counter <= 4'b0000; // reset counter
					statesig <= 2'b11; // move to next state
				end
				else begin
					x_reg <= original_x + counter[1:0];
					y_reg <= curr_ball + counter[3:2];
					color_reg <= color_ball;
					
					counter <= counter + 1'b1; // increment counter
					statesig <= 2'b10; // stay in current state
				end
			end
        end
    end
endmodule
