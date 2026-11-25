`timescale 1ps/1ps

module Tx_Wrapper_tb #(
    parameter int DATA_WIDTH = 8
);

    // ==========================================
    // CONFIGURATION
    // ==========================================

    localparam int NUM_BYTES = DATA_WIDTH / 8;
    localparam int BIT_PERIOD = 200;
    localparam int SYMBOL_PERIOD = 2000;
    localparam int PCLK_PERIOD = SYMBOL_PERIOD * NUM_BYTES;
    localparam int NUM_SYMBOLS = 8;

    // ==========================================
    // CLOCKS AND RESET
    // ==========================================

    logic bit_rate_clk;
    wire  symbol_clk;
    logic pclk_wide;
    wire  pclk;
    logic rst_n;

    // ==========================================
    // TRANSMITTER INPUTS
    // ==========================================

    logic                  tx_valid;
    logic [DATA_WIDTH-1:0] tx_data;
    logic [NUM_BYTES-1:0]  tx_data_k;

    // ==========================================
    // TRANSMITTER OUTPUTS
    // ==========================================

    logic tx_p;
    logic tx_n;
    logic tx_serial_out;
    logic tx_invalid_k;
    logic tx_rd_positive;

    // ==========================================
    // MONITORING
    // ==========================================

    integer encoder_valid_count = 0;
    integer invalid_k_count = 0;
    integer serial_transition_count = 0;
    integer differential_errors = 0;
    integer divider_errors = 0;
    integer data_errors = 0;
    integer symbol_index = 0;

    time last_div_edge;
    bit seen_div_edge = 0;

    logic previous_serial;

    // Expected symbol sequence
    logic [7:0] test_data [0:NUM_SYMBOLS-1];
    logic       test_k    [0:NUM_SYMBOLS-1];

    // ==========================================
    // DUT
    // ==========================================

    TX_Wrapper #(
        .DATA_WIDTH(DATA_WIDTH)
    ) DUT (
        .pclk           (pclk),
        .bit_rate_clk   (bit_rate_clk),
        .rst_n          (rst_n),

        .tx_valid       (tx_valid),
        .tx_data        (tx_data),
        .tx_data_k      (tx_data_k),

        .tx_p           (tx_p),
        .tx_n           (tx_n),
        .tx_serial_out  (tx_serial_out),
        .tx_invalid_k   (tx_invalid_k),
        .tx_rd_positive (tx_rd_positive)
    );

    // ==========================================
    // CLOCK GENERATION
    // ==========================================

    initial bit_rate_clk = 0;

    always #(BIT_PERIOD/2)
        bit_rate_clk = ~bit_rate_clk;

    assign symbol_clk = DUT.bit_rate_clk_div10;

    // Static PCLK selection
    generate
        if (DATA_WIDTH == 8) begin : gen_clk8

            assign pclk = symbol_clk;

        end
        else begin : gen_clk_wide

            initial pclk_wide = 0;

            always #(PCLK_PERIOD/2)
                pclk_wide = ~pclk_wide;

            assign pclk = pclk_wide;

        end
    endgenerate

    // ==========================================
    // DIVIDER MONITOR
    // ==========================================

    always @(posedge symbol_clk) begin

        if (!rst_n) begin
            seen_div_edge = 0;
        end
        else begin

            if (seen_div_edge) begin

                if (($time - last_div_edge)
                    != SYMBOL_PERIOD) begin

                    $display(
                        "FAIL: Divider period = %0t",
                        $time - last_div_edge
                    );

                    divider_errors++;

                end
            end

            last_div_edge = $time;
            seen_div_edge = 1;

        end
    end

    // ==========================================
    // OPTIONAL BLOCK SCOREBOARD
    // ==========================================

    // Check the actual inputs sampled by the encoder.
    // No delay here because the encoder samples
    // these signals before NBA updates.

    always @(posedge symbol_clk) begin

        if (rst_n && DUT.encoder_valid) begin

            if (symbol_index < NUM_SYMBOLS) begin

                if (DUT.encoder_data !==
                    test_data[symbol_index] ||

                    DUT.encoder_k !==
                    test_k[symbol_index]) begin

                    $display(
                        "FAIL: Symbol %0d Expected=%h K=%b Got=%h K=%b",
                        symbol_index,
                        test_data[symbol_index],
                        test_k[symbol_index],
                        DUT.encoder_data,
                        DUT.encoder_k
                    );

                    data_errors++;

                end
                else begin

                    $display(
                        "[PASS] Symbol %0d Data=%h K=%b",
                        symbol_index,
                        DUT.encoder_data,
                        DUT.encoder_k
                    );

                end

            end
            else begin

                $display(
                    "FAIL: Unexpected extra symbol %h",
                    DUT.encoder_data
                );

                data_errors++;

            end

            symbol_index++;

        end
    end

    // ==========================================
    // ENCODER MONITOR
    // ==========================================

    always @(posedge symbol_clk) begin
        #2;

        if (rst_n) begin

            if (DUT.serializer_valid) begin

                encoder_valid_count++;

                $display(
                    "[ENCODER] Encoded data=%b",
                    DUT.serializer_data
                );

            end

            if (tx_invalid_k) begin

                invalid_k_count++;

                $display(
                    "[ENCODER] Invalid K detected!"
                );

            end

        end
    end

    // ==========================================
    // SERIALIZER AND DIFFERENTIAL MONITOR
    // ==========================================

    always @(posedge bit_rate_clk) begin
        #1;

        if (rst_n) begin

            if ($isunknown(tx_serial_out)) begin

                $display(
                    "FAIL: Serial output contains X/Z"
                );

                data_errors++;

            end

            if (tx_serial_out !== previous_serial)
                serial_transition_count++;

            previous_serial = tx_serial_out;

            if (tx_p !== tx_serial_out ||
                tx_n !== ~tx_serial_out) begin

                $display(
                    "FAIL: Differential mismatch at %0t",
                    $time
                );

                differential_errors++;

            end

        end
    end

    // ==========================================
    // TASK: SEND ONE PARALLEL WORD
    // ==========================================

    task automatic send_word(
        input logic [DATA_WIDTH-1:0] data,
        input logic [NUM_BYTES-1:0]  is_k
    );

        @(negedge pclk);

        tx_data   = data;
        tx_data_k = is_k;
        tx_valid  = 1'b1;

        $display(
            "[TX INPUT] Data=%h K=%b Time=%0t",
            data, is_k, $time
        );

        @(posedge pclk);
        #2;

    endtask

    // ==========================================
    // TASK: PACK AND SEND TEST SYMBOLS
    // ==========================================

    task automatic send_test_sequence;

        logic [DATA_WIDTH-1:0] packed_data;
        logic [NUM_BYTES-1:0]  packed_k;

        for (int i = 0;
             i < NUM_SYMBOLS;
             i += NUM_BYTES) begin

            packed_data = '0;
            packed_k    = '0;

            for (int j = 0;
                 j < NUM_BYTES;
                 j++) begin

                packed_data[j*8 +: 8] =
                    test_data[i+j];

                packed_k[j] = test_k[i+j];

            end

            send_word(packed_data, packed_k);

        end

        @(negedge pclk);
        tx_valid = 1'b0;

    endtask

    // ==========================================
    // MAIN TEST
    // ==========================================

    initial begin

        if (!(DATA_WIDTH inside {8,16,32}))
            $fatal(1, "Unsupported DATA_WIDTH");

        $display("=================================");
        $display("       USB3 TX PHY TEST");
        $display("DATA_WIDTH  = %0d", DATA_WIDTH);
        $display("NUM_BYTES   = %0d", NUM_BYTES);
        $display("PCLK_PERIOD = %0d ps", PCLK_PERIOD);
        $display("=================================");

        rst_n     = 0;
        tx_valid  = 0;
        tx_data   = '0;
        tx_data_k = '0;

        previous_serial = 0;
        last_div_edge   = 0;

        // --------------------------------------
        // TEST SYMBOLS
        // --------------------------------------

        test_data = '{
            8'h55,
            8'hA5,
            8'h12,
            8'hBC,
            8'h00,
            8'hFF,
            8'h00,
            8'h96
        };

        test_k = '{
            1'b0,
            1'b0,
            1'b0,
            1'b1,  // Valid K28.5
            1'b1,  // Invalid K
            1'b0,
            1'b0,
            1'b0
        };

        // --------------------------------------
        // RESET
        // --------------------------------------

        repeat (10) @(posedge bit_rate_clk);

        @(negedge bit_rate_clk);
        rst_n = 1;

        $display("[RESET] Released at %0t", $time);

        repeat (3) @(posedge pclk);

        // --------------------------------------
        // SEND ALL TEST SYMBOLS
        // --------------------------------------

        send_test_sequence();

        // Wait for pipeline and serializer
        repeat (15) @(posedge symbol_clk);
        repeat (10) @(posedge bit_rate_clk);

        #10;

        // ======================================
        // FINAL CHECKS
        // ======================================

        if (symbol_index != NUM_SYMBOLS) begin
            $display("FAIL: Optional symbol count");
            data_errors++;
        end

        if (encoder_valid_count != 7) begin
            $display("FAIL: Encoder valid count");
            data_errors++;
        end

        if (invalid_k_count != 1) begin
            $display("FAIL: Invalid K count");
            data_errors++;
        end

        if (serial_transition_count == 0) begin
            $display("FAIL: No serial transitions");
            data_errors++;
        end

        // ======================================
        // FINAL RESULTS
        // ======================================

        $display("\n=================================");
        $display("             SUMMARY");
        $display("=================================");

        $display("DATA_WIDTH             : %0d",
                 DATA_WIDTH);

        $display("Expected input symbols : %0d",
                 NUM_SYMBOLS);

        $display("Actual input symbols   : %0d",
                 symbol_index);

        $display("Expected valid symbols : 7");

        $display("Actual valid symbols   : %0d",
                 encoder_valid_count);

        $display("Expected invalid K     : 1");

        $display("Actual invalid K       : %0d",
                 invalid_k_count);

        $display("Serial transitions     : %0d",
                 serial_transition_count);

        $display("Divider errors         : %0d",
                 divider_errors);

        $display("Differential errors    : %0d",
                 differential_errors);

        $display("Data errors            : %0d",
                 data_errors);

        if (divider_errors != 0 ||
            differential_errors != 0 ||
            data_errors != 0) begin

            $display("========== TEST FAILED ==========");

        end
        else begin

            $display("========== ALL TESTS PASSED ==========");

        end

        $display("=================================");

        $finish;

    end

    // ==========================================
    // SIMULATION TIMEOUT
    // ==========================================

    initial begin
        #500000;
        $fatal(1, "Simulation timeout!");
    end

endmodule