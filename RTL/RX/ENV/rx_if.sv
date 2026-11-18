timeunit 1ps;
timeprecision 1fs;

`ifndef RX_IF_SV
`define RX_IF_SV

interface rx_if(input clk);
    real        D_plus;
    real        D_minus;
    logic       rst_n;
    logic       Rx_Polarity;

    logic       recovered_clk;
    logic       recovered_data;
    logic [9:0] parallel_data;
    logic       symbol_valid;
    logic       recovered_symbol_clk;

    // Drive each bit at the reference-clock falling edge
    clocking drive_cb @(negedge clk);
        default output #0;
        output D_plus, D_minus;
        output rst_n, Rx_Polarity;
    endclocking

    // Sample the incoming bit at its nominal center
    clocking input_cb @(posedge clk);
        default input #1step;
        input D_plus, D_minus;
        input rst_n, Rx_Polarity;
    endclocking

    // Sample DUT outputs after the recovered-clock rising edge
    clocking output_cb @(negedge recovered_clk);
        default input #1step;
        input rst_n;
        input recovered_data;
        input parallel_data;
        input symbol_valid;
        input recovered_symbol_clk;
    endclocking

endinterface

`endif