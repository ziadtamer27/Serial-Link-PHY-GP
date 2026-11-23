`ifndef RX_SEQUENCER_SV
`define RX_SEQUENCER_SV

package rx_sequencer_pkg;
    import uvm_pkg::*;
    import rx_transaction_pkg::*;
    `include "uvm_macros.svh"

    class rx_sequencer extends uvm_sequencer #(rx_transaction); 
        `uvm_component_utils(rx_sequencer)
        function new(string name = "rx_sequencer", uvm_component parent = null);
            super.new(name, parent);
        endfunction
    endclass
endpackage

`endif