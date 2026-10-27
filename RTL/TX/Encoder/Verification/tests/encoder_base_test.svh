`ifndef ENCODER_BASE_TEST_SVH
`define ENCODER_BASE_TEST_SVH

virtual class encoder_base_test extends uvm_test;

    encoder_env env;

    function new(string name = "encoder_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = encoder_env::type_id::create("env", this);
    endfunction
    
    pure virtual task run_sequences();

  
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        `uvm_info("TEST_START", $sformatf("Starting %s", get_type_name()), UVM_LOW)
        run_sequences();
        // Leave additional edges for the monitor and analysis FIFOs to drain.
        repeat (3) @(negedge env.agt.cfg.vif.clk);
        phase.drop_objection(this);
    endtask

endclass

`endif
