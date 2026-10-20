
`timescale 1ps/1fs

module tb_top_simple;

    logic clk = 0;
    real D_plus  = 0.0;
    real D_minus = 0.0;

    logic recovered_clk;
    logic recovered_data;

    localparam realtime UI = 200.0;

    // 5 GHz reference clock
    always #100 clk = ~clk;

    top dut (
        .clk(clk),
        .D_plus(D_plus),
        .D_minus(D_minus),
        .recovered_clk(recovered_clk),
        .recovered_data(recovered_data)
    );

    // Differential bit transmitter
    task automatic send_bit(input bit b);
        D_plus  = b ? 0.5 : -0.5;
        D_minus = b ? -0.5 : 0.5;
        #(UI);
    endtask

    integer sample_count = 0;
    integer errors = 0;
    bit checking = 0;
    bit expected_bit = 0;

    realtime last_edge = 0.0;

    // Check recovered clock and recovered data
    always @(posedge recovered_clk) begin
        realtime now_t;
        now_t = $realtime;

        if (checking) begin
            // recovered_data updates in NBA region
            #0.001;

            if (recovered_data !== expected_bit) begin
                errors++;
                $display(
                    "FAIL t=%0.3f ps expected=%b received=%b",
                    now_t, expected_bit, recovered_data
                );
            end
            else begin
                $display(
                    "PASS t=%0.3f ps bit=%b",
                    now_t, recovered_data
                );
            end

            if (last_edge != 0.0 &&
                now_t - last_edge != UI) begin
                errors++;
                $display(
                    "FAIL clock period=%0.3f ps",
                    now_t - last_edge
                );
            end

            last_edge = now_t;
            sample_count++;
        end
    end

    initial begin
        $timeformat(-12, 3, " ps", 10);

        $dumpfile("top_simple.vcd");
        $dumpvars(0, tb_top_simple);

        // Initial phase offset
        #50;

        $display("=== CRC ACQUISITION ===");

        // Alternating pattern for frequency acquisition
        repeat (12) begin
            send_bit(1);
            send_bit(0);
        end

        $display("Recovered interval = %0.3f ps", dut.wrapper_CDR_inst.crc_inst.min_t_diff);

        // Allow clock to settle
        repeat (3) send_bit(1);

        $display("=== DATA RECOVERY TEST ===");

        // Check bit values during known stable intervals.
        // expected_bit follows the currently driven bit.
        checking = 1;

        expected_bit = 1; send_bit(1);
        expected_bit = 0; send_bit(0);
        expected_bit = 1; send_bit(1);
        expected_bit = 1; send_bit(1);
        expected_bit = 0; send_bit(0);
        expected_bit = 0; send_bit(0);
        expected_bit = 1; send_bit(1);
        expected_bit = 0; send_bit(0);

        checking = 0;

        $display("=== FINAL RESULTS ===");
        $display("Samples checked = %0d", sample_count);
        $display("Errors = %0d", errors);

        if (errors == 0 && sample_count == 8)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end

endmodule
