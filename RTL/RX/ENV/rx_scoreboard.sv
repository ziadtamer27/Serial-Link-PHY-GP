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

        uvm_tlm_analysis_fifo #(rx_transaction) input_fifo;
        uvm_tlm_analysis_fifo #(rx_transaction) output_fifo;

        // Reference model
        logic [9:0] bit_window = 0;

        logic [9:0] expected_q[$];
        logic [9:0] actual_q[$];

        bit aligned = 0;
        int bit_count = 0;

        // Timing
        realtime last_valid_time = -1.0;

        int correct_counter = 0;
        int error_counter = 0;

        function new( string name = "rx_scoreboard",uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            input_fifo  = new("input_fifo", this);
            output_fifo = new("output_fifo", this);
        endfunction

        // Compare all available expected/actual symbols
        function void compare_symbols();
            logic [9:0] expected;
            logic [9:0] actual;

            while (expected_q.size() > 0 && actual_q.size() > 0) begin
                expected = expected_q.pop_front();
                actual   = actual_q.pop_front();

                if (actual !== expected) begin
                    error_counter++;
                    `uvm_error("RX_SB", $sformatf("Symbol mismatch: expected=%010b actual=%010b", expected, actual))
                end
                else begin
                    correct_counter++;
                end

            end

        endfunction

        // Build expected symbols from transmitted bits
        function void check_input(rx_transaction tr);

            logic corrected_bit;

            if (tr.rst_n !== 1'b1) begin

                bit_window = 0;
                bit_count  = 0;
                aligned    = 0;

                expected_q.delete();
                actual_q.delete();

                last_valid_time = -1.0;
                return;

            end

            corrected_bit = tr.tx_bit ^ tr.Rx_Polarity;

            bit_window = { bit_window[8:0],corrected_bit };

            // Search for comma
            if (!aligned) begin

                if (bit_window == 10'b0011111010 || bit_window == 10'b1100000101) begin
                    aligned   = 1;
                    bit_count = 0;
                    expected_q.push_back(bit_window);
                end

            end
            else begin
                bit_count++;

                if (bit_count == 10) begin
                    expected_q.push_back(bit_window);
                    bit_count = 0;

                end
            end
            compare_symbols();
        endfunction

        // Check received symbols and their timing
        function void check_output(rx_transaction tr);

            realtime current_time;
            realtime interval;

            current_time = $realtime;

            // Check symbol_valid spacing
            if (last_valid_time >= 0.0) begin

                interval = current_time - last_valid_time;

                if (interval < (10.0*200.0) || interval > (10.0*200.0)) begin
                    error_counter++;
                    `uvm_error("RX_SB", $sformatf( "Symbol interval = %0.3f ps, expected = %0.3f ps", interval, 10.0*200.0 ) )
                end

            end

            last_valid_time = current_time;

            // Check symbol clock at completed symbol
            if (tr.recovered_symbol_clk !== 1'b1) begin

                error_counter++;

                `uvm_error("RX_SB", "recovered_symbol_clk is not HIGH when symbol_valid is HIGH" )

            end

            // Save actual symbol
            actual_q.push_back(tr.parallel_data);

            compare_symbols();

        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            fork
                begin
                    rx_transaction in_tr;

                    forever begin
                        input_fifo.get(in_tr);
                        check_input(in_tr);
                    end
                end

                begin
                    rx_transaction out_tr;

                    forever begin
                        output_fifo.get(out_tr);
                        check_output(out_tr);
                    end
                end
            join
        endtask

        function void report_phase(uvm_phase phase);
            super.report_phase(phase);

            if (correct_counter == 0) begin
                `uvm_error("RX_SB", "No matching RX symbols were verified")
            end

            if (expected_q.size() != 0 || actual_q.size() != 0) begin
                `uvm_warning("RX_SB", $sformatf("Unmatched symbols: expected=%0d actual=%0d", expected_q.size(), actual_q.size() ) )
            end

            `uvm_info("RX_SB", $sformatf( "Correct symbols = %0d | Errors = %0d", correct_counter, error_counter ), UVM_LOW)

        endfunction
    endclass
endpackage
`endif
