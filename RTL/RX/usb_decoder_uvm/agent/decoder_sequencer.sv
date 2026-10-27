class decoder_sequencer extends uvm_sequencer #(decoder_sequence_item);

    // UVM Factory Registration
    `uvm_component_utils(decoder_sequencer)

    // Constructor
    function new(string name = "decoder_sequencer",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction

endclass
