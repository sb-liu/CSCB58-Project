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
