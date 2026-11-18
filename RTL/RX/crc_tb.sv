`timescale 1ps/1fs
module tb_CRC;
    logic clk = 0;
    real V_diff = 0.0;
    logic recovered_clk;

    // 5 GHz reference clock: period = 200 ps
    always #100 clk = ~clk;

    // Your CRC
    CRC dut (
        .clk(clk),
        .V_diff(V_diff),
        .recovered_clk(recovered_clk)
    );

    // Transmit one bit every 200 ps
    task automatic send_bit(input bit data_bit);
        V_diff = data_bit ? 0.5 : -0.5;
        #200;
    endtask

    initial begin
        $dumpfile("crc_test.vcd");
        $dumpvars(0, tb_CRC);

        // Offset data transitions from reference clock
        #50;

        // Initial long intervals
        send_bit(1);
        send_bit(1);
        send_bit(1);
        send_bit(0);
        send_bit(0);
        send_bit(1);

        // Consecutive alternating bits
        send_bit(0);
        send_bit(1);
        send_bit(0);
        send_bit(1);
        send_bit(0);
        send_bit(1);

        // Another sequence with repeated bits
        send_bit(1);
        send_bit(1);
        send_bit(0);
        send_bit(0);
        send_bit(1);
        send_bit(0);
        send_bit(1);
        send_bit(0);

        #1000;
        $finish;
    end

    initial begin
        $monitor(
            "Time=%0t ps | V_diff=%0.2f | min_t_diff=%0.2f | half_t=%0.2f | recovered_clk=%b",
            $time, V_diff, dut.min_t_diff,
            dut.half_t, recovered_clk
        );
    end

endmodule
