package ser_config;
import uvm_pkg::*;
`include "uvm_macros.svh";
class ser_config extends uvm_object;
    `uvm_object_utils(ser_config)
    virtual ser_if ser_vif;

    function new(string name="ser_config");
        super.new(name);
    endfunction
    endclass
endpackage