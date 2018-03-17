module updater (
	input[7:0] curr_ball,
	input[27:0] position_plats,
	input[11:0] color_plats,
	input[2:0] color_ball,
	input[1:0] statesig, // signal from controller to update values
	input clk,
	input[3:0] keys,
    input [31:0] curr_score,
	output[7:0] reg prev_ball,
	output[7:0] reg new_curr_ball,
	output[11:0] reg new_color_plats,
	output[2:0] reg new_color_ball,
    output reg gameover,
    output reg next_score
);	
    reg[3:0] up_counter = 0;
	reg touch;
    gameover = 0;
    
	always@(posedge clk) begin
        touch = 0;
        score = 0;
		if(statesig == 2'b10) begin
            if (up_counter > 0) counter <= counter - 1;
			//Key 3 pressed 0111
			//Key 2 pressed 1011
			//Key 1 pressed 1101
			//Key 0 pressed 1110
			// Need to know when key is pressed along with ball position
			case(keys)
				4'b0111: touch = (color_ball == color_plats[2:0]) & ((curr_ball <= position_plats[6:0]) && (position_plats[6:0] <= (curr_ball + 4)));
				4'b1011: touch = (color_ball == color_plats[5:3]) & ((curr_ball <= position_plats[13:7]) && (position_plats[13:7] <= (curr_ball + 4)));
				4'b1101: touch = (color_ball == color_plats[8:6]) & ((curr_ball <= position_plats[20:14]) && (position_plats[20:14] <= (curr_ball + 4)));
				4'b1110: touch = (color_ball == color_plats[11:9]) & ((curr_ball <= position_plats[27:21]) && (position_plats[27:21] <= (curr_ball + 4)));
				default: touch = 1'b0;
			endcase
			// Going Down
			// Settin new positions of the ball
		
			
			if (touch) begin
				// Color S w a p
				new_color_ball = //random
				new_color_plats = //random
				// Swith the direction (we reset direction when we hit the counter)
				counter = 20;
                next_score = curr_score + 1;
			end
            else begin
                new_color_ball = color_ball;
                new_color_plats = color_plats;
                next_score = curr_score;
            end

			prev_ball = curr_ball;
			
			// Going Down
			// Settin new positions of the ball
			if (up_counter == 0) begin
				new_curr_ball = curr_ball + 1;
			end
			
			// Going up
			else begin
				new_curr_ball = curr_ball - 1;		
			end
			if (new_curr_ball >= 7'd116)
				gameover = 1;
			
			// Code for the counter
		end
	end
endmodule

