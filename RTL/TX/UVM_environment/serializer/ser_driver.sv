package ser_driver;
import uvm_pkg::*;
import ser_config::*;
import ser_seq_item::*;
`include "uvm_macros.svh"

class ser_driver extends uvm_driver#(ser_seq_item);
`uvm_component_utils(ser_driver)

virtual ser_if ser_vif;
ser_seq_item seq_item;

function new(string name="ser_driver",uvm_component parent=null);
super.new(name,parent);
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);
forever begin
    seq_item_port.get_next_item(seq_item);
    @(ser_vif.drv_cb);
    ser_vif.drv_cb.rst_n <= seq_item.rst_n;
    ser_vif.drv_cb.parallel_data <= seq_item.parallel_data;
    seq_item_port.item_done();
end
endtask
endclass
endpackage