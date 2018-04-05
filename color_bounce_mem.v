module memory(
	input clk,
    input reset,
	input[7:0] prev_ball_in,
	input[7:0] curr_ball_in,
	input[2:0] color_ball_in,
	input[11:0] color_plats_in,
	input[31:0] position_plats_in,
    input[15:0] score_in,
	output reg [7:0] prev_ball_out,
	output reg[7:0] curr_ball_out,
	output reg[2:0] color_ball_out,
	output reg[11:0] color_plats_out,
	output reg[31:0] position_plats_out,
    output reg[15:0] score_out,
	 output reg[15:0] hiscore
	);
	
	always@(posedge clk)
	begin
		//position_plats_out <= 28'b0100011011110010101011101110;
		position_plats_out <= 32'b01011111011100111000011110011011;
		if (hiscore < score_in) hiscore <= score_in; 
        if (reset == 0) begin
            prev_ball_out <= prev_ball_in;
            curr_ball_out <= curr_ball_in;
            color_ball_out <= color_ball_in;
            color_plats_out <= color_plats_in;

			// new positions: 80 100 120 140
			// new up counter: 65
            score_out <= score_in;
         end else begin
            prev_ball_out <= prev_ball_in;
            curr_ball_out <= 0;
            color_ball_out <= 3'b111;
            color_plats_out <= 12'b001110111101;
//          position_plats_out <=  28'b0011110011110010110101100100;
				score_out <= 0;
            //score_out <= 0;
         end
	end
endmodule
