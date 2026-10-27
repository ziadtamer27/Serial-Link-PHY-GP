
interface usb_8b10b_decoder_if (input logic clk);

    // DUT Inputs
    logic       rst_n;
    logic       valid_in;
    logic [9:0] code_in;

    // DUT Outputs
    logic       valid_out;
    logic [7:0] data_out;
    logic       is_kcode;
    logic       RxDataK;
    logic       is_comma;
    logic       is_skip;
    logic       decode_error;
    logic       disparity_error;


    // Driver Clocking Block
    clocking drv_cb @(posedge clk);

        default input #1step output #0;

        input  rst_n;

        output valid_in;
        output code_in;

    endclocking


    // Monitor Clocking Block
    clocking mon_cb @(posedge clk);

        default input #1step;

        input rst_n;
        input valid_in;
        input code_in;

        input #0 valid_out;
        input #0 data_out;
        input #0 is_kcode;
        input #0 RxDataK;
        input #0 is_comma;
        input #0 is_skip;
        input #0 decode_error;
        input #0 disparity_error;

    endclocking


    // DUT Modport
    modport DUT (
        input  clk,
        input  rst_n,
        input  valid_in,
        input  code_in,

        output valid_out,
        output data_out,
        output is_kcode,
        output RxDataK,
        output is_comma,
        output is_skip,
        output decode_error,
        output disparity_error
    );


    // Driver Modport
    modport DRIVER (
        clocking drv_cb,
        input rst_n
    );


    // Monitor Modport
    modport MONITOR (
        clocking mon_cb,
        input rst_n
    );

endinterface
