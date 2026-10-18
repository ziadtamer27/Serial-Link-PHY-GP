
module encoder_5b6b_ref (encoder_5b6b_if.DUT sif);

    logic [4:0] x;
    logic [5:0] code6_next;
    logic [2:0] ones_count;

    assign x = sif.in_data[4:0];

    // 5b/6b Encoding
    always_comb begin
        code6_next = 6'b000000;

        // Special K28.x encoding
        if (sif.in_is_k && (x == 5'd28)) begin
            code6_next = sif.rd_in ?
                         6'b110000 : 6'b001111;
        end
        else begin
            case (x)
                5'd0:  code6_next = sif.rd_in ? 6'b011000 : 6'b100111;
                5'd1:  code6_next = sif.rd_in ? 6'b100010 : 6'b011101;
                5'd2:  code6_next = sif.rd_in ? 6'b010010 : 6'b101101;
                5'd3:  code6_next = sif.rd_in ? 6'b110001 : 6'b110001;
                5'd4:  code6_next = sif.rd_in ? 6'b001010 : 6'b110101;
                5'd5:  code6_next = sif.rd_in ? 6'b101001 : 6'b101001;
                5'd6:  code6_next = sif.rd_in ? 6'b011001 : 6'b011001;
                5'd7:  code6_next = sif.rd_in ? 6'b000111 : 6'b111000;
                5'd8:  code6_next = sif.rd_in ? 6'b000110 : 6'b111001;
                5'd9:  code6_next = sif.rd_in ? 6'b100101 : 6'b100101;
                5'd10: code6_next = sif.rd_in ? 6'b010101 : 6'b010101;
                5'd11: code6_next = sif.rd_in ? 6'b110100 : 6'b110100;
                5'd12: code6_next = sif.rd_in ? 6'b001101 : 6'b001101;
                5'd13: code6_next = sif.rd_in ? 6'b101100 : 6'b101100;
                5'd14: code6_next = sif.rd_in ? 6'b011100 : 6'b011100;
                5'd15: code6_next = sif.rd_in ? 6'b101000 : 6'b010111;
                5'd16: code6_next = sif.rd_in ? 6'b100100 : 6'b011011;
                5'd17: code6_next = sif.rd_in ? 6'b100011 : 6'b100011;
                5'd18: code6_next = sif.rd_in ? 6'b010011 : 6'b010011;
                5'd19: code6_next = sif.rd_in ? 6'b110010 : 6'b110010;
                5'd20: code6_next = sif.rd_in ? 6'b001011 : 6'b001011;
                5'd21: code6_next = sif.rd_in ? 6'b101010 : 6'b101010;
                5'd22: code6_next = sif.rd_in ? 6'b011010 : 6'b011010;
                5'd23: code6_next = sif.rd_in ? 6'b000101 : 6'b111010;
                5'd24: code6_next = sif.rd_in ? 6'b001100 : 6'b110011;
                5'd25: code6_next = sif.rd_in ? 6'b100110 : 6'b100110;
                5'd26: code6_next = sif.rd_in ? 6'b010110 : 6'b010110;
                5'd27: code6_next = sif.rd_in ? 6'b001001 : 6'b110110;
                5'd28: code6_next = sif.rd_in ? 6'b001110 : 6'b001110;
                5'd29: code6_next = sif.rd_in ? 6'b010001 : 6'b101110;
                5'd30: code6_next = sif.rd_in ? 6'b100001 : 6'b011110;
                5'd31: code6_next = sif.rd_in ? 6'b010100 : 6'b101011;
                default: code6_next = 6'b000000;
            endcase
        end
    end

    // Count number of ones in encoded 6-bit symbol
    always_comb begin
        ones_count = 3'd0;

        for (int i = 0; i < 6; i++) begin
            ones_count = ones_count + {2'b00, code6_next[i]};
        end
    end

    // Output encoded 6-bit symbol
    assign sif.code6 = code6_next;

    // Valid signal propagation
    assign sif.out_valid = sif.in_valid;

    // Intermediate Running Disparity
    // RD- = 0, RD+ = 1
    assign sif.rd_mid =
        (ones_count > 3) ? 1'b1 :
        (ones_count < 3) ? 1'b0 :
                           sif.rd_in;

endmodule
