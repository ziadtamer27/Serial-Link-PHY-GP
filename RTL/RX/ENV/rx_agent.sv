`ifndef RX_AGENT_SV    
`define RX_AGENT_SV

package rx_agent_pkg;
    import uvm_pkg::*;
    import rx_driver_pkg::*;
    import rx_monitor_pkg::*;
    import rx_sequencer_pkg::*;
    import rx_transaction_pkg::*;
    import rx_config_pkg::*;
    `include "uvm_macros.svh"

    class rx_agent extends uvm_agent;
        `uvm_component_utils(rx_agent)
        rx_config cfg;
        rx_driver driver;
        rx_monitor monitor;
        rx_sequencer sequencer;
        virtual rx_if vif;
        uvm_analysis_port #(rx_transaction) agt_ap;

        function new(string name = "rx_agent", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            agt_ap = new("agt_ap", this);
            cfg = rx_config::type_id::create("cfg", this);
            monitor = rx_monitor::type_id::create("monitor", this);
            if(cfg.get_active() == UVM_ACTIVE) begin
                driver = rx_driver::type_id::create("driver", this);
                sequencer = rx_sequencer::type_id::create("sequencer", this);
            end
        endfunction

        virtual function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            if(uvm_config_db#(virtual rx_if)::get(this, "", "rx_if", vif) == 0) begin
                `uvm_fatal("RX_AGENT", "Virtual interface not found in uvm_config_db")
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