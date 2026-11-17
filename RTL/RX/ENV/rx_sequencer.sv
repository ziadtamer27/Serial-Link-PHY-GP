`ifndef ALU_SEQUENCER_SV
`define ALU_SEQUENCER_SV

package alu_sequencer_pkg;
    import uvm_pkg::*;
    import alu_transaction_pkg::*;
    `include "uvm_macros.svh"

    class alu_sequencer extends uvm_sequencer #(alu_transaction);
        `uvm_component_utils(alu_sequencer)
        function new(string name = "alu_sequencer", uvm_component parent = null);
            super.new(name, parent);
        endfunction
    endclass
endpackage

`endif