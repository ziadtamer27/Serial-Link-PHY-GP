`ifndef ENCODER_CONFIG_SV
`define ENCODER_CONFIG_SV

class encoder_config_obj extends uvm_object;

    `uvm_object_utils(encoder_config_obj)
    virtual encoder_if vif;
    uvm_active_passive_enum is_active;


    function new(string name = "encoder_config_obj");
        super.new(name);
        is_active = UVM_ACTIVE;
    endfunction

    function void set_vif(virtual encoder_if vif);
        this.vif = vif;
    endfunction

    function virtual encoder_if get_vif();
        return vif;
    endfunction

    function void set_active(uvm_active_passive_enum active);
        this.is_active = active;
    endfunction

    function uvm_active_passive_enum get_active();
        return is_active;
    endfunction

endclass


`endif