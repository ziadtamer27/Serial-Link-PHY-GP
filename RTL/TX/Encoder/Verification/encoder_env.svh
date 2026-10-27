`ifndef ENCODER_ENV_SV
`define ENCODER_ENV_SV
class encoder_env extends uvm_env;
    `uvm_component_utils(encoder_env)
    encoder_config_obj cfg;
    encoder_agent agt;
    encoder_scoreboard sb;
    encoder_coverage cov;
    function new(string name = "encoder_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    function void build_phase(uvm_phase phase);
        virtual encoder_if vif;
        super.build_phase(phase);
        if (!uvm_config_db#(encoder_config_obj)::get(this, "", "cfg", cfg))
            cfg = encoder_config_obj::type_id::create("cfg");
        if (cfg.get_vif() == null) begin
            if (!uvm_config_db#(virtual encoder_if)::get(this, "", "ENC_IF", vif))
                `uvm_fatal("ENC_IF", "Virtual encoder interface is missing")
            cfg.set_vif(vif);
        end
        uvm_config_db#(encoder_config_obj)::set(this, "agt", "cfg", cfg);
        agt = encoder_agent::type_id::create("agt", this);
        sb = encoder_scoreboard::type_id::create("sb", this);
        cov = encoder_coverage::type_id::create("cov", this);
    endfunction
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agt.agt_ap.connect(sb.sb_export);
        agt.agt_ap.connect(cov.cvr_export);
    endfunction
endclass
`endif