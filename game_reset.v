/*module game_reset(SW, LEDR, CLOCK_50);
	input[9:0] SW;
	output [9:0]LEDR;
	input CLOCK_50;
	
	game_reset1 gr(
		.start_key(SW[0]),
		.gameover(SW[1]),
		.clk(CLOCK_50),
		.reset_is_on(LEDR[5])
	);
	//assign LEDR[0] = 1;
endmodule
*/

module game_reset(
	start_key,
	gameover,
	clk,
	reset_is_on
);
	input start_key, gameover, clk;
	output reg reset_is_on = 1;
	//initial reset_is_on = 1;

	always@(posedge clk) begin
		case({gameover, start_key})
			1:reset_is_on = 0;
			2:reset_is_on = 1;
			3:reset_is_on = 1;
			default: reset_is_on = reset_is_on;
		endcase
	end
endmodule