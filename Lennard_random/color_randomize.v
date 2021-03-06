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

	output [31:0] out;

	input enable, clk, reset;
	input [7:0] seed;
	reg [31:0] out = 32'd4;
	wire linear_feedback;

	reg linear_color_platsfeedback1;
	reg linear_color_platsfeedback2;
//	wire[3:0] no = out[7:4];
//	wire[3:0] xno = ~out[3:0];
	reg tf;
	reg mux2out;
	always@(posedge clk) begin
		tf = ~tf;
		case(tf)
			0:linear_color_platsfeedback1= (out[25] ^ out[10]);
			1:linear_color_platsfeedback2= ~(out[25] ^ out[10]);
		endcase
	end
	always @(posedge clk) begin
		if (reset) begin 
		  out <= 32'd2147483647 ;
		end 
		
		else if (enable) begin
			out <= (2*(out * out) + 5*(out) + 1);
		end 
	end
endmodule 

module color_rand(
    new_color_ball,
    new_color_plats,
    clk
);
    input clk;
    output[11:0] new_color_plats;
    output[2:0] new_color_ball;
    wire[11:0] cplats_out;
    
    color_rand_plats cplats(
        .clk(clk),
        .new_color_plats(new_color_plats)
    );
    color_rand_ball cball(
        .clk(clk),
        .new_color_plats(new_color_plats),
        .new_color_ball(new_color_ball)
    );

endmodule

module color_rand_ball(
    clk,
    new_color_plats,
    new_color_ball
);
    input clk;
    input[11:0] new_color_plats;
    output reg [2:0] new_color_ball;
    wire[31:0] rand_out;
    
    pseudo_rand my_rand(
		.out(rand_out),
		.enable(1'b1),
		.clk(clk),
		.reset(1'b0),
		.seed(8'b10110101)	
	);
    
    always@(*) begin
        case(rand_out % 4)
            0:new_color_ball = new_color_plats[2:0];
            1:new_color_ball = new_color_plats[5:3];
            2:new_color_ball = new_color_plats[8:6];
            3:new_color_ball = new_color_plats[11:9];
        endcase
    end
endmodule

module color_rand_plats(
    new_color_plats,
    clk
    );
	 // bit 3 and 5 always 1
	 input clk;
    output reg [11:0] new_color_plats;
    wire [31:0] rand_out;
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
                    new_color_plats[2:0] = rand_out[7:0] % 8;
					//	  new_color_ball = rand_out[7:0] % 8;
                    new_color_plats[5:3] = rand_out[15:8] % 8;
                    new_color_plats[8:6] = rand_out[23:16] % 8;
                    new_color_plats[11:9] = rand_out[31:24] % 8;
						  position = rand_out[7:0] % 4;
                end
            1: begin
                    new_color_plats[5:3] = rand_out[7:0] % 8;
					//	  new_color_ball = rand_out[7:0] % 8;
                    new_color_plats[2:0] = rand_out[15:8] %8;
                    new_color_plats[8:6] = rand_out[23:16] % 8;
                    new_color_plats[11:9] = rand_out[31:24] %8;
                    position = rand_out[15:8] % 4;
                end
            2:  begin
                    new_color_plats[8:6] = rand_out[7:0] % 8;
					//	  new_color_ball = rand_out[7:0] % 8;
                    new_color_plats[5:3] = rand_out[15:8] %8;
                    new_color_plats[2:0] = rand_out[23:16] % 8;
                    new_color_plats[11:9] = rand_out[31:24] %8;
		              position = rand_out[23:16] % 4;
                end
            3:  begin
                    new_color_plats[11:9] = rand_out[7:0] % 8;
					//	  new_color_ball = rand_out[7:0] % 8;
                    new_color_plats[5:3] = rand_out[15:8] %8;
                    new_color_plats[2:0] = rand_out[23:16] % 8;
                    new_color_plats[8:6] = rand_out[31:24] % 8;
                    position = rand_out[31:24] % 4;
                end
					 default: begin
                    new_color_plats[11:9] = rand_out[7:0] % 8;
					//	  new_color_ball = rand_out[7:0] % 8;
                    new_color_plats[5:3] = rand_out[15:8] %8;
                    new_color_plats[2:0] = rand_out[23:16] % 8;
                    new_color_plats[8:6] = rand_out[31:24] % 8;
                    position = rand_out[31:24] % 4;
                end
        endcase
    end

endmodule

