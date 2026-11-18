`ifndef RX_TEST_SV
`define RX_TEST_SV

package rx_test_pkg;

    import uvm_pkg::*;
    import rx_env_pkg::*;
    import rx_all_sequence_pkg::*;

    `include "uvm_macros.svh"

    class rx_test extends uvm_test;

        `uvm_component_utils(rx_test)
        rx_env env;
        rx_all_sequence seq;

        function new(string name = "rx_test", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            env = rx_env::type_id::create("env", this);
            seq = rx_all_sequence::type_id::create("seq");
        endfunction

        task run_phase(uvm_phase phase);
            phase.raise_objection(this, "Test is running");
            `uvm_info("RX_TEST", "RX All Sequence Start", UVM_MEDIUM)
            seq.start(env.agent.sequencer);
            `uvm_info("RX_TEST", "RX All Sequence End", UVM_MEDIUM)
            repeat (20)
                @(posedge env.agent.vif.clk);
            phase.drop_objection(this, "Test completed");
        endtask

    endclass

endpackage
`endif
