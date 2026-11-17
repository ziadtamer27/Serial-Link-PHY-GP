`ifndef RX_SCOREBOARD_SV
`define RX_SCOREBOARD_SV

package rx_scoreboard_pkg;

    timeunit 1ps;
    timeprecision 1fs;

    import uvm_pkg::*;
    import rx_transaction_pkg::*;
    `include "uvm_macros.svh"

    class rx_scoreboard extends uvm_scoreboard;

        `uvm_component_utils(rx_scoreboard)

        localparam realtime UI  = 200.0;
        localparam realtime TOL = 0.01;

        uvm_tlm_analysis_fifo #(rx_transaction) input_fifo;
        uvm_tlm_analysis_fifo #(rx_transaction) output_fifo;

        // Reference model
        bit [9:0] expected_window = 0;
        bit [9:0] expected_symbols[$];

        bit aligned = 0;
        bit expected_bit;
        int bit_count = 0;

        // Timing
        realtime last_tx_time     = -1.0;
        realtime last_rx_time     = -1.0;
        realtime last_valid_time  = -1.0;
        realtime last_symbol_time = -1.0;

        int correct_counter = 0;
        int error_counter = 0;
        int symbols_checked = 0;

        function new(string name = "rx_scoreboard",
                     uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            input_fifo  = new("input_fifo", this);
            output_fifo = new("output_fifo", this);
        endfunction

        function automatic realtime abs_time(realtime value);
            return (value < 0.0) ? -value : value;
        endfunction

        function void check_error(string message);
            error_counter++;
            `uvm_error("RX_SCOREBOARD", message)
        endfunction

        // =====================================
        // INPUT MONITOR: Expected serial data
        // =====================================
        function void check_input(rx_transaction tr);

            bit corrected_bit;

            if (tr.observation != RX_TX_BIT)
                return;

            if (!tr.rst_n) begin
                aligned = 0;
                expected_window = 0;
                expected_symbols.delete();
                bit_count = 0;

                last_tx_time = -1.0;
                last_rx_time = -1.0;
                last_valid_time = -1.0;
                last_symbol_time = -1.0;
                return;
            end

            // Check transmitted UI
            if (last_tx_time >= 0.0 &&
                abs_time(tr.timestamp_ps - last_tx_time - UI) > TOL)
                check_error("Incorrect transmitted bit interval");

            last_tx_time = tr.timestamp_ps;

            // Expected serial bit
            expected_bit = (tr.D_plus > tr.D_minus);

            // Apply RX polarity before forming symbols
            corrected_bit = expected_bit ^ tr.Rx_Polarity;

            expected_window = {
                expected_window[8:0],
                corrected_bit
            };

            // Find first K28.5
            if (!aligned) begin

                if (expected_window == 10'b0011111010 ||
                    expected_window == 10'b1100000101) begin

                    aligned = 1;
                    bit_count = 0;
                    expected_symbols.push_back(expected_window);

                end
            end

            // Collect next 10-bit symbols
            else begin

                bit_count++;

                if (bit_count == 10) begin
                    expected_symbols.push_back(expected_window);
                    bit_count = 0;
                end
            end

        endfunction

        // =====================================
        // OUTPUT MONITOR: Actual RX outputs
        // =====================================
        function void check_output(rx_transaction tr);

            bit [9:0] exp_symbol;
            realtime dt;

            if (!tr.rst_n)
                return;

            case (tr.observation)

                RX_BIT_CLK_EDGE: begin

                    // Check only after comma alignment
                    if (aligned) begin

                        // Recovered clock period
                        if (last_rx_time >= 0.0) begin
                            dt = tr.timestamp_ps - last_rx_time;

                            if (abs_time(dt - UI) > TOL)
                                check_error(
                                    $sformatf(
                                        "Recovered clock period = %0.3f ps",
                                        dt
                                    )
                                );
                        end

                        // Recovered clock phase
                        if (last_tx_time >= 0.0) begin
                            dt = tr.timestamp_ps - last_tx_time;

                            if (abs_time(dt - UI/2.0) > TOL)
                                check_error("Recovered clock not centered");

                            // Recovered data
                            if (tr.recovered_data !== expected_bit)
                                check_error(
                                    $sformatf(
                                        "Recovered data mismatch: expected=%b actual=%b",
                                        expected_bit,
                                        tr.recovered_data
                                    )
                                );
                            else
                                correct_counter++;
                        end
                    end

                    last_rx_time = tr.timestamp_ps;

                    // Check completed parallel symbol
                    if (tr.symbol_valid) begin

                        if (expected_symbols.size() == 0) begin
                            check_error("Unexpected parallel symbol");
                        end
                        else begin

                            exp_symbol = expected_symbols.pop_front();
                            symbols_checked++;

                            if (tr.parallel_data !== exp_symbol)
                                check_error(
                                    $sformatf(
                                        "Symbol mismatch: expected=%010b actual=%010b",
                                        exp_symbol,
                                        tr.parallel_data
                                    )
                                );
                            else
                                correct_counter++;

                        end

                        // Symbol-valid spacing
                        if (last_valid_time >= 0.0) begin
                            dt = tr.timestamp_ps - last_valid_time;

                            if (abs_time(dt - 10.0*UI) > TOL)
                                check_error("Incorrect symbol_valid interval");
                        end

                        last_valid_time = tr.timestamp_ps;

                        if (tr.recovered_symbol_clk !== 1'b1)
                            check_error(
                                "Symbol clock not HIGH at symbol completion"
                            );

                    end
                end

                RX_SYMBOL_CLK_RISE: begin

                    if (last_symbol_time >= 0.0) begin
                        dt = tr.timestamp_ps - last_symbol_time;

                        if (abs_time(dt - 10.0*UI) > TOL)
                            check_error(
                                "Incorrect recovered symbol clock period"
                            );
                    end

                    last_symbol_time = tr.timestamp_ps;
                end

                default: begin
                    // No additional checks
                end

            endcase

        endfunction

        // =====================================
        // Run both checkers
        // =====================================
        task run_phase(uvm_phase phase);

            rx_transaction tr;

            super.run_phase(phase);

            fork

                forever begin
                    input_fifo.get(tr);
                    check_input(tr);
                end

                forever begin
                    rx_transaction out_tr;
                    output_fifo.get(out_tr);
                    check_output(out_tr);
                end

            join

        endtask

        // =====================================
        // Final report
        // =====================================
        function void report_phase(uvm_phase phase);

            super.report_phase(phase);

            if (symbols_checked == 0)
                check_error("No parallel symbols were checked");

            `uvm_info("RX_SCOREBOARD",
                $sformatf(
                    "Correct checks = %0d | Symbols checked = %0d | Errors = %0d",
                    correct_counter,
                    symbols_checked,
                    error_counter
                ),
                UVM_LOW
            )

        endfunction

    endclass

endpackage

`endif
