`ifndef ENCODER_TEST_SV
`define ENCODER_TEST_SV

class encoder_base_test extends uvm_test;
    `uvm_component_utils(encoder_base_test)

    encoder_env env;

    function new(string name = "encoder_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = encoder_env::type_id::create("env", this);
    endfunction
    
    pure virtual task run_sequences;

  
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        `uvm_info("TEST_START", $sformatf("Starting %s", get_type_name()), UVM_LOW)
        run_sequences();
        // Leave additional edges for the monitor and analysis FIFOs to drain.
        repeat (3) @(negedge env.agt.cfg.vif.clk);
        phase.drop_objection(this);
    endtask

endclass

class encoder_alternate7_test extends encoder_base_test;
    `uvm_component_utils(encoder_alternate7_test)
    function new(string name = "encoder_alternate7_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    virtual task run_sequences();
        encoder_alternate7_sequence seq;
        seq = encoder_alternate7_sequence::type_id::create("alternate7");
        seq.start(env.agt.sequencer);
    endtask
endclass

class encoder_disparity_test extends encoder_base_test;
    `uvm_component_utils(encoder_disparity_test)
    function new(string name = "encoder_disparity_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    virtual task run_sequences();
        encoder_disparity_sequence seq;
        seq = encoder_disparity_sequence::type_id::create("disparity");
        seq.start(env.agt.sequencer);
    endtask
endclass

class encoder_invalid_k_test extends encoder_base_test;
    `uvm_component_utils(encoder_invalid_k_test)
    function new(string name = "encoder_invalid_k_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    virtual task run_sequences();
        encoder_invalid_k_sequence seq;
        seq = encoder_invalid_k_sequence::type_id::create("invalid_k");
        seq.start(env.agt.sequencer);
    endtask
endclass

class encoder_idle_test extends encoder_base_test;
    `uvm_component_utils(encoder_idle_test)
    function new(string name = "encoder_idle_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    virtual task run_sequences();
        encoder_idle_sequence seq;
        seq = encoder_idle_sequence::type_id::create("idle");
        seq.start(env.agt.sequencer);
    endtask
endclass

class encoder_reset_test extends encoder_base_test;
    `uvm_component_utils(encoder_reset_test)
    function new(string name = "encoder_reset_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    virtual task run_sequences();
        encoder_reset_sequence seq;
        seq = encoder_reset_sequence::type_id::create("reset");
        seq.start(env.agt.sequencer);
    endtask
endclass

class encoder_random_test extends encoder_base_test;
    `uvm_component_utils(encoder_random_test)
    function new(string name = "encoder_random_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    virtual task run_sequences();
        encoder_random_sequence seq;
        seq = encoder_random_sequence::type_id::create("random");
        seq.start(env.agt.sequencer);
    endtask
endclass

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
        encoder_alternate7_sequence alternate7;
        encoder_disparity_sequence disparity;
        encoder_invalid_k_sequence invalid_k;
        encoder_idle_sequence idle;
        encoder_reset_sequence resets;
        encoder_random_sequence random_traffic;
        exhaustive = encoder_exhaustive_sequence::type_id::create("exhaustive");
        alternate7 = encoder_alternate7_sequence::type_id::create("alternate7");
        disparity = encoder_disparity_sequence::type_id::create("disparity");
        invalid_k = encoder_invalid_k_sequence::type_id::create("invalid_k");
        idle = encoder_idle_sequence::type_id::create("idle");
        resets = encoder_reset_sequence::type_id::create("reset");
        random_traffic = encoder_random_sequence::type_id::create("random");
        exhaustive.start(env.agt.sequencer);
        alternate7.start(env.agt.sequencer);
        disparity.start(env.agt.sequencer);
        invalid_k.start(env.agt.sequencer);
        idle.start(env.agt.sequencer);
        resets.start(env.agt.sequencer);
        random_traffic.start(env.agt.sequencer);
    endtask
endclass
`endif
