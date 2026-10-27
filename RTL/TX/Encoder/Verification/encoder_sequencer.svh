`ifndef ENCODER_SEQUENCER_SV
`define ENCODER_SEQUENCER_SV

    class encoder_sequencer extends uvm_sequencer #(encoder_seq_item);
        `uvm_component_utils(encoder_sequencer)
        function new(string name = "encoder_sequencer", uvm_component parent = null);
            super.new(name, parent);
        endfunction
    endclass

`endif