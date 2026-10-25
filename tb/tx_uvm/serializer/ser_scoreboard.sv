package ser_scoreboard;

import uvm_pkg::*;
import ser_seq_item::*;
`include "uvm_macros.svh"

// ============================================================
// DPI-C / MATLAB imports
// ============================================================
import "DPI-C" function void get_differential_out(
    input  bit  bit_val,
    output real tx_p,
    output real tx_n,
    output real v_diff
);

import "DPI-C" function void close_matlab();


class ser_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(ser_scoreboard)

    uvm_analysis_export #(ser_seq_item) sb_export;
    uvm_tlm_analysis_fifo #(ser_seq_item) sb_fifo;

    ser_seq_item sb_seq_item;

    int correct_count;
    int error_count;

    int bit_count;
    logic [9:0] expected_data;

    // ========================================================
    // MATLAB returned values
    // ========================================================
    real tx_p;
    real tx_n;
    real v_diff;


    function new(string name = "ser_scoreboard",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction


    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        sb_export = new("sb_export", this);
        sb_fifo   = new("sb_fifo", this);

        correct_count = 0;
        error_count   = 0;
    endfunction


    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        sb_export.connect(sb_fifo.analysis_export);
    endfunction


    // ========================================================
    // Floating-point comparison
    // ========================================================
    function automatic bit is_close(
        real a,
        real b,
        real tol = 0.001
    );

        real diff;

        diff = (a > b) ? (a - b) : (b - a);

        return (diff <= tol);

    endfunction


    // ========================================================
    // MATLAB / Differential output check
    // ========================================================
    function void matlab_check(logic serial_bit);

        real exp_tx_p;
        real exp_tx_n;
        real exp_v_diff;

        // ----------------------------------------------------
        // Do not send X/Z to a 2-state DPI bit
        // ----------------------------------------------------
        if ($isunknown(serial_bit)) begin

            `uvm_error(
                "MATLAB_CHECK",
                "serial_out is X/Z. Not sending it to MATLAB."
            )

            return;

        end


        // ----------------------------------------------------
        // Determine expected analog values
        // ----------------------------------------------------
        if (serial_bit == 1'b1) begin

            exp_tx_p   = 1.4;
            exp_tx_n   = 1.0;
            exp_v_diff = 0.4;

        end
        else begin

            exp_tx_p   = 1.0;
            exp_tx_n   = 1.4;
            exp_v_diff = -0.4;

        end


        // ----------------------------------------------------
        // Send actual serializer output bit to MATLAB
        // ----------------------------------------------------
        get_differential_out(
            serial_bit,
            tx_p,
            tx_n,
            v_diff
        );


        `uvm_info(
            "MATLAB_CHECK",
            $sformatf(
                "serial=%0b | TX+=%0.3f V | TX-=%0.3f V | Vdiff=%0.3f V",
                serial_bit,
                tx_p,
                tx_n,
                v_diff
            ),
            UVM_MEDIUM
        )


        // ----------------------------------------------------
        // Check TX+
        // ----------------------------------------------------
        if (is_close(tx_p, exp_tx_p)) begin

            `uvm_info(
                "MATLAB_CHECK",
                $sformatf(
                    "PASS TX+: actual=%0.3f V expected=%0.3f V",
                    tx_p,
                    exp_tx_p
                ),
                UVM_MEDIUM
            )

        end
        else begin

            `uvm_error(
                "MATLAB_CHECK",
                $sformatf(
                    "FAIL TX+: actual=%0.3f V expected=%0.3f V",
                    tx_p,
                    exp_tx_p
                )
            )

        end


        // ----------------------------------------------------
        // Check TX-
        // ----------------------------------------------------
        if (is_close(tx_n, exp_tx_n)) begin

            `uvm_info(
                "MATLAB_CHECK",
                $sformatf(
                    "PASS TX-: actual=%0.3f V expected=%0.3f V",
                    tx_n,
                    exp_tx_n
                ),
                UVM_MEDIUM
            )

        end
        else begin

            `uvm_error(
                "MATLAB_CHECK",
                $sformatf(
                    "FAIL TX-: actual=%0.3f V expected=%0.3f V",
                    tx_n,
                    exp_tx_n
                )
            )

        end


        // ----------------------------------------------------
        // Check Vdiff
        // ----------------------------------------------------
        if (is_close(v_diff, exp_v_diff)) begin

            `uvm_info(
                "MATLAB_CHECK",
                $sformatf(
                    "PASS Vdiff: actual=%0.3f V expected=%0.3f V",
                    v_diff,
                    exp_v_diff
                ),
                UVM_MEDIUM
            )

        end
        else begin

            `uvm_error(
                "MATLAB_CHECK",
                $sformatf(
                    "FAIL Vdiff: actual=%0.3f V expected=%0.3f V",
                    v_diff,
                    exp_v_diff
                )
            )

        end

    endfunction


    // ========================================================
    // Main Scoreboard
    // ========================================================
    task run_phase(uvm_phase phase);

        super.run_phase(phase);

        bit_count     = 0;
        expected_data = 0;

        forever begin

            // Get transaction from monitor
            sb_fifo.get(sb_seq_item);


            // ------------------------------------------------
            // Reset
            // ------------------------------------------------
            if (!sb_seq_item.rst_n) begin

                bit_count     = 0;
                expected_data = 0;

            end

            else begin

                // --------------------------------------------
                // Capture new parallel word
                // --------------------------------------------
                if (bit_count == 0)
                    expected_data = sb_seq_item.parallel_data;


                // ============================================
                // 1. DIGITAL P2S CHECK
                // ============================================
                if (sb_seq_item.serial_out ===
                    expected_data[bit_count]) begin

                    correct_count++;

                    `uvm_info(
                        "SER_SCOREBOARD",
                        $sformatf(
                            "PASS: bit_count=%0d expected=%0b actual=%0b",
                            bit_count,
                            expected_data[bit_count],
                            sb_seq_item.serial_out
                        ),
                        UVM_MEDIUM
                    )

                end

                else begin

                    error_count++;

                    `uvm_error(
                        "SER_SCOREBOARD",
                        $sformatf(
                            "FAIL: bit_count=%0d expected=%0b actual=%0b",
                            bit_count,
                            expected_data[bit_count],
                            sb_seq_item.serial_out
                        )
                    )

                end


                // ============================================
                // 2. MATLAB / DIFFERENTIAL CHECK
                // ============================================
                matlab_check(sb_seq_item.serial_out);


                // --------------------------------------------
                // Move to next serialized bit
                // --------------------------------------------
                if (bit_count == 9)
                    bit_count = 0;
                else
                    bit_count++;

            end

        end

    endtask


    // ========================================================
    // Report
    // ========================================================
    function void report_phase(uvm_phase phase);

        super.report_phase(phase);

        `uvm_info(
            "SER_SCOREBOARD",
            $sformatf(
                "Correct bits = %0d, Error bits = %0d",
                correct_count,
                error_count
            ),
            UVM_MEDIUM
        )

        // Tell C/MATLAB that simulation checking is complete
        close_matlab();

    endfunction


endclass

endpackage