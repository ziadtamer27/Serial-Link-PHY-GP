`ifndef ALU_AGENT_SV    
`define ALU_AGENT_SV

package alu_agent_pkg;
    import uvm_pkg::*;
    import alu_driver_pkg::*;
    import alu_monitor_pkg::*;
    import alu_sequencer_pkg::*;
    import alu_transaction_pkg::*;
    import alu_config_pkg::*;
    `include "uvm_macros.svh"

    class alu_agent extends uvm_agent;
        `uvm_component_utils(alu_agent)
        alu_config cfg;
        alu_driver driver;
        alu_monitor monitor;
        alu_sequencer sequencer;
        virtual alu_if vif;
        uvm_analysis_port #(alu_transaction) agt_ap;

        function new(string name = "alu_agent", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            agt_ap = new("agt_ap", this);
            cfg = alu_config::type_id::create("cfg", this);
            monitor = alu_monitor::type_id::create("monitor", this);
            if(cfg.get_active() == UVM_ACTIVE) begin
                driver = alu_driver::type_id::create("driver", this);
                sequencer = alu_sequencer::type_id::create("sequencer", this);
            end
        endfunction
        virtual function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            if(uvm_config_db#(virtual alu_if)::get(this, "", "alu_if", vif) == 0) begin
                `uvm_fatal("ALU_AGENT", "Virtual interface not found in uvm_config_db")
            end
            else begin
                cfg.set_vif(vif);
            end
            monitor.cfg = cfg;
            if(cfg.get_active() == UVM_ACTIVE) begin
                driver.cfg = cfg;
                driver.seq_item_port.connect(sequencer.seq_item_export);
            end
            monitor.monitor_ap.connect(agt_ap);
            

        endfunction
    endclass
endpackage

`endif