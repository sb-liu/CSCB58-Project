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

//-----------------------------------------------------
// Design Name : lfsr
// File Name   : lfsr.v
// Function    : Linear feedback shift register
// Coder       : Deepak Kumar Tala
//-----------------------------------------------------
module lfsr    (
out             ,  // Output of the counter
enable          ,  // Enable  for counter
clk             ,  // clock input
reset              // reset input
);

//----------Output Ports--------------
output [7:0] out;
//------------Input Ports--------------

input enable, clk, reset;
//------------Internal Variables--------
reg [7:0] out = 8'b10101001;
wire linear_feedback;

//-------------Code Starts Here-------
assign linear_feedback = (out[7] ^ out[3]);
wire[3:0] no = out[7:4];
wire[3:0] xno = ~out[3:0];
always @(posedge clk)
if (reset) begin // active high reset
  out <= 8'b0 ;
end else if (enable) begin
  out <= {no[0], xno[0],no[1], xno[1],no[2], xno[2],no[3], xno[3]};
end 

endmodule // End Of Module counter


/*
module color_rand(
    output [11:0] new_color_plats,
    output [2:0] new_color_ball
    );
    assign new_color_ball = $random%8[2:0];
    reg [1:0] position = 2'b00;
    reg [2:0] plat1_color = 3'b000;
    reg [2:0] plat2_color = 3'b000;
    reg [2:0] plat3_color = 3'b000;
    always @ ( * ) begin
        // Get color of the ball
        new_color_ball = $random%7[2:0];
        // if the color is 000, i.e. it is black
        // get a new color
        // do the same and randomize the colors for the other platforms
        while (new_color_ball != 3'b000) begin
            new_color_ball = $random%7[2:0];
        end
        while (plat1_color != 3'b000) begin
            plat1_color = $random%7[2:0];
        end
        while (plat2_color != 3'b000) begin
            plat2_color = $random%7[2:0];
        end
        while (plat3_color != 3'b000) begin
            plat3_color = $random%7[2:0];
        end


        position = $random%3[1:0]
        case (position)
            0: begin
                    new_color_plats[2:0] = new_color_ball;
                    new_color_plats[5:3] = plat1_color;
                    new_color_plats[8:6] = plat2_color;
                    new_color_plats[11:9] = plat3_color;
                end
            1: begin
                    new_color_plats[5:3] = new_color_ball;
                    new_color_plats[2:0] = plat1_color;
                    new_color_plats[8:6] = plat2_color;
                    new_color_plats[11:9] = plat3_color;
                end
            2:  begin
                    new_color_plats[8:6] = new_color_ball;
                    new_color_plats[5:3] = plat1_color;
                    new_color_plats[2:0] = plat2_color;
                    new_color_plats[11:9] = plat3_color;
                end
            3:  begin
                    new_color_plats[11:9] = new_color_ball;
                    new_color_plats[5:3] = plat1_color;
                    new_color_plats[2:0] = plat2_color;
                    new_color_plats[8:6] = plat3_color;
                end
        endcase
    end

endmodule
*/