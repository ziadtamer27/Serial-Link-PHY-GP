module usb_8b10b_decoder (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       valid_in,
    input  logic [9:0] code_in,

    output logic       valid_out,
    output logic [7:0] data_out,
    output logic       is_kcode,
    output logic       RxDataK,
    output logic       is_comma,
    output logic       is_skip,
    output logic       decode_error,
    output logic       disparity_error
);
    // RD=0 means negative, RD=1 means positive
    logic running_disparity;
    logic rd_known;
    logic [9:0] symbol;
    logic [5:0] six;
    logic [3:0] four;
    logic [4:0] x;
    logic [2:0] y;
    logic six_valid, four_valid;
    logic legal_negative, legal_positive;
    logic decoded_k;
    logic [7:0] decoded_byte;
    logic incoming_rd, next_rd;
    integer ones_six;
    integer i;

    assign RxDataK = is_kcode;

    assign symbol = {<<{code_in}};
    assign six  = symbol[9:4];
    assign four = symbol[3:0];

    always_comb begin // 6b -> 5b
        six_valid = 1'b1;
        x = 5'd0;
        case (six)
            6'b100111, 6'b011000: x = 5'd0;
            6'b011101, 6'b100010: x = 5'd1;
            6'b101101, 6'b010010: x = 5'd2;
            6'b110001:            x = 5'd3;
            6'b110101, 6'b001010: x = 5'd4;
            6'b101001:            x = 5'd5;
            6'b011001:            x = 5'd6;
            6'b111000, 6'b000111: x = 5'd7;
            6'b111001, 6'b000110: x = 5'd8;
            6'b100101:            x = 5'd9;
            6'b010101:            x = 5'd10;
            6'b110100:            x = 5'd11;
            6'b001101:            x = 5'd12;
            6'b101100:            x = 5'd13;
            6'b011100:            x = 5'd14;
            6'b010111, 6'b101000: x = 5'd15;
            6'b011011, 6'b100100: x = 5'd16;
            6'b100011:            x = 5'd17;
            6'b010011:            x = 5'd18;
            6'b110010:            x = 5'd19;
            6'b001011:            x = 5'd20;
            6'b101010:            x = 5'd21;
            6'b011010:            x = 5'd22;
            6'b111010, 6'b000101: x = 5'd23;
            6'b110011, 6'b001100: x = 5'd24;
            6'b100110:            x = 5'd25;
            6'b010110:            x = 5'd26;
            6'b110110, 6'b001001: x = 5'd27;
            6'b001110:            x = 5'd28;
            6'b101110, 6'b010001: x = 5'd29;
            6'b011110, 6'b100001: x = 5'd30;
            6'b101011, 6'b010100: x = 5'd31;
            default: six_valid = 1'b0;
        endcase
    end

    always_comb begin // 4b -> 3b
        four_valid = 1'b1;
        y = 3'd0;
        case (four)
            4'b1011, 4'b0100: y = 3'd0;
            4'b1001:          y = 3'd1;
            4'b0101:          y = 3'd2;
            4'b1100, 4'b0011: y = 3'd3;
            4'b1101, 4'b0010: y = 3'd4;
            4'b1010:          y = 3'd5;
            4'b0110:          y = 3'd6;
            4'b1110, 4'b0001, 4'b0111, 4'b1000: y = 3'd7; // if there is 5 or more consecitive ones or zeros this is not allowed to we use alternative representation 
            default: four_valid = 1'b0;
        endcase
    end
    // compare the four we recived againist the expected 4 we should have from rd after 6
    function automatic logic [3:0] expected_four (input logic [2:0] hi,input logic [4:0] lo,input logic rd_after_six); 
        case (hi)
            3'd0: expected_four = rd_after_six ? 4'b0100 : 4'b1011;
            3'd1: expected_four = 4'b1001;
            3'd2: expected_four = 4'b0101;
            3'd3: expected_four = rd_after_six ? 4'b0011 : 4'b1100;
            3'd4: expected_four = rd_after_six ? 4'b0010 : 4'b1101;
            3'd5: expected_four = 4'b1010;
            3'd6: expected_four = 4'b0110;
            3'd7: begin
                if (!rd_after_six && (lo == 17 || lo == 18 || lo == 20))
                    expected_four = 4'b0111;
                else if (rd_after_six && (lo == 11 || lo == 13 || lo == 14))
                    expected_four = 4'b1000;
                else
                    expected_four = rd_after_six ? 4'b0001 : 4'b1110;
            end
            default: expected_four = 4'b0000;
        endcase
    endfunction

    // count the rd of total symbol and perserve the running disparity if both balanced
    function automatic logic update_rd (input logic [9:0] received_symbol,input logic rd_in);
        integer count6, count4, bit_index;
        logic rd;
        begin
            count6 = 0;
            count4 = 0;
            for (bit_index = 4; bit_index < 10; bit_index = bit_index + 1)
                count6 = count6 + int'(received_symbol[bit_index]);
            for (bit_index = 0; bit_index < 4; bit_index = bit_index + 1)
                count4 = count4 + int'(received_symbol[bit_index]);
            rd = rd_in;
            if (count6 > 3) rd = 1'b1;
            if (count6 < 3) rd = 1'b0;
            if (count4 > 2) rd = 1'b1;
            if (count4 < 2) rd = 1'b0;
            update_rd = rd;
        end
    endfunction

    always_comb begin
        ones_six = 0;
        for (i = 0; i < 6; i = i + 1)
            ones_six = ones_six + int'(six[i]);

        decoded_byte = {y, x};
        decoded_k = 1'b0;
        legal_negative = 1'b0;
        legal_positive = 1'b0;

        if (six_valid && four_valid) begin
            // is symbol positive in running disparity negitive ? 
            legal_negative = (ones_six >= 3) && (six != 6'b000111) && (four == expected_four(y, x, (ones_six > 3))); // 000111 it appears to be balanced but ref treat it as negitive
            legal_positive = (ones_six <= 3) && (six != 6'b111000) && (four == expected_four(y, x, (ones_six == 3)));
        end

        // All 12 K characters 
        case (symbol)
            10'b001111_0100: begin decoded_byte=8'h1C; decoded_k=1'b1; legal_negative=1'b1; end
            10'b001111_1001: begin decoded_byte=8'h3C; decoded_k=1'b1; legal_negative=1'b1; end
            10'b001111_0101: begin decoded_byte=8'h5C; decoded_k=1'b1; legal_negative=1'b1; end
            10'b001111_0011: begin decoded_byte=8'h7C; decoded_k=1'b1; legal_negative=1'b1; end
            10'b001111_0010: begin decoded_byte=8'h9C; decoded_k=1'b1; legal_negative=1'b1; end
            10'b001111_1010: begin decoded_byte=8'hBC; decoded_k=1'b1; legal_negative=1'b1; end
            10'b001111_0110: begin decoded_byte=8'hDC; decoded_k=1'b1; legal_negative=1'b1; end
            10'b001111_1000: begin decoded_byte=8'hFC; decoded_k=1'b1; legal_negative=1'b1; end
            10'b111010_1000: begin decoded_byte=8'hF7; decoded_k=1'b1; legal_negative=1'b1; end
            10'b110110_1000: begin decoded_byte=8'hFB; decoded_k=1'b1; legal_negative=1'b1; end
            10'b101110_1000: begin decoded_byte=8'hFD; decoded_k=1'b1; legal_negative=1'b1; end
            10'b011110_1000: begin decoded_byte=8'hFE; decoded_k=1'b1; legal_negative=1'b1; end
            10'b110000_1011: begin decoded_byte=8'h1C; decoded_k=1'b1; legal_positive=1'b1; end
            10'b110000_0110: begin decoded_byte=8'h3C; decoded_k=1'b1; legal_positive=1'b1; end
            10'b110000_1010: begin decoded_byte=8'h5C; decoded_k=1'b1; legal_positive=1'b1; end
            10'b110000_1100: begin decoded_byte=8'h7C; decoded_k=1'b1; legal_positive=1'b1; end
            10'b110000_1101: begin decoded_byte=8'h9C; decoded_k=1'b1; legal_positive=1'b1; end
            10'b110000_0101: begin decoded_byte=8'hBC; decoded_k=1'b1; legal_positive=1'b1; end
            10'b110000_1001: begin decoded_byte=8'hDC; decoded_k=1'b1; legal_positive=1'b1; end
            10'b110000_0111: begin decoded_byte=8'hFC; decoded_k=1'b1; legal_positive=1'b1; end
            10'b000101_0111: begin decoded_byte=8'hF7; decoded_k=1'b1; legal_positive=1'b1; end
            10'b001001_0111: begin decoded_byte=8'hFB; decoded_k=1'b1; legal_positive=1'b1; end
            10'b010001_0111: begin decoded_byte=8'hFD; decoded_k=1'b1; legal_positive=1'b1; end
            10'b100001_0111: begin decoded_byte=8'hFE; decoded_k=1'b1; legal_positive=1'b1; end
            default: begin end
        endcase

        incoming_rd = running_disparity; // disparity when symbol was recived
        if (legal_negative && !legal_positive) incoming_rd = 1'b0;
        if (legal_positive && !legal_negative) incoming_rd = 1'b1;
        next_rd = update_rd(symbol, incoming_rd); // update it according to current symbol or perserve the current disparity
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            running_disparity <= 1'b0;
            rd_known          <= 1'b0;
            rd_known          <= 1'b0; // if == 1 then it means the running disparity is trustworthy
            valid_out         <= 1'b0;
            data_out          <= 8'h00;
            is_kcode          <= 1'b0;
            is_comma          <= 1'b0;
            is_skip           <= 1'b0;
            decode_error        <= 1'b0;
            disparity_error   <= 1'b0;
        end else begin
            valid_out       <= valid_in;
            is_kcode        <= 1'b0;
            is_comma        <= 1'b0;
            is_skip         <= 1'b0;
            decode_error      <= 1'b0;
            disparity_error <= 1'b0;
            if (valid_in) begin
                if (legal_negative || legal_positive) begin
                    data_out <= decoded_byte;
                    is_kcode <= decoded_k;
                    is_comma <= decoded_k && (decoded_byte == 8'hBC);
                    is_skip  <= decoded_k && (decoded_byte == 8'h3C);
                    disparity_error <= rd_known && !(running_disparity ? legal_positive : legal_negative);
                    running_disparity <= next_rd;
                    if (legal_negative != legal_positive)
                        rd_known <= 1'b1;
                end else begin
                    data_out   <= 8'h9C; // K28.4 / SUB
                    is_kcode   <= 1'b1;
                    decode_error <= 1'b1;
                    rd_known   <= 1'b0;
                end
            end
        end
    end
endmodule