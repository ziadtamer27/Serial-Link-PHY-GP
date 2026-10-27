module top (
    input  logic       clk,
    input  real        D_plus,
    input  real        D_minus,
    input  logic       rst_n,
    input  logic       Rx_Polarity,

    output logic       recovered_clk,
    output logic       recovered_data,
    output logic [9:0] parallel_data,
    output logic       symbol_valid,
    output logic       recovered_symbol_clk
);

     real V_diff;

    logic [9:0] candidate_window;
    logic symbol_align;

    // Differential receiver
    diff_receiver diff_receiver_inst (
        .D_plus(D_plus),
        .D_minus(D_minus),
        .V_diff(V_diff)
    );

    // Clock and data recovery
    wrapper_CDR wrapper_CDR_inst (
        .clk(clk),
        .V_diff(V_diff),
        .recovered_clk(recovered_clk),
        .recovered_data(recovered_data)
    );

    // Serial-to-parallel converter
    serial_to_parallel s2p_inst (
        .recovered_clk(recovered_clk),
        .recovered_data(recovered_data),
        .rst_n(rst_n),
        .Rx_Polarity(Rx_Polarity),
        .symbol_align(symbol_align),
        .candidate_window(candidate_window),
        .parallel_data(parallel_data),
        .symbol_valid(symbol_valid)
    );

    // K28.5 detector
    symbol_detector k28_inst (
        .recovered_clk(recovered_clk),
        .rst_n(rst_n),
        .candidate_window(candidate_window),
        .symbol_align(symbol_align),
        .recovered_symbol_clk(recovered_symbol_clk)
    );

endmodule
