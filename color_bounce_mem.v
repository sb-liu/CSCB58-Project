module memory(
	input clk,
	input[7:0] prev_ball_in,
	input[7:0] curr_ball_in,
	input[2:0] color_ball_in,
	input[11:0] color_plats_in,
	input[27:0] position_plats_in,
    input[11:0] score_in,
	output reg [7:0] prev_ball_out,
	output reg[7:0] curr_ball_out,
	output reg[2:0] color_ball_out,
	output reg[11:0] color_plats_out,
	output reg[27:0] position_plats_out,
    output reg[11:0] score_out
	);
	
	always@(posedge clk)
	begin
		prev_ball_out <= prev_ball_in;
		curr_ball_out <= curr_ball_in;
		color_ball_out <= color_ball_in;
		color_plats_out <= color_plats_in;
		position_plats_out <= position_plats_in;
        score_out <= score_in;
	end
endmodule
