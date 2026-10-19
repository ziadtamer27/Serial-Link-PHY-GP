`timescale 1ns / 1ps

interface encoder_if(input logic clk);

    logic       rst_n;

    // Input from scrambler
    logic       in_valid;
    logic [7:0] in_data;
    logic       in_is_k;

    // Encoder output
    logic       out_valid;
    logic [9:0] out_data;

    // Status
    logic       rd_positive;
    logic       invalid_k;

    // Clocking block for driver
    clocking drv_cb @(posedge clk);
        default input #1ps output #1ps;
        input  rst_n;
        output in_valid;
        output in_data;
        output in_is_k;
        input  out_valid;
        input  out_data;
        input  rd_positive;
        input  invalid_k;
    endclocking

    // Clocking block for monitor
    clocking mon_cb @(posedge clk);
        default input #1ps output #1ps;
        input rst_n;
        input in_valid;
        input in_data;
        input in_is_k;
        input out_valid;
        input out_data;
        input rd_positive;
        input invalid_k;
    endclocking

    modport DUT (
        input  clk,
        input  rst_n,
        input  in_valid,
        input  in_data,
        input  in_is_k,

        output out_valid,
        output out_data,
        output rd_positive,
        output invalid_k
    );

    modport DRV (clocking drv_cb, input clk);
    modport MON (clocking mon_cb, input clk);

endinterface
