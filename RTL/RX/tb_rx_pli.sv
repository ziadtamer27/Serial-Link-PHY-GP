`timescale 1ps/1fs

module tb_rx_pli;

    // MATLAB parameters
    localparam real SAMPLE_PERIOD_PS = 100.0;
    localparam real BIT_PERIOD_PS    = 400.0;

    localparam int EXPECTED_SAMPLES = 1280;

    // DUT inputs
    logic clk = 0;
    real D_plus;
    real D_minus;

    // DUT outputs
    logic recovered_clk;
    logic recovered_data;

    // VPI status
    integer valid;
    integer sample_count;

    // DUT
    top dut (
        .clk(clk),
        .D_plus(D_plus),
        .D_minus(D_minus),
        .recovered_clk(recovered_clk),
        .recovered_data(recovered_data)
    );

    // Reference clock for CDR
    // Example: 10 GHz reference clock
    always #50 clk = ~clk;

    // MATLAB waveform stimulus
    initial begin

        D_plus = 0.0;
        D_minus = 0.0;

        valid = 0;
        sample_count = 0;

        // Load MATLAB file through C VPI
        $rx_load("D:/DIGITAL/Serial-Link-PHY-GP/RTL/RX/rx_in_real.txt");

        $display("==================================");
        $display(" MATLAB -> C VPI -> RX Simulation ");
        $display("==================================");

        for (int i = 0; i < EXPECTED_SAMPLES; i++) begin

            // Call C-based VPI task
            $rx_next(D_plus, D_minus, valid);

            if (!valid) begin
                $display("Unexpected end of waveform");
                break;
            end

            sample_count++;

            // Allow combinational RX logic to update
            #1;

            $display(
                "Time=%0t ps | Sample=%0d | D+=%f | D-=%f | Vdiff=%f | RX_CLK=%b | RX_DATA=%b",
                $time,
                sample_count,
                D_plus,
                D_minus,
                D_plus-D_minus,
                recovered_clk,
                recovered_data
            );

            // Complete 100 ps sample interval
            #99;

        end

        $display("----------------------------------");
        $display("Total samples = %0d", sample_count);
        $display("Simulation completed");
        $display("----------------------------------");

        #1000;
        $finish;

    end

endmodule
