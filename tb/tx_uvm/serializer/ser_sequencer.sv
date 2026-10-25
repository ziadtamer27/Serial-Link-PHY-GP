package ser_sequencer ;
`include "uvm_macros.svh"
import uvm_pkg::*;
import ser_seq_item::*;
class ser_sequencer extends uvm_sequencer #(ser_seq_item);
    `uvm_component_utils(ser_sequencer);

    function new(string name ="ser_sequencer",uvm_component parent=null);
        super.new(name,parent);
    endfunction

endclass
endpackage