module TX_Wrapper (

    // CLOCKS AND RESET
    input logic pclk,
    input logic bit_rate_clk_div10,
    input logic bit_rate_clk,
    input logic rst_n,

    // TRANSMITTER INPUTS
    input logic       tx_valid, //////
    input logic [7:0] tx_data,
    input logic       tx_data_k, //////

    // TRANSMITTER OUTPUTS
    output logic tx_p,
    output logic tx_n,

    // Debug / status outputs
    output logic tx_serial_out,
    output logic tx_invalid_k,  //////
    output logic tx_rd_positive //////
);

    // Encoder -> Serializer
    logic [9:0] encoded_data;
    logic       encoded_valid;

    // Serializer output
    logic serial_data;

    // 8b/10b ENCODER
    encoder_8b10b_top u_encoder (
        .clk         (bit_rate_clk_div10), // bit_rate_clk or bit_rate_clk_div10?
        .rst_n       (rst_n),

        .in_valid    (tx_valid),
        .in_data     (tx_data),
        .in_is_k     (tx_data_k),

        .out_valid   (encoded_valid),
        .out_data    (encoded_data),

        .invalid_k   (tx_invalid_k),
        .rd_positive (tx_rd_positive)
    );

    // assign fifo_clk = loopback ? rx_clk : bit_rate_clk_div10;
    // assign fifo_data = loopback ? rx_data : encoded_data;

    // fifo

    // PARALLEL-TO-SERIAL CONVERTER
    serializer u_serializer (
        .pclk          (pclk),
        .bit_rate_clk  (bit_rate_clk),
        .rst_n         (rst_n),

        .enable        (encoded_valid),
        .parallel_data (encoded_data),

        .serial_out    (serial_data)
    );

    assign tx_serial_out = serial_data;

    // TRANSMITTER DIFFERENTIAL DRIVER
    // Temprorarily using a simple assignment for the differential driver.
    assign tx_p = serial_data;
    assign tx_n = ~serial_data;

endmodule