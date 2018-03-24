module updater (
	input[7:0] curr_ball,
	input[27:0] position_plats,
	input[11:0] color_plats,
	input[2:0] color_ball,
	input[1:0] statesig, // signal from controller to update values
	input clk,
	input[3:0] keys,
    input [15:0] curr_score,
	 output reg[7:0] prev_ball,
	 output reg[7:0] new_curr_ball,
	 output reg[11:0] new_color_plats,
	 output reg[2:0] new_color_ball,
    output reg gameover,
    output reg[15:0] next_score
);	
	reg[5:0] up_counter;
	reg touch;
	wire [11:0] new_color_plats_wire;
	wire [2:0] new_color_ball_wire;
	color_rand myradd(
		.new_color_plats(new_color_plats_wire),
      .new_color_ball(new_color_ball_wire),
      .clk(touch)
	);
    
	always@(posedge clk) begin
		touch = 0;
		
		if(statesig == 2'b11) begin
			// If key is pressed, check if ball is touching corresponding platform of the same colour
			//Key 3 pressed 0111	//Key 1 pressed 1101
			//Key 2 pressed 1011	//Key 0 pressed 1110
			if (up_counter == 0) begin
				case(keys)
					4'b0111: touch = (color_ball == color_plats[2:0]) & ((curr_ball <= position_plats[6:0]) && (position_plats[6:0] <= (curr_ball + 4)));
					4'b1011: touch = (color_ball == color_plats[5:3]) & ((curr_ball <= position_plats[13:7]) && (position_plats[13:7] <= (curr_ball + 4)));
					4'b1101: touch = (color_ball == color_plats[8:6]) & ((curr_ball <= position_plats[20:14]) && (position_plats[20:14] <= (curr_ball + 4)));
					4'b1110: touch = (color_ball == color_plats[11:9]) & ((curr_ball <= position_plats[27:21]) && (position_plats[27:21] <= (curr_ball + 4)));
					default: touch = 1'b0;
				endcase		
			end
			
			if (touch) begin
				// If ball is touching correct platform, Color S w a p
				// ENTER CODE HERE
				new_color_ball = new_color_ball_wire;//random
				new_color_plats = new_color_plats_wire;//random
				
				// Make ball go up (direction will change back to down when counter reaches 0)
				up_counter <= 50;
				next_score = curr_score + 1;
			end
            else begin
				// If not touching, all colours stay the same
                new_color_ball = color_ball;
                new_color_plats = color_plats;
                next_score = curr_score;
            end
			
			
			// Setting new positions of the ball
			prev_ball = curr_ball;
			gameover = 0;
			
			if (up_counter == 0) begin // Ball going down
				new_curr_ball = curr_ball + 1;
			end
			else begin // Ball going up
				new_curr_ball = curr_ball - 1;	
				up_counter <= up_counter - 1;
			end
			
			// If ball drops to the bottom, game over
			if (new_curr_ball >= 7'd116)
				gameover = 1;
				next_score = 0;
		end
	end
endmodule

