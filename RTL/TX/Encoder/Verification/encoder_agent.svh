`ifndef ENCODER_AGENT_SV
`define ENCODER_AGENT_SV
class encoder_agent extends uvm_agent;
    `uvm_component_utils(encoder_agent)
    encoder_config_obj cfg;
    encoder_driver driver;
    encoder_monitor monitor;
    encoder_sequencer sequencer;
    uvm_analysis_port #(encoder_seq_item) agt_ap;
    function new(string name = "encoder_agent", uvm_component parent = null);
        super.new(name, parent);
        agt_ap = new("agt_ap", this);
    endfunction
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(encoder_config_obj)::get(this, "", "cfg", cfg))
            `uvm_fatal("ENC_CFG", "Agent configuration is missing")
        uvm_config_db#(encoder_config_obj)::set(this, "*", "cfg", cfg);
        monitor = encoder_monitor::type_id::create("monitor", this);
        if (cfg.get_active() == UVM_ACTIVE) begin
            driver = encoder_driver::type_id::create("driver", this);
            sequencer = encoder_sequencer::type_id::create("sequencer", this);
        end
    endfunction
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        monitor.monitor_ap.connect(agt_ap);
        if (cfg.get_active() == UVM_ACTIVE)
            driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
endclass
`endif