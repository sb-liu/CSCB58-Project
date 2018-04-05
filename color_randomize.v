
module color_randomize(
	input [9:0] SW,
	output [17:0] LEDR,
	input CLOCK_50,
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4
);

	/*pseudo_rand ya(
		.out(LEDR[7:0]),
		.enable(SW[1]),
		.clk(SW[0]),
		.reset(SW[9]),
		.seed(8'b10101001)
	);*/
	
	wire [31:0] color_plats_out;
	wire [2:0] color_ball_out;
	
	assign LEDR[2:0] = color_ball_out;
	
	color_rand1 myrand(
		.new_color_ball(color_ball_out),
		.new_color_plats(color_plats_out),
		.clk(SW[0])
	);
	
	hex_display h0(
		.IN(color_plats_out[2:0]),
		.OUT(HEX0)
	 );

	 hex_display h1(
		.IN(color_plats_out[5:3]),
		.OUT(HEX1)
	 );

	 hex_display h2(
		.IN(color_plats_out[8:6]),
		.OUT(HEX2)
	 );

	 hex_display h3(
		.IN(color_plats_out[11:9]),
		.OUT(HEX3)
	 );
	 
	 hex_display h4(
		.IN(color_ball_out),
		.OUT(HEX4)
	 );
	
		
endmodule


module pseudo_rand(
	out,  
	enable,  
	clk,  
	reset
);

	//output [31:0] out;

	input enable, clk, reset;
	output reg [31:0] out;
	wire linear_feedback;

	reg linear_color_platsfeedback1;
	reg linear_color_platsfeedback2;
//	wire[3:0] no = out[7:4];
//	wire[3:0] xno = ~out[3:0];
	reg tf;
	reg mux2out;

	initial out = 32'd1668220261;
	
	always @(posedge clk) begin
		if (reset) begin 
		  out <= 32'd1668220261 ;
		end 
		
		else if (enable) begin
			out <= (3*(out * out) + 7*(out) + 1);
		end 
	end
endmodule 

module color_rand(
	new_color_ball,
    new_color_plats,
    clk
    );
	 input clk;
	 output reg [2:0] new_color_ball;
    output reg [11:0] new_color_plats;
	 wire [31:0] rand_out_wire;
    reg [31:0] rand_out;
	 reg [1:0] position;
	 
	 
	 
    pseudo_rand my_rand(
		.out(rand_out_wire),
		.enable(1'b1),
		.clk(clk),
		.reset(1'b0)
	);
    reg[2:0] selected_color, section1, section2, section3;
	 initial begin
		 selected_color <= 3'b010;
		 section1 <= 3'b001;
		 section2 <= 3'b100;
		 section3 <= 3'b111;
		 new_color_plats <= {selected_color,section1,section2,section3};
		 new_color_ball <= selected_color;
	 end
    
    always @ ( posedge clk ) begin
			rand_out <= rand_out_wire;
			selected_color <=  (rand_out[7:0] % 4'd7) + 1;
			section1 <= (rand_out[15:8] % 4'd7) + 1;
			section2 <= (rand_out[23:16] % 4'd7) + 1;
			section3 <= (rand_out[31:24] % 4'd7) + 1;

		  case (position)
				0: begin
						  new_color_plats[2:0] <= selected_color;
						  new_color_ball <= selected_color;
						  new_color_plats[5:3] <= section1;
						  new_color_plats[8:6] <= section2;
						  new_color_plats[11:9] <= section3;
						  position <= rand_out[7:0] % 3'd4;
					 end
				1: begin
						  new_color_plats[5:3] <= selected_color;
						  new_color_ball <= selected_color;
						  new_color_plats[2:0] <= section1;
						  new_color_plats[8:6] <= section2;
						  new_color_plats[11:9] <= section3;
						  position <= rand_out[15:8] % 3'd4;
					 end
				2:  begin
						  new_color_plats[8:6] <= selected_color;
						  new_color_ball <= selected_color;
						  new_color_plats[5:3] <= section1;
						  new_color_plats[2:0] <= section2;
						  new_color_plats[11:9] <= section3;
						  position <= rand_out[23:16] % 3'd4;
					 end
				3:  begin
						  new_color_plats[11:9] <= selected_color;
						  new_color_ball <= selected_color;
						  new_color_plats[5:3] <= section1;
						  new_color_plats[2:0] <= section2;
						  new_color_plats[8:6] <= section3;
						  position <= rand_out[31:24] % 3'd4;
					 end
					 default: begin
						  new_color_plats[11:9] <= selected_color;
						  new_color_ball <= selected_color;
						  new_color_plats[5:3] <= section1;
						  new_color_plats[2:0] <= section2;
						  new_color_plats[8:6] <= section3;
						  position  <= rand_out[31:24] % 3'd4;
					 end
		  endcase
    end

endmodule

