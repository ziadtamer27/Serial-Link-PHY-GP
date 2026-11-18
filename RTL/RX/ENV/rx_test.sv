`ifndef ALU_TEST_SV
`define ALU_TEST_SV

package alu_test_pkg;
    import uvm_pkg::*;
    import alu_env_pkg::*;
    import alu_overflow_sequence_pkg::*;
    import alu_shift_sequence_pkg::*;
    import alu_corner_sequence_pkg::*;
    import alu_random_sequence_pkg::*;
    `include "uvm_macros.svh"

    class alu_test extends uvm_test;
        `uvm_component_utils(alu_test)
        alu_env env;
        alu_overflow_sequence overflow_seq;
        alu_shift_sequence shift_seq;
        alu_corner_sequence corner_seq;
        alu_random_sequence rand_seq;
        function new(string name = "alu_test",uvm_component parent = null);
            super.new(name,parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            env = alu_env ::type_id:: create("env",this);
            rand_seq = alu_random_sequence::type_id::create("rand_seq");
            overflow_seq = alu_overflow_sequence::type_id::create("overflow_seq");
            shift_seq = alu_shift_sequence::type_id::create("shift_seq");
            corner_seq = alu_corner_sequence::type_id::create("corner_seq");
        endfunction

        task run_phase(uvm_phase phase);
            phase.raise_objection(this,"Test is running");
                `uvm_info("run_phase","Overflow Sequence Start",UVM_MEDIUM);
                overflow_seq.start(env.agent.sequencer);
                `uvm_info("run_phase","Overflow Sequence End",UVM_MEDIUM);
                `uvm_info("run_phase","Shift Sequence Start",UVM_MEDIUM);
                shift_seq.start(env.agent.sequencer);
                `uvm_info("run_phase","Shift Sequence End",UVM_MEDIUM);
                `uvm_info("run_phase","Corner Sequence Start",UVM_MEDIUM);
                corner_seq.start(env.agent.sequencer);
                `uvm_info("run_phase","Corner Sequence End",UVM_MEDIUM);
                `uvm_info("run_phase","Random Sequence Start",UVM_MEDIUM);
                rand_seq.start(env.agent.sequencer);
                `uvm_info("run_phase","Random Sequence End",UVM_MEDIUM);
                @(posedge env.agent.vif.clk);
            phase.drop_objection(this,"Test completed");
        endtask;
    endclass
endpackage

`endif