`timescale 1ps/1fs

module tb_top_tseq;

    localparam realtime UI = 200.0; // 5 GT/s

    // Use 65536 for the full specification sequence
    localparam int TSEQ_REPEATS = 3;
    localparam int SYMBOLS_PER_TSEQ = 32;
    localparam int TOTAL_SYMBOLS =
        TSEQ_REPEATS * SYMBOLS_PER_TSEQ;

    logic clk = 0;
    logic rst_n = 0;
    logic Rx_Polarity = 0;

    real D_plus  = 0.0;
    real D_minus = 0.0;

    logic recovered_clk;
    logic recovered_data;
    logic [9:0] parallel_data;
    logic symbol_valid;
    logic recovered_symbol_clk;

    logic [9:0] expected [0:TOTAL_SYMBOLS-1];

    bit rd_positive = 0; // Initial running disparity: RD-

    integer tx_count = 0;
    integer checked = 0;
    integer errors = 0;
    integer alignment_events = 0;
    integer symbol_clock_edges = 0;

    realtime last_valid_time = -1.0;
    realtime last_symbol_clock_time = -1.0;

    always #100 clk = ~clk;

    top dut (
        .clk(clk),
        .D_plus(D_plus),
        .D_minus(D_minus),
        .rst_n(rst_n),
        .Rx_Polarity(Rx_Polarity),
        .recovered_clk(recovered_clk),
        .recovered_data(recovered_data),
        .parallel_data(parallel_data),
        .symbol_valid(symbol_valid),
        .recovered_symbol_clk(recovered_symbol_clk)
    );

    // 8b/10b codes for the TSEQ ordered set.
    // Only the characters needed by TSEQ are included.
    function automatic logic [9:0] tseq_code(
        input integer pos,
        input bit rd_positive
    );

        case (pos)
            0:  tseq_code = rd_positive ?
                 10'b1100000101 : 10'b0011111010; // K28.5

            1:  tseq_code = rd_positive ?
                 10'b0101001110 : 10'b1010110001; // D31.7 FF

            2:  tseq_code = rd_positive ?
                 10'b0001011011 : 10'b1110100100; // D23.0 17

            3:  tseq_code = rd_positive ?
                 10'b0110000110 : 10'b1001110110; // D0.6 C0

            4:  tseq_code = rd_positive ?
                 10'b0010110100 : 10'b0010111011; // D20.0 14

            5:  tseq_code = 10'b0100111010; // D18.5 B2

            6:  tseq_code = rd_positive ?
                 10'b0001110001 : 10'b1110001110; // D7.7 E7

            7:  tseq_code = rd_positive ?
                 10'b0100101011 : 10'b1011010100; // D2.0 02

            8:  tseq_code = rd_positive ?
                 10'b0100101101 : 10'b1011010010; // D2.4 82

            9:  tseq_code = rd_positive ?
                 10'b0100110011 : 10'b0100111100; // D18.3 72

            10: tseq_code = rd_positive ?
                 10'b0111000011 : 10'b0111001100; // D14.3 6E

            11: tseq_code = rd_positive ?
                 10'b0001101001 : 10'b1110011001; // D8.1 28

            12: tseq_code = 10'b0110011010; // D6.5 A6

            13: tseq_code = rd_positive ?
                 10'b1000011010 : 10'b0111101010; // D30.5 BE

            14: tseq_code = rd_positive ?
                 10'b1011000011 : 10'b1011001100; // D13.3 6D

            15: tseq_code = rd_positive ?
                 10'b0101001010 : 10'b1010111010; // D31.5 BF

            // Positions 16 through 31: D10.2
            default: tseq_code = 10'b0101010101;
        endcase
    endfunction

    // Track running disparity between encoded characters.
    function automatic bit next_rd(
        input logic [9:0] code,
        input bit previous_rd
    );
        integer ones;

        ones = 0;
        for (integer i = 0; i < 10; i++)
            if (code[i])
                ones++;

        if (ones > 5)
            next_rd = 1;
        else if (ones < 5)
            next_rd = 0;
        else
            next_rd = previous_rd;
    endfunction

    // Generate differential signaling
    task automatic send_bit(input bit value);
        D_plus  = value ? 0.5 : -0.5;
        D_minus = value ? -0.5 : 0.5;
        #(UI);
    endtask

    // Send 10-bit encoded symbol, MSB first
    task automatic send_symbol(input logic [9:0] code);

        for (integer i = 9; i >= 0; i--)
            send_bit(code[i]);

    endtask

    // Send one complete 32-symbol TSEQ ordered set
    task automatic send_tseq(input integer repetition);

        logic [9:0] code;

        $display(
            "Transmitting TSEQ ordered set %0d",
            repetition
        );

        for (integer pos = 0;
             pos < SYMBOLS_PER_TSEQ;
             pos++) begin

            code = tseq_code(pos, rd_positive);

            expected[tx_count] = code;
            tx_count++;

            rd_positive = next_rd(code, rd_positive);

            send_symbol(code);
        end

    endtask

    // Check the recovered parallel words
    always @(posedge recovered_clk) begin : check_symbols

        realtime t;
        t = $realtime;

        // Observe the alignment request as sampled by S2P
        if (rst_n && dut.symbol_align) begin
            alignment_events++;
            $display(
                "Comma accepted at %0.3f ps",
                t
            );
        end

        // Allow S2P nonblocking assignments to update
        #0.001;

        if (rst_n && symbol_valid) begin

            if (checked >= TOTAL_SYMBOLS) begin
                errors++;
                $display(
                    "FAIL: Unexpected symbol %010b",
                    parallel_data
                );
            end

            else if (parallel_data !== expected[checked]) begin
                errors++;

                $display(
                    "FAIL symbol %0d (TSEQ %0d, slot %0d): expected=%010b received=%010b",
                    checked,
                    checked / 32,
                    checked % 32,
                    expected[checked],
                    parallel_data
                );
            end

            else if (checked < 32 || checked % 32 == 0) begin
                $display(
                    "PASS symbol %0d (slot %0d): %010b",
                    checked,
                    checked % 32,
                    parallel_data
                );
            end

            // Check that each symbol is 10 bit periods apart
            if (last_valid_time >= 0.0 &&
                ((t - last_valid_time) < (10.0*UI - 0.01) ||
                 (t - last_valid_time) > (10.0*UI + 0.01))) begin

                errors++;
                $display(
                    "FAIL: Symbol interval = %0.3f ps",
                    t - last_valid_time
                );
            end

            // Symbol clock should be high at symbol completion
            if (recovered_symbol_clk !== 1'b1) begin
                errors++;
                $display(
                    "FAIL: Symbol clock not high with symbol_valid"
                );
            end

            last_valid_time = t;
            checked++;

        end
    end

    // Verify symbol clock period
    always @(posedge recovered_symbol_clk) begin : check_symbol_clock

        realtime t;
        t = $realtime;

        if (rst_n) begin

            if (last_symbol_clock_time >= 0.0 &&
                ((t - last_symbol_clock_time) < (10.0*UI - 0.01) ||
                 (t - last_symbol_clock_time) > (10.0*UI + 0.01))) begin

                errors++;

                $display(
                    "FAIL: Symbol clock period = %0.3f ps",
                    t - last_symbol_clock_time
                );
            end

            last_symbol_clock_time = t;
            symbol_clock_edges++;

        end
    end

    initial begin

        $timeformat(-12, 3, " ps", 10);

        $dumpfile("tb_top_tseq.vcd");
        $dumpvars(0, tb_top_tseq);

        #73;

        // Pretrain the existing behavioral CRC.
        // This preamble is NOT part of USB 3.0 TSEQ.
        repeat (16) begin
            send_bit(1);
            send_bit(0);
        end

        rst_n = 1;

        // Fill the S2P before the first comma
        repeat (6) begin
            send_bit(1);
            send_bit(0);
        end

        $display("\n=== START TSEQ ===");

        for (integer rep = 0; rep < TSEQ_REPEATS; rep++)
            send_tseq(rep);

        // Allow DRC/S2P pipeline to finish
        repeat (3) @(posedge recovered_clk);
        #0.001;

        $display("\n=== FINAL TSEQ RESULTS ===");
        $display("TSEQ sets transmitted = %0d", TSEQ_REPEATS);
        $display("Symbols transmitted   = %0d", tx_count);
        $display("Symbols checked       = %0d", checked);
        $display("Alignment events      = %0d", alignment_events);
        $display("Symbol clock edges    = %0d", symbol_clock_edges);
        $display("Errors                = %0d", errors);

        if (
            checked == TOTAL_SYMBOLS &&
            tx_count == TOTAL_SYMBOLS &&
            alignment_events == 1 &&
            symbol_clock_edges == TOTAL_SYMBOLS &&
            errors == 0
        )
            $display("TSEQ TEST PASSED");
        else
            $display("TSEQ TEST FAILED");

        $finish;
    end

endmodule
