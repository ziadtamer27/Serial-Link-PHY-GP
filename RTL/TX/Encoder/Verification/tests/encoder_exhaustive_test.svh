`ifndef ENCODER_EXHAUSTIVE_TEST_SVH
`define ENCODER_EXHAUSTIVE_TEST_SVH

class encoder_exhaustive_test extends encoder_base_test;
    `uvm_component_utils(encoder_exhaustive_test)
    function new(string name = "encoder_exhaustive_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        uvm_config_db#(bit)::set(this, "env.cov", "require_full_coverage", 1'b1);
        super.build_phase(phase);
    endfunction

    virtual task run_sequences();
        encoder_exhaustive_sequence seq;
        seq = encoder_exhaustive_sequence::type_id::create("exhaustive");
        seq.start(env.agt.sequencer);
    endtask

endclass

`endif
