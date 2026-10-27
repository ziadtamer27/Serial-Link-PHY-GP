`ifndef ENCODER_MONITOR_SV
`define ENCODER_MONITOR_SV
class encoder_monitor extends uvm_monitor;
    `uvm_component_utils(encoder_monitor)
    encoder_config_obj cfg;
    virtual encoder_if vif;
    uvm_analysis_port #(encoder_seq_item) monitor_ap;
    function new(string name = "encoder_monitor", uvm_component parent = null);
        super.new(name, parent);
        monitor_ap = new("monitor_ap", this);
    endfunction
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(encoder_config_obj)::get(this, "", "cfg", cfg))
            `uvm_fatal("ENC_CFG", "Monitor configuration is missing")
        vif = cfg.get_vif();
    endfunction
    task run_phase(uvm_phase phase);
        encoder_seq_item tr;
        forever begin
            @(posedge vif.clk);
            tr = encoder_seq_item::type_id::create("observed_cycle");
            tr.rst_n = vif.rst_n;
            tr.in_valid = vif.in_valid;
            tr.in_data = vif.in_data;
            tr.in_is_k = vif.in_is_k;
            // Observe this edge's registered outputs after nonblocking updates.
            #1ns;
            tr.out_valid = vif.out_valid;
            tr.out_data = vif.out_data;
            tr.invalid_k = vif.invalid_k;
            tr.rd_positive = vif.rd_positive;
            monitor_ap.write(tr);
        end
    endtask
endclass
`endif