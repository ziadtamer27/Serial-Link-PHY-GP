module encoder_top;
    timeunit 1ns;
    timeprecision 1ps;
    import uvm_pkg::*;
    import pack::*;
    import encoder_test_pkg::*;
    `include "uvm_macros.svh"
    logic clk = 0;
    always #5ns clk = ~clk;
    encoder_if encoder_if(clk);
    encoder_8b10b_top dut(
        .clk(clk), .rst_n(encoder_if.rst_n),
        .in_valid(encoder_if.in_valid), .in_data(encoder_if.in_data),
        .in_is_k(encoder_if.in_is_k), .out_valid(encoder_if.out_valid),
        .out_data(encoder_if.out_data), .invalid_k(encoder_if.invalid_k),
        .rd_positive(encoder_if.rd_positive)
    );

    initial begin
        encoder_if.rst_n = 0;
        encoder_if.in_valid = 0;
        encoder_if.in_data = 0;
        encoder_if.in_is_k = 0;
        uvm_config_db#(virtual encoder_if)::set(null,"*","ENC_IF",encoder_if);
        if ($test$plusargs("UVM_TESTNAME")) run_test();
        else run_test("encoder_regression_test");
    end

    initial begin
        #10ms;
        `uvm_fatal("ENC_TIMEOUT", "Watchdog: test failed to finish within 10 ms")
    end

endmodule