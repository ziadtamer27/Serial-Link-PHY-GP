module encoder_3b4b_ref (encoder_3b4b_if.DUT sif);
    logic [4:0] x;
    logic [2:0] y;
    logic valid_k, k28, alt7, flip_k28;
    logic [3:0] base4, selected4;
    logic [2:0] ones4;

    assign x = sif.in_data[4:0];
    assign y = sif.in_data[7:5];
    assign k28 = sif.in_is_k && x == 5'd28;
    // Table A-2 defines K28.0..K28.7 and K23/K27/K29/K30.7.
    assign valid_k = !sif.in_is_k || (x == 5'd28)
                   || ((y == 3'd7) &&
                       ((x == 5'd23) || (x == 5'd27) ||
                        (x == 5'd29) || (x == 5'd30)));

    // Alternate .7 suffix: D11/13/14.7 if RDmid+, or
    // D17/18/20.7 if RDmid-. All supported K*.7 use alt form.
    assign alt7 = y == 3'd7 &&
             (sif.in_is_k ||
              (sif.rd_mid && (x == 5'd11 || x == 5'd13 || x == 5'd14)) ||
              (!sif.rd_mid && (x == 5'd17 || x == 5'd18 || x == 5'd20)));

    // With K28.1,2,5,6 the RDmid- suffix is the complement of
    // the ordinary neutral-disparity code selected for those y values.
    assign flip_k28 = k28 && !sif.rd_mid &&
                     (y == 3'd1 || y == 3'd2 || y == 3'd5 || y == 3'd6);

    always_comb begin
        case (y)
            3'd0: base4 = sif.rd_mid ? 4'b0100 : 4'b1011;
            3'd1: base4 = 4'b1001;
            3'd2: base4 = 4'b0101;
            3'd3: base4 = sif.rd_mid ? 4'b0011 : 4'b1100;
            3'd4: base4 = sif.rd_mid ? 4'b0010 : 4'b1101;
            3'd5: base4 = 4'b1010;
            3'd6: base4 = 4'b0110;
            3'd7: base4 = sif.rd_mid ? 4'b0001 : 4'b1110;
            default: base4 = 4'b0000;
        endcase
        selected4 = base4;
        if (alt7)     selected4 = selected4 ^ 4'b1001;
        if (flip_k28) selected4 = selected4 ^ 4'b1111;
    end

    assign sif.invalid_k = sif.in_valid && !valid_k;
    assign sif.out_valid = sif.in_valid && valid_k;
    assign sif.code4 = valid_k ? selected4 : 4'b0000;

    assign ones4 = {2'b00, selected4[0]} + {2'b00, selected4[1]}
                 + {2'b00, selected4[2]} + {2'b00, selected4[3]};
    assign sif.rd_out = !valid_k ? sif.rd_mid :
                        ones4 > 2 ? 1'b1 :
                        ones4 < 2 ? 1'b0 : sif.rd_mid;
endmodule
