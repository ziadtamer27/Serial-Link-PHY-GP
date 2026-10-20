interface ser_if (input bit clk);

    logic       rst_n;
    logic [9:0] parallel_data;
    logic       serial_out;

    // Driver: drive DUT inputs just before posedge
    clocking drv_cb @(posedge clk);
        default output #1step;
        output rst_n;
        output parallel_data;
    endclocking

    // Monitor: sample DUT signals before posedge
    clocking mon_cb @(posedge clk);
        default input #0;
        input rst_n;
        input parallel_data;
        input serial_out;
    endclocking
    
    modport drv (input clk, output rst_n, output parallel_data);
    modport mon (input clk, input rst_n, input parallel_data, input serial_out);

endinterface