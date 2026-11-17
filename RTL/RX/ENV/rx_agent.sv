`ifndef RX_AGENT_SV    
`define RX_AGENT_SV

package rx_agent_pkg;
    import uvm_pkg::*;
    import rx_driver_pkg::*;
    import rx_input_monitor_pkg::*;
    import rx_output_monitor_pkg::*;
    import rx_sequencer_pkg::*;
    import rx_transaction_pkg::*;
    import rx_config_pkg::*;
    `include "uvm_macros.svh"

    class rx_agent extends uvm_agent;
        `uvm_component_utils(rx_agent)
        rx_config cfg;
        rx_driver driver;
        rx_input_monitor in_mon;
        rx_output_monitor out_mon;
        rx_sequencer sequencer;
        virtual rx_if vif;
        uvm_analysis_port #(rx_transaction) input_ap;
        uvm_analysis_port #(rx_transaction) output_ap;

        function new(string name = "rx_agent", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            input_ap = new("input_ap", this);
            output_ap = new("output_ap", this);
            cfg = rx_config::type_id::create("cfg", this);
            in_mon = rx_input_monitor::type_id::create("in_mon", this);
            out_mon = rx_output_monitor::type_id::create("out_mon", this);
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
            in_mon.cfg = cfg;
            out_mon.cfg = cfg;
            if(cfg.get_active() == UVM_ACTIVE) begin
                driver.cfg = cfg;
                driver.seq_item_port.connect(sequencer.seq_item_export);
            end
            in_mon.monitor_ap.connect(input_ap);
            out_mon.monitor_ap.connect(output_ap);
        endfunction
        
    endclass
endpackage

`endif