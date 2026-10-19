module encoder_3b4b_boolean (encoder_3b4b_if.DUT sif);
    logic [4:0] x;
    logic [2:0] y;
    logic F, G, H, R;
    logic f, g, h, j;
    logic valid_symbol, k28, alt7, flip_k28;
    logic [3:0] base4, selected4;
    logic [2:0] ones4;

    assign x = sif.in_data[4:0];
    assign y = sif.in_data[7:5];
    assign {H, G, F} = y;
    assign R = sif.rd_mid;

    assign k28 = sif.in_is_k && (x == 5'd28);
    assign valid_symbol = !sif.in_is_k || (x == 5'd28)
                   || ((y == 3'd7) &&
                       ((x == 5'd23) || (x == 5'd27) ||
                        (x == 5'd29) || (x == 5'd30)));


    assign f = (F & ~G) |
            (F & ~R) |
            (~G & ~R);

    assign g = (G & ~F) |
            (G & ~R) |
            (H & ~F & ~R) |
            (R & ~F & ~H);

    assign h = (F & H & ~R) |
            (G & H & ~F) |
            (H & R & ~G) |
            (F & G & R & ~H) |
            (~F & ~G & ~H & ~R);

    assign j = (F & G & R) |
            (F & ~G & ~H) |
            (G & ~F & ~H) |
            (~F & ~G & ~R);


    assign base4 = {f, g, h, j};

   
    assign alt7 = y == 3'd7 &&
             (sif.in_is_k ||
              (R && (x == 5'd11 || x == 5'd13 || x == 5'd14)) ||
              (!R && (x == 5'd17 || x == 5'd18 || x == 5'd20)));


    assign flip_k28 = k28 && !R &&
                     (y == 3'd1 || y == 3'd2 || y == 3'd5 || y == 3'd6);

    assign selected4 = base4 ^ (alt7 ? 4'b1001 : 4'b0000)
                             ^ {4{flip_k28}};
    assign sif.invalid_k = sif.in_valid && !valid_symbol;
    assign sif.out_valid = sif.in_valid && valid_symbol;
    assign sif.code4 = valid_symbol ? selected4 : 4'b0000;

    assign ones4 = {2'b00, selected4[0]} + {2'b00, selected4[1]}
                 + {2'b00, selected4[2]} + {2'b00, selected4[3]};
    assign sif.rd_out = !valid_symbol ? sif.rd_mid :
                        ones4 > 2 ? 1'b1 :
                        ones4 < 2 ? 1'b0 : sif.rd_mid;
endmodule
