module color_randomize(
	input [9:0] SW,
	output [17:0] LEDR
);

	lfsr ya(
		.out(LEDR[7:0]),
		.enable(SW[1]),
		.clk(SW[0]),
		.reset(SW[9])
	);
		
endmodule

module pseudo_rand(
	out,  
	enable,  
	clk,  
	reset,
	seed
);

	output [7:0] out;

	input enable, clk, reset;
	input [7:0] seed
	//reg [7:0] out = 8'b10101001;
	reg [7:0] out = seed;
	wire linear_feedback;

	assign linear_feedback = (out[7] ^ out[3]);
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
    pseudo_rand my_rand(
	.out(rand_out_wire),
	.enable(1'b1),
	.clk(clk),
	.reset(1'b0),
	.seed(8'b10101001)	
	);

    output reg [11:0] new_color_plats;
    output reg [2:0] new_color_ball;
    wire [7:0] rand_out_wire;
    reg [7:0] rand_out = rand_out_wire;
    reg [1:0] position = rand_out[1:0];
    reg [2:0] plat1_color = 3'b000;
    reg [2:0] plat2_color = 3'b000;
    reg [2:0] plat3_color = 3'b000;
    always @ ( * ) begin
	
        case (position)
            0: begin
                    new_color_plats[2:0] = new_color_ball;
                    new_color_plats[5:3] = plat1_color;
                    new_color_plats[8:6] = plat2_color;
                    new_color_plats[11:9] = plat3_color;
		    position = rand_out[4:3];
                end
            1: begin
                    new_color_plats[5:3] = new_color_ball;
                    new_color_plats[2:0] = plat1_color;
                    new_color_plats[8:6] = plat2_color;
                    new_color_plats[11:9] = plat3_color;
                    position = rand_out[3:2];
                end
            2:  begin
                    new_color_plats[8:6] = new_color_ball;
                    new_color_plats[5:3] = plat1_color;
                    new_color_plats[2:0] = plat2_color;
                    new_color_plats[11:9] = plat3_color;
		    position = rand_out[7:6];
                end
            3:  begin
                    new_color_plats[11:9] = new_color_ball;
                    new_color_plats[5:3] = plat1_color;
                    new_color_plats[2:0] = plat2_color;
                    new_color_plats[8:6] = plat3_color;
                    position = rand_out[5:4];
                end
        endcase
    end

endmodule

