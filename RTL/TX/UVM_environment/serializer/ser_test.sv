package ser_test;
import ser_env::*;
import uvm_pkg::*;
import ser_config::*;

import ser_main_sequence::*;
import ser_directed_sequence::*;
import ser_reset_sequence::*;

`include "uvm_macros.svh";
class ser_test extends uvm_test;
    `uvm_component_utils(ser_test)

    ser_env env;
    ser_config con_fig;
    ser_main_sequence main_seq;
    ser_directed_sequence directed_seq;
    ser_reset_sequence reset_seq;

    virtual ser_if ser_vif;

    function new(string name="ser_test",uvm_component parent=null);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = ser_env::type_id::create("env",this);
        con_fig = ser_config::type_id::create("con_fig");
        main_seq = ser_main_sequence::type_id::create("main_seq");
        directed_seq = ser_directed_sequence::type_id::create("directed_seq");
        reset_seq = ser_reset_sequence::type_id::create("reset_seq");

        if(!uvm_config_db#(virtual ser_if)::get(this,"","vif",con_fig.ser_vif))
            `uvm_fatal("SER_TEST","virtual interface must be set for ser_If");

        uvm_config_db#(ser_config)::set(this,"*","cfg",con_fig);

    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        phase.raise_objection(this);
    
        `uvm_info("reset_sequence","reset sequence started",UVM_MEDIUM)
        reset_seq.start(env.agent.sequencer);

        `uvm_info("directed_sequence","directed sequence started",UVM_MEDIUM)
        directed_seq.start(env.agent.sequencer);

        //`uvm_info("main_sequence","main sequence started",UVM_MEDIUM)
        //main_seq.start(env.agent.sequencer);

        #30;

        phase.drop_objection(this);
    endtask
    endclass
endpackage

