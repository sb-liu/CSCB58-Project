module color_rand(
    output [11:0] new_color_plats,
    output [2:0] new_color_ball
    );
    new_color_ball = $random%10[2:0];
    reg [1:0] position = 2'b0
    always @ ( * ) begin
        new_color_ball = $random%10[2:0];
    end

endmodule
