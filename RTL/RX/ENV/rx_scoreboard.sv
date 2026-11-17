`ifndef RX_SCOREBOARD_SV    
`define RX_SCOREBOARD_SV
package rx_scoreboard_pkg;
import uvm_pkg::*;
import rx_transaction_pkg::*;
`include "uvm_macros.svh"

class rx_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(rx_scoreboard)

    rx_transaction trans;
    uvm_analysis_export #(rx_transaction) sb_export;
    uvm_tlm_analysis_fifo #(rx_transaction) sb_fifo;

    int correct_counter = 0;
    int error_counter   = 0;

    function new(string name = "rx_scoreboard",uvm_component parent = null);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        sb_export = new("sb_export",this);
        sb_fifo   = new("sb_fifo",this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        sb_export.connect(sb_fifo.analysis_export);
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            sb_fifo.get(trans);
            if (trans.ref_Result !== trans.Result || trans.ref_overflow !== trans.overflow)begin
                error_counter++;
                `uvm_error("UNEXPECTED OUTPUT",
                    $sformatf("A = %d | B = %d | AluControlout = %d | Shift_Amt = %d | Result = %d | Ref_Result = %d | overflow = %d | Ref_overflow = %d",
                    trans.A,
                    trans.B,
                    trans.AluControlout,
                    trans.shift_amt,
                    trans.Result,
                    trans.ref_Result,
                    trans.overflow,
                    trans.ref_overflow))
            end
            else 
                correct_counter++;
        end
    endtask

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        $display("Final Counters for rx %d,%d", correct_counter, error_counter);
    endfunction


endclass
endpackage
`endif