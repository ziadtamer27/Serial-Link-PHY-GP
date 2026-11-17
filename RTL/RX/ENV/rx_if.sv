`ifndef RX_IF_SV
`define RX_IF_SV

interface rx_if(input clk);
    real        D_plus,
    real        D_minus,
    logic       rst_n,
    logic       Rx_Polarity,

    logic       recovered_clk,
    logic       recovered_data,
    logic [9:0] parallel_data,
    logic       symbol_valid,
    logic       recovered_symbol_clk
endinterface

`endif