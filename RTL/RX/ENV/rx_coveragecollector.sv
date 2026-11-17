`ifndef RX_COVERAGECOLLECTOR_SV
`define RX_COVERAGECOLLECTOR_SV
package rx_coveragecollector_pkg;
import uvm_pkg::*;
import rx_transaction_pkg::*;
`include "uvm_macros.svh"

class rx_coveragecollector extends uvm_component;
    `uvm_component_utils(rx_coveragecollector)
    rx_transaction trans;
    uvm_analysis_export #(rx_transaction) cvr_export;
    uvm_tlm_analysis_fifo #(rx_transaction) cvr_fifo;
    covergroup cvr_grp;
        cp_symbol : coverpoint trans.parallel_data {
            bins comma_minus = {10'b0011111010};   // K28.5 RD-
            bins comma_plus  = {10'b1100000101};   // K28.5 RD+
            bins data_symbol = default;
        }

        // valid 8b10b symbols have 4, 5 or 6 ones
        cp_ones : coverpoint $countones(trans.parallel_data) {
            bins four_ones = {4};
            bins five_ones = {5};
            bins six_ones  = {6};
            illegal_bins bad_count = default;
        }

        cp_polarity : coverpoint trans.Rx_Polarity {
            bins normal   = {1'b0};
            bins inverted = {1'b1};
        }

        cx_symbol_pol : cross cp_symbol, cp_polarity;
    endgroup

    function new(string name = "rx_coveragecollector",uvm_component parent = null);
        super.new(name,parent);
        cvr_grp = new();
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        cvr_export = new("cvr_export",this);
        cvr_fifo = new("cvr_fifo",this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        cvr_export.connect(cvr_fifo.analysis_export);
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            cvr_fifo.get(trans);
            cvr_grp.sample();
        end
    endtask
endclass
endpackage
`endif