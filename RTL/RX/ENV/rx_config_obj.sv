`ifndef ALU_CONFIG_SV
`define ALU_CONFIG_SV

package alu_config_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class alu_config extends uvm_object;

        `uvm_object_utils(alu_config)
        virtual alu_if vif;
        uvm_active_passive_enum is_active;


        function new(string name = "alu_config");
            super.new(name);
            is_active = UVM_ACTIVE;
        endfunction

        function void set_vif(virtual alu_if vif);
            this.vif = vif;
        endfunction

        function virtual alu_if get_vif();
            return vif;
        endfunction

        function void set_active(uvm_active_passive_enum active);
            this.is_active = active;
        endfunction

        function uvm_active_passive_enum get_active();
            return is_active;
        endfunction

    endclass

endpackage

`endif