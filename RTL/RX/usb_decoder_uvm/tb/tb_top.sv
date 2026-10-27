`timescale 1ns/1ps

module tb_top;

    import uvm_pkg::*;
    import decoder_pkg::*;

    bit clk = 1'b0;
    bit test_passed = 1'b0;

    usb_8b10b_decoder_if decoder_if(clk);

    usb_8b10b_decoder dut (
        .clk             (clk),
        .rst_n           (decoder_if.rst_n),
        .valid_in        (decoder_if.valid_in),
        .code_in         (decoder_if.code_in),
        .valid_out       (decoder_if.valid_out),
        .data_out        (decoder_if.data_out),
        .is_kcode        (decoder_if.is_kcode),
        .RxDataK         (decoder_if.RxDataK),
        .is_comma        (decoder_if.is_comma),
        .is_skip         (decoder_if.is_skip),
        .decode_error    (decoder_if.decode_error),
        .disparity_error (decoder_if.disparity_error)
    );

    always #5 clk = ~clk;

    initial begin
        #1ms;
        $fatal(1, "Decoder test timed out after 1 ms");
    end

    initial begin
        decoder_if.rst_n    = 1'b0;
        decoder_if.valid_in = 1'b0;
        decoder_if.code_in  = '0;
        repeat (5) @(negedge clk);
        decoder_if.rst_n = 1'b1;
    end

    initial begin
        uvm_report_server report_server;

        uvm_config_db#(virtual usb_8b10b_decoder_if.DRIVER)::set(
            null, "uvm_test_top.env.agent.driver", "vif", decoder_if
        );
        uvm_config_db#(virtual usb_8b10b_decoder_if.MONITOR)::set(
            null, "*", "vif", decoder_if
        );
        uvm_config_db#(virtual usb_8b10b_decoder_if)::set(
            null, "uvm_test_top", "reset_vif", decoder_if
        );

        uvm_top.finish_on_completion = 0;
        run_test();

        // Let run.do return a failing process status for UVM failures.
        report_server = uvm_report_server::get_server();
        test_passed = (report_server.get_severity_count(UVM_ERROR) == 0 &&
                       report_server.get_severity_count(UVM_FATAL) == 0);
        $finish;
    end

endmodule
