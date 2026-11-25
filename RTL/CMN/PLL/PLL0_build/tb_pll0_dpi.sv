module tb_pll0_dpi #(
    parameter real N = 10.0,
    parameter realtime REF_PERIOD_NS = 100.0,
    parameter realtime SETTLE_NS = 20_000.0,
    parameter real TOLERANCE_PCT = 2.0
);
    timeunit 1ns;
    timeprecision 1fs;

    localparam realtime MODEL_STEP = 25ps;
    localparam int MEASURE_PERIODS = 64;
    localparam real EXPECTED_MHZ = 1000.0 * N / REF_PERIOD_NS;

    bit clk = 0;
    bit wrapper_reset = 0;
    bit Fref = 0;
    byte unsigned rst_N = 0;
    wire [7:0] F_N;
    wire pll_clk = (F_N == 8'd1);

    PLL0_dpi dut (
        .clk        (clk),
        .clk_enable (1'b1),
        .reset      (wrapper_reset),
        .Fref       (Fref),
        .rst_N      (rst_N),
        .N          (N),
        .F_N        (F_N)
    );

    // Generated C advances by 25 ps on each rising edge of clk.
    always #(MODEL_STEP / 2.0) clk = ~clk;

    initial begin
        if (N < 2.0 || REF_PERIOD_NS <= 0.0 ||
            SETTLE_NS < 0.0 || TOLERANCE_PCT <= 0.0)
            $fatal(1, "Invalid PLL testbench parameters");

        // Offset reference transitions from the model clock's sample edges.
        @(negedge clk);
        forever begin
            #(REF_PERIOD_NS / 2.0);
            Fref = (Fref == 8'd0) ? 8'd1 : 8'd0;
        end
    end

    initial begin
        // Let the wrapper allocate its DPI object before pulsing reset.
        @(negedge clk);
        wrapper_reset = 1'b1;
        repeat (2) @(negedge clk);
        wrapper_reset = 1'b0;
        repeat (4) @(negedge clk);
        rst_N = 8'd1;
    end

    initial begin : measure_output
        realtime first_edge;
        realtime average_period_ns;
        real measured_mhz;
        real error_pct;

        wait (rst_N == 8'd1);
        #(SETTLE_NS);
        $display("Reference %.3f MHz, N %.4f, expected VCO %.3f MHz",
                 1000.0 / REF_PERIOD_NS, N, EXPECTED_MHZ);

        @(posedge pll_clk);
        first_edge = $realtime;
        repeat (MEASURE_PERIODS) @(posedge pll_clk);
        average_period_ns = ($realtime - first_edge) / MEASURE_PERIODS;
        measured_mhz = 1000.0 / average_period_ns;
        error_pct = 100.0 * (measured_mhz - EXPECTED_MHZ) / EXPECTED_MHZ;

        $display("Measured VCO %.3f MHz, average period %.6f ns, error %.3f%%",
                 measured_mhz, average_period_ns, error_pct);
        if (error_pct > TOLERANCE_PCT || error_pct < -TOLERANCE_PCT)
            $fatal(1, "Average VCO frequency outside +/-%.2f%%", TOLERANCE_PCT);

        $display("PASS: PLL output frequency within tolerance");
        $finish;
    end

    initial begin
        #(SETTLE_NS + (MEASURE_PERIODS + 10) * REF_PERIOD_NS + 1000.0);
        $fatal(1, "Timed out waiting for VCO edges on F_N");
    end
endmodule
