`timescale 1ps/1fs

module tb_top_advanced;

logic clk = 0;
    real D_plus  = 0.0;
    real D_minus = 0.0;

logic recovered_clk;
    logic recovered_data;

localparam realtime UI = 200.0;
    localparam int MAX_BITS = 500;

bit expected_bits [0:MAX_BITS-1];
    integer tx_count = 0;
    integer rx_count = 0;
    integer errors = 0;

bit checking = 0;
    bit current_bit = 0;

    realtime previous_edge = 0.0;

    always #100 clk = ~clk;

top dut (
        .clk(clk),
        .D_plus(D_plus),
        .D_minus(D_minus),
        .recovered_clk(recovered_clk),
        .recovered_data(recovered_data)
    );

task automatic transmit(input bit b);
        D_plus  = b ? 0.5 : -0.5;
        D_minus = b ? -0.5 : 0.5;
        current_bit = b;

if (checking) begin
            expected_bits[tx_count] = b;
            tx_count++;
        end

#(UI);
    endtask

task automatic transmit_random(input int count);
        bit b;
        repeat (count) begin
            b = $urandom_range(0, 1);
            transmit(b);
        end
    endtask

// Clock and data checker
    always @(posedge recovered_clk) begin
        realtime edge_time;
        edge_time = $realtime;

        if (checking) begin

// Allow nonblocking assignment in DRC to complete
            #0.001;

            if (rx_count <tx_count) begin
                if (recovered_data !== expected_bits[rx_count]) begin
                    errors++;
                    $display(
                        "ERROR bit=%0d t=%0.3f ps expected=%b received=%b",
                        rx_count, edge_time,
                        expected_bits[rx_count],
                        recovered_data
                    );
                end
                rx_count++;
            end

if (previous_edge != 0.0 &&
                edge_time - previous_edge != UI) begin
                errors++;
                $display(
                    "CLOCK ERROR t=%0.3f ps period=%0.3f ps",
                    edge_time, edge_time - previous_edge
                );
            end

previous_edge = edge_time;
        end
    end

initial begin
        bit random_bit;

        $timeformat(-12, 3, " ps", 10);

$dumpfile("top_advanced.vcd");
        $dumpvars(0, tb_top_advanced);

        #73;

        $display("=== PHASE 1: LONG RUNS BEFORE ACQUISITION ===");

        repeat (12) transmit(1);
        repeat (8)  transmit(0);
        repeat (6)  transmit(1);

        $display("=== PHASE 2: ACQUIRE 200 ps PERIOD ===");

repeat (20) begin
            transmit(1);
            transmit(0);
        end

// Give the CRC time to settle
        repeat (4) transmit(1);

        $display("=== PHASE 3: START CHECKING ===");

        checking = 1;

        $display("=== PHASE 4: ALTERNATING DATA ===");

repeat (20) begin
            transmit(1);
            transmit(0);
        end

        $display("=== PHASE 5: LONG RUN WITHOUT TRANSITIONS ===");

repeat (40) transmit(1);
        repeat (40) transmit(0);

        $display("=== PHASE 6: RANDOM DATA ===");

        transmit_random(100);

        $display("=== PHASE 7: TRANSITIONS RETURN ===");

repeat (20) begin
            transmit(0);
            transmit(1);
        end

        checking = 0;

$display("\n=== FINAL RESULTS ===");
        $display("Transmitted bits = %0d", tx_count);
        $display("Recovered bits   = %0d", rx_count);
        $display("Errors           = %0d", errors);

if (errors == 0 && rx_count == tx_count)
            $display("ADVANCED TEST PASSED");
        else
            $display("ADVANCED TEST FAILED");

$finish;
    end

endmodule