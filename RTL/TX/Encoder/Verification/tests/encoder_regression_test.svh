`ifndef ENCODER_REGRESSION_TEST_SVH
`define ENCODER_REGRESSION_TEST_SVH

class encoder_regression_test extends encoder_base_test;
    `uvm_component_utils(encoder_regression_test)
    function new(string name = "encoder_regression_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    function void build_phase(uvm_phase phase);
        uvm_config_db#(bit)::set(this, "env.cov", "require_full_coverage", 1'b1);
        super.build_phase(phase);
    endfunction
    virtual task run_sequences();
        encoder_exhaustive_sequence exhaustive;
        exhaustive = encoder_exhaustive_sequence::type_id::create("exhaustive");
        exhaustive.start(env.agt.sequencer);

    endtask
endclass

`endif
