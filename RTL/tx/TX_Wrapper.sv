module TX_Wrapper #(
    parameter int DATA_WIDTH = 8,
    localparam int K_WIDTH = DATA_WIDTH / 8
)(
    // CLOCKS AND RESET
    input logic pclk,
    input logic bit_rate_clk,
    input logic rst_n,

    // TRANSMITTER INPUTS
    input logic                  tx_valid,
    input logic [DATA_WIDTH-1:0] tx_data,
    input logic [K_WIDTH-1:0]    tx_data_k,

    // TRANSMITTER OUTPUTS
    output logic tx_p,
    output logic tx_n,

    // DEBUG / STATUS OUTPUTS
    output logic tx_serial_out,
    output logic tx_invalid_k,
    output logic tx_rd_positive
);

    // ==========================================
    // CLOCK DIVIDER
    // ==========================================

    logic bit_rate_clk_div10;
    logic [3:0] div_counter;

    always_ff @(posedge bit_rate_clk or negedge rst_n) begin
        if (!rst_n) begin
            div_counter        <= 4'd0;
            bit_rate_clk_div10 <= 1'b0;
        end
        else begin
            if (div_counter == 4'd4) begin
                div_counter        <= 4'd0;
                bit_rate_clk_div10 <= ~bit_rate_clk_div10;
            end
            else begin
                div_counter <= div_counter + 1'b1;
            end
        end
    end

    // ==========================================
    // INTERNAL SIGNALS
    // ==========================================

    // Optional -> Encoder
    logic [7:0] encoder_data;
    logic       encoder_k;
    logic       encoder_valid;

    // Encoder -> Serializer
    logic [9:0] serializer_data;
    logic       serializer_valid;

    // Serializer output
    logic serial_data;

    // ==========================================
    // OPTIONAL WIDTH CONVERSION
    // ==========================================

    optional #(
        .DATA_WIDTH(DATA_WIDTH)
    ) optional_inst (
        .pclk       (pclk),
        .symbol_clk (bit_rate_clk_div10),
        .rst_n      (rst_n),
        .enable     (tx_valid),

        .tx_data    (tx_data),
        .tx_data_k  (tx_data_k),

        .data_out   (encoder_data),
        .k_out      (encoder_k),
        .valid_out  (encoder_valid)
    );

    // ==========================================
    // 8b/10b ENCODER
    // ==========================================

    encoder_8b10b_top u_encoder (
        .clk         (bit_rate_clk_div10),
        .rst_n       (rst_n),

        .in_valid    (encoder_valid),
        .in_data     (encoder_data),
        .in_is_k     (encoder_k),

        .out_valid   (serializer_valid),
        .out_data    (serializer_data),

        .invalid_k   (tx_invalid_k),
        .rd_positive (tx_rd_positive)
    );

    // ==========================================
    // LOOPBACK (Future implementation)
    // ==========================================


    // ==========================================
    // PARALLEL-TO-SERIAL CONVERTER
    // ==========================================

    serializer u_serializer (
        .bit_rate_clk_div10 (bit_rate_clk_div10),
        .bit_rate_clk       (bit_rate_clk),
        .rst_n              (rst_n),

        .enable             (serializer_valid),
        .parallel_data      (serializer_data),

        .serial_out         (serial_data)
    );

    // ==========================================
    // DIFFERENTIAL DRIVER
    // ==========================================

    assign tx_serial_out = serial_data;

    assign tx_p =  serial_data;
    assign tx_n = ~serial_data;

endmodule