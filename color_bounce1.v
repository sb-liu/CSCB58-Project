// Part 2 skeleton

module color_bounce1
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		  HEX0,
		  HEX1,
		  HEX2,
		  HEX3,
		  HEX4,
		  HEX5,
		  HEX6,
		  HEX7,
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
	output [6:0] HEX0, HEX1, HEX2,HEX3,HEX4,HEX5, HEX6, HEX7;

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
	wire [6:0] x; // x output from datapath to VGA
	wire [7:0] y; // y output from datapath to VGA


	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(1'b1),
			.clock(CLOCK_50),
			.colour(colour),
			.x(y),
			.y(x),
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
        .resetn(1'b1),
        .statesig(statesig),
        .erase_ball(erase_ball),
        .draw_ball(draw_ball),
        .draw_plat(draw_plat),
		.idletoerase(adjustedClock1)
    );

	wire gameover;
	wire [7:0] prev_ball_memout, curr_ball_memout, prev_ball_up2mem, curr_ball_up2mem;
	wire [2:0] color_ball_memout, color_ball_up2mem;
	wire [11:0] color_plats_memout,color_plats_up2mem;
	wire [15:0] score_up2mem, score_memout;
	wire [31:0] position_plats_memout, position_plats_up2mem;
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
		  .pause(SW[1])
    );

	 wire game_reset_out;
	 wire or_keys = KEY[0] && KEY[1] && KEY[2] && KEY[3];
	 game_reset gr(
		.start_key(!or_keys),
		.gameover(gameover),
		.clk(CLOCK_50),
		.reset_is_on(game_reset_out)
	 );

	 wire game_reset_or_key = game_reset_out || SW[0];

	 memory mem_game(
		.clk(CLOCK_50),
		.reset(game_reset_or_key),
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
		.score_out(score_memout),
		.hiscore(hiscore)
	 );

    datapath d0(
        .clk(CLOCK_50),
        .resetn(1'b1),
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
        .counter(28'd750000-(score_memout*15000)),
		  //.counter(28'd750000 >> (score_memout)),
        .clock(CLOCK_50),
        .out(adjustedClock1)
    );
	 
	 wire[15:0] hiscore;
	 wire [3:0] tens_score, ones_score, tens_hi, ones_hi;
	 
	 bcd b2d(
		.number(score_memout[7:0]),
		.tens(tens_score),
		.ones(ones_score)
	 );
	 
	 bcd b2d_hi(
		.number(hiscore[7:0]),
		.tens(tens_hi),
		.ones(ones_hi)
	 );
/*
	 hex_display h0(
		.IN(score_memout[3:0]),
		.OUT(HEX0)
	 );

	 hex_display h1(
		.IN(score_memout[7:4]),
		.OUT(HEX1)
	 );*/
	 hex_display h0(
		.IN(ones_score),
		.OUT(HEX0)
	 );

	 hex_display h1(
		.IN(tens_score),
		.OUT(HEX1)
	 );
/*
	 hex_display h2(
		.IN(12),
		.OUT(HEX2)
	 );
*/
	assign HEX2 = 7'b0100111;
	 hex_display h3(
		.IN(5),
		.OUT(HEX3)
	 );
	 /*
	 hex_display hih0(
		.IN(hiscore[3:0]),
		.OUT(HEX4)
	 );

	 hex_display hih1(
		.IN(hiscore[7:4]),
		.OUT(HEX5)
	 );*/

	 hex_display hih0(
		.IN(ones_hi),
		.OUT(HEX4)
	 );

	 hex_display hih1(
		.IN(tens_hi),
		.OUT(HEX5)
	 );
	 
	 hex_display hih2(
		.IN(1),
		.OUT(HEX6)
	 );
/*
	 hex_display hih3(
		.IN(hiscore[15:12]),
		.OUT(HEX7)
	 );
	 */
	 assign HEX7 = 7'b0001001;
endmodule


//-----------------------------------------------------------------------------------------
/*
module game_reset(
	start_key,
	gameover,
	clk,
	reset_is_on
);
	input start_key, gameover, clk;
	output reg reset_is_on;
	initial reset_is_on = 1;

	always@(posedge clk) begin
		case({gameover, start_key})
			1:reset_is_on = 0;
			2:reset_is_on = 1;
			3:reset_is_on = 1;
			default: reset_is_on = reset_is_on;
		endcase
	end
endmodule

*/
module hex_display(IN, OUT);
    input [3:0] IN;
	 output reg [7:0] OUT;

	 always @(*)
	 begin
		case(IN[3:0])
			4'b0000: OUT = 7'b1000000;
			4'b0001: OUT = 7'b1111001;
			4'b0010: OUT = 7'b0100100;
			4'b0011: OUT = 7'b0110000;
			4'b0100: OUT = 7'b0011001;
			4'b0101: OUT = 7'b0010010;
			4'b0110: OUT = 7'b0000010;
			4'b0111: OUT = 7'b1111000;
			4'b1000: OUT = 7'b0000000;
			4'b1001: OUT = 7'b0011000;
			4'b1010: OUT = 7'b0001000;
			4'b1011: OUT = 7'b0000011;
			4'b1100: OUT = 7'b1000110;
			4'b1101: OUT = 7'b0100001;
			4'b1110: OUT = 7'b0000110;
			4'b1111: OUT = 7'b0001110;
			default: OUT = 7'b0111111;
		endcase

	end
endmodule

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
	input [31:0] position_plats,
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
	reg [7:0] original_x = 8'd60; // hard-coded x-coordinate for ball


    always@(posedge clk) begin
        if(!resetn) begin
            x_reg <= original_x;
            y_reg <= prev_ball;
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

				// if:0 we have finished drawing the current platform, reset drawing counter and try to draw the next platform
				if (counter == 4'b1111) begin
					counter <= 4'b0000;
					counter_plat <= counter_plat + 1; // increment counter_plat to try to draw the next platform
					if(counter_plat == 2'b11) begin
						counter_plat <= 2'b00;
						statesig <= 2'b10; // move to next state
						y_reg <= position_plats[31:24];
						color_reg <= color_plats[11:9];
					end
				end

				// if we have not finished drawing the current platform, continue
				else begin
					x_reg <= (original_x - 6) + counter; // platform should start 6 pixels to the left of the ball
					case(counter_plat)
						0: begin
								y_reg <= position_plats[7:0];
								color_reg <= color_plats[2:0];
							end
						1: begin
								y_reg <= position_plats[15:8];
								color_reg <= color_plats[5:3];
							end
						2: begin
								y_reg <= position_plats[23:16];
								color_reg <= color_plats[8:6];
							end
						3: begin
								y_reg <= position_plats[31:24];
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
