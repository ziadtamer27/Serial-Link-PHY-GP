interface ser_if (input bit pclk, input bit bit_rate_clk);

    logic       rst_n;
    logic       enable;
    logic [9:0] parallel_data;
    logic       serial_out;

    // Driver: drive DUT inputs just before posedge
    clocking drv_cb @(posedge pclk);
        default output #1step;
        output rst_n;
        output enable;
        output parallel_data;
    endclocking

    // Monitor: sample DUT signals before posedge
    clocking mon_cb @(posedge bit_rate_clk);
        default input #0;
        input rst_n;
        input enable;
        input parallel_data;
        input serial_out;
    endclocking

    modport drv (input pclk, output rst_n, output enable, output parallel_data);
    modport mon (input pclk, input bit_rate_clk, input rst_n, input enable, input parallel_data, input serial_out);
    modport dut (input pclk, input bit_rate_clk, input rst_n, input enable, input parallel_data, output serial_out);

endinterface
//clk in each block needed to be checked