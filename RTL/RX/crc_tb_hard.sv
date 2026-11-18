
`timescale 1ps/1fs

module tb_CRC_hard;

    logic clk = 0;
    real V_diff = 0.0;
    logic recovered_clk;

    localparam realtime BIT_PERIOD = 200.0;

    // 5 GHz reference clock
    always #100 clk = ~clk;

    CRC dut (
        .clk(clk),
        .V_diff(V_diff),
        .recovered_clk(recovered_clk)
    );

    // Transmit one ideal differential bit
    task automatic send_bit(input bit data_bit);
        V_diff = data_bit ? 0.5 : -0.5;
        #(BIT_PERIOD);
    endtask

    // Monitor recovered-clock rising edges
    realtime last_rising_edge = 0.0;
    integer clock_edges = 0;
    integer errors = 0;

    always @(posedge recovered_clk) begin
        realtime current_time;
        realtime measured_period;

        current_time = $realtime;

        if (clock_edges > 0) begin
            measured_period = current_time - last_rising_edge;

            if (dut.half_t == 100.0 &&
                measured_period != 200.0) begin

                $display(
                    "WARNING: Clock period = %0.2f ps at %0.2f ps",
                    measured_period, current_time
                );
            end
        end

        last_rising_edge = current_time;
        clock_edges++;

        $display(
            "SAMPLE: t=%0.2f ps | V_diff=%0.2f | recovered_clk=%b",
            current_time, V_diff, recovered_clk
        );
    end

    initial begin

        $timeformat(-12, 0, " ps", 10);

        $dumpfile("crc_hard.vcd");
        $dumpvars(0, tb_CRC_hard);

        // Initial offset: data is not aligned with clk
        #73;

        $display("\n===== TEST 1: LONG RUNS =====");

        // Long intervals before the first short interval
        repeat (8) send_bit(1);
        repeat (6) send_bit(0);
        repeat (5) send_bit(1);
        repeat (4) send_bit(0);

        $display("\n===== TEST 2: ALTERNATING DATA =====");

        // Reveal the true 200 ps bit period
        repeat (10) begin
            send_bit(1);
            send_bit(0);
        end

        $display("\n===== TEST 3: IRREGULAR PATTERN =====");

        send_bit(1);
        send_bit(1);
        send_bit(0);
        send_bit(1);
        send_bit(0);
        send_bit(0);
        send_bit(0);
        send_bit(1);
        send_bit(1);
        send_bit(0);
        send_bit(1);
        send_bit(1);
        send_bit(1);
        send_bit(0);

        $display("\n===== TEST 4: NO TRANSITIONS =====");

        // Clock should continue running
        repeat (20) send_bit(1);

        $display("\n===== TEST 5: TRANSITIONS RETURN =====");

        repeat (10) begin
            send_bit(0);
            send_bit(1);
        end

        #1000;

        $display("\n===== FINAL RESULTS =====");
        $display("min_t_diff = %0.2f ps", dut.min_t_diff);
        $display("half_t     = %0.2f ps", dut.half_t);
        $display("Clock edges detected = %0d", clock_edges);

        if (dut.min_t_diff == 200.0 &&
            dut.half_t == 100.0)
            $display("PASS: Correct bit period recovered");
        else begin
            $display("FAIL: Incorrect bit period");
            errors++;
        end

        $display("Errors = %0d", errors);

        $finish;
    end

endmodule
