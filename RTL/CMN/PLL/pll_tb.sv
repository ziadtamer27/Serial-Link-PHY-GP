module tb_pll;
    timeunit 1ns / 1ps;

    localparam int  N = 2;
    localparam real EXPECTED_FB_PERIOD_NS = 20.0;
    localparam real PERIOD_TOLERANCE_NS   = 0.10;
    localparam int  MEASURE_CYCLES        = 32;

    logic fref  = 1'b0;
    logic rst_n = 1'b1;

    wire up;
    wire dn;
    wire vco_clk;
    wire fb_clk;

    real i_pump;
    real vctrl;
    real vco_freq_hz;

    pfd pfd_inst (
        .fref (fref),
        .fvco_N (fb_clk),
        .up   (up),
        .dn   (dn)
    );

    charge_pump #(
        .I_CP (100.0e-6)
    ) cp_inst (
        .up     (up),
        .dn     (dn),
        .i_pump (i_pump)
    );

    loop_filter #(
        .C_FARADS (10.0e-12),
        .R_OHMS   (1000.0),
        .V_INIT   (0.5)
    ) lf_inst (
        .i_pump (i_pump),
        .vctrl  (vctrl)
    );

    vco #(
        .K     (50.0e6),
        .FBIAS (95.0e6),
        .VBIAS (0.5)
    ) vco_inst (
        .vctrl   (vctrl),
        .vco_clk (vco_clk),
        .fvco    (vco_freq_hz)
    );

    freq_divider #(
        .N (N)
    ) div_inst (
        .vco_clk   (vco_clk),
        .rst_n     (rst_n),
        .vco_clk_N (fb_clk)
    );

    // 50 MHz reference: 20 ns per cycle.
    always #10ns fref = ~fref;

    initial begin
        // Reset the divider and pulse the PFD's internal reset.
        force pfd_inst.rst = 1'b0;
        #1ns;
        rst_n = 1'b0;
        force pfd_inst.rst = 1'b1;
        #1ns;
        release pfd_inst.rst;
        rst_n = 1'b1;
    end

    initial begin : check_feedback_frequency
        realtime first_edge;
        real avg_period_ns;

        // Allow the loop to settle, then measure the actual feedback edges.
        #10us;
        @(posedge fb_clk);
        first_edge = $realtime;

        repeat (MEASURE_CYCLES) @(posedge fb_clk);
        avg_period_ns = ($realtime - first_edge) / MEASURE_CYCLES;

        $display("Average feedback period = %0.4f ns", avg_period_ns);
        $display("Measured feedback frequency = %0.3f MHz",
                 1000.0 / avg_period_ns);

        if (avg_period_ns < EXPECTED_FB_PERIOD_NS - PERIOD_TOLERANCE_NS ||
            avg_period_ns > EXPECTED_FB_PERIOD_NS + PERIOD_TOLERANCE_NS)
            $fatal(1, "Feedback period did not settle near 20 ns");

        $display("PASS: Feedback frequency settled near 50 MHz");
        $finish;
    end

    initial begin
        #20us;
        $fatal(1, "Timed out waiting for the feedback period measurement");
    end
endmodule