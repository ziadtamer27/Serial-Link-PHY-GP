module usb_descrambler (
    input  logic       clk,
    input  logic       rst_n,

    input  logic       valid_in,
    input  logic [7:0] data_in,

    input  logic       is_comma,
    input  logic       is_skip,
    input  logic       is_kcode,
    input  logic       training_sequence,

    output logic       valid_out,
    output logic [7:0] data_out
);

    logic [15:0] lfsr;
    logic [15:0] lfsr_next;
    logic [7:0]  descrambled_byte;

    always_comb begin
        descrambled_byte[0] = data_in[0] ^ lfsr[15];
        descrambled_byte[1] = data_in[1] ^ lfsr[14];
        descrambled_byte[2] = data_in[2] ^ lfsr[13];
        descrambled_byte[3] = data_in[3] ^ lfsr[12];
        descrambled_byte[4] = data_in[4] ^ lfsr[11];
        descrambled_byte[5] = data_in[5] ^ lfsr[10];
        descrambled_byte[6] = data_in[6] ^ lfsr[9];
        descrambled_byte[7] = data_in[7] ^ lfsr[8];
    end

    always_comb begin
        lfsr_next[0]  = lfsr[8];
        lfsr_next[1]  = lfsr[9];
        lfsr_next[2]  = lfsr[10];
        lfsr_next[3]  = lfsr[11] ^ lfsr[8];
        lfsr_next[4]  = lfsr[12] ^ lfsr[9] ^  lfsr[8];
        lfsr_next[5]  = lfsr[13] ^ lfsr[10] ^ lfsr[9] ^ lfsr[8];
        lfsr_next[6]  = lfsr[14] ^ lfsr[11] ^ lfsr[10] ^ lfsr[9];
        lfsr_next[7]  = lfsr[15] ^ lfsr[12] ^ lfsr[11] ^ lfsr[10];
        lfsr_next[8]  = lfsr[0] ^ lfsr[13] ^ lfsr[12] ^ lfsr[11];
        lfsr_next[9]  = lfsr[1] ^ lfsr[14] ^ lfsr[13] ^ lfsr[12];
        lfsr_next[10] = lfsr[2] ^ lfsr[15] ^ lfsr[14] ^ lfsr[13];
        lfsr_next[11] = lfsr[3] ^ lfsr[15] ^ lfsr[14];
        lfsr_next[12] = lfsr[4] ^ lfsr[15];
        lfsr_next[13] = lfsr[5];
        lfsr_next[14] = lfsr[6];
        lfsr_next[15] = lfsr[7];
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            lfsr      <= 16'hFFFF;
            data_out  <= 8'h00;
            valid_out <= 1'b0;
        end else begin
            valid_out <= 1'b0;

            if (valid_in) begin
                if (is_comma) begin
                    lfsr      <= 16'hFFFF;
                    data_out  <= data_in;
                    valid_out <= 1'b1;
                end else if (is_skip) begin
                    data_out  <= data_in;
                    valid_out <= 1'b1;
                end else begin
                    lfsr <= lfsr_next;

                    if (!is_kcode && !training_sequence)
                        data_out <= descrambled_byte;
                    else
                        data_out <= data_in;

                    valid_out <= 1'b1;
                end
            end
        end
    end

endmodule
