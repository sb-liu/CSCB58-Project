/*
module color_randomize(
	input [9:0] SW,
	output [17:0] LEDR
);

	pseudo_rand ya(
		.out(LEDR[7:0]),
		.enable(SW[1]),
		.clk(SW[0]),
		.reset(SW[9]),
		.seed(8'b10101001)
	);
		
endmodule
*/

module pseudo_rand(
	out,  
	enable,  
	clk,  
	reset,
	seed
);

	output [7:0] out;

	input enable, clk, reset;
	input [7:0] seed;
	reg [7:0] out = 8'b10110101;
	wire linear_feedback;

	assign linear_color_platsfeedback = (out[7] ^ out[3]);
	wire[3:0] no = out[7:4];
	wire[3:0] xno = ~out[3:0];
	always @(posedge clk)
		if (reset) begin 
		  out <= 8'b0 ;
		end 
		
		else if (enable) begin
		out <= {no[0], xno[0],no[1], xno[1],no[2], xno[2],no[3], xno[3]};
		end 

endmodule 


module color_rand(
    new_color_plats,
    new_color_ball,
    clk
    );
	 // bit 3 and 5 always 1
	 input clk;
    output reg [11:0] new_color_plats;
    output reg [2:0] new_color_ball;
    wire [7:0] rand_out;
	 reg [1:0] position;
	 
    pseudo_rand my_rand(
		.out(rand_out),
		.enable(1'b1),
		.clk(clk),
		.reset(1'b0),
		.seed(8'b10110101)	
	);
    always @ ( * ) begin
        case (position)
            0: begin
                    new_color_plats[2:0] = rand_out[3:1];
						  new_color_ball = rand_out[3:1];
                    new_color_plats[5:3] = rand_out[5:3];
                    new_color_plats[8:6] = rand_out[7:5];
                    new_color_plats[11:9] = {rand_out[6], rand_out[3], rand_out[0]};
						  position = rand_out[4:3];
                end
            1: begin
                    new_color_plats[5:3] = rand_out[7:5];
						  new_color_ball = rand_out[7:5];
                    new_color_plats[2:0] = rand_out[6:4];
                    new_color_plats[8:6] = {rand_out[2], rand_out[3], rand_out[0]};
                    new_color_plats[11:9] = {rand_out[5], rand_out[1], rand_out[6]};
                    position = rand_out[3:2];
                end
            2:  begin
                    new_color_plats[8:6] = {rand_out[2], rand_out[3], rand_out[0]};
						  new_color_ball = {rand_out[2], rand_out[3], rand_out[0]};
                    new_color_plats[5:3] = {rand_out[7], rand_out[2], rand_out[3]};
                    new_color_plats[2:0] = rand_out[5:3];
                    new_color_plats[11:9] = rand_out[3:1];
		              position = rand_out[7:6];
                end
            3:  begin
                    new_color_plats[11:9] = rand_out[6:4];
						  new_color_ball = rand_out[6:4];
                    new_color_plats[5:3] = {rand_out[7], rand_out[2], rand_out[3]};
                    new_color_plats[2:0] = {rand_out[5], rand_out[1], rand_out[1]};
                    new_color_plats[8:6] = {rand_out[1], rand_out[1], rand_out[3]};
                    position = rand_out[5:4];
                end
					 default: begin
                    new_color_plats[11:9] = rand_out[6:4];
						  new_color_ball = rand_out[6:4];
                    new_color_plats[5:3] = {rand_out[7], rand_out[2], rand_out[3]};
                    new_color_plats[2:0] = {rand_out[5], rand_out[1], rand_out[1]};
                    new_color_plats[8:6] = {rand_out[1], rand_out[1], rand_out[3]};
                    position = rand_out[5:4];
                end
        endcase
    end

endmodule

