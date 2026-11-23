`ifndef RX_CONFIG_SV
`define RX_CONFIG_SV

package rx_config_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class rx_config extends uvm_object;

        `uvm_object_utils(rx_config)
        virtual rx_if vif;
        uvm_active_passive_enum is_active;

        function new(string name = "rx_config");
            super.new(name);
            is_active = UVM_ACTIVE;
        endfunction

        function void set_vif(virtual rx_if vif);
            this.vif = vif;
        endfunction

        function virtual rx_if get_vif();
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