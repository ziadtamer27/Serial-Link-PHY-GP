package ser_monitor;
import uvm_pkg::*;
import ser_seq_item::*;
`include "uvm_macros.svh"

class ser_monitor extends uvm_monitor;
`uvm_component_utils(ser_monitor);

virtual ser_if ser_vif;
ser_seq_item mon_seq_item;
uvm_analysis_port#(ser_seq_item) mon_seq_item_port;

function new(string name="ser_monitor",uvm_component parent=null);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
mon_seq_item_port = new("mon_seq_item_port",this);
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);
forever begin
    @(ser_vif.mon_cb);
    mon_seq_item = ser_seq_item::type_id::create("mon_seq_item");
    mon_seq_item.rst_n = ser_vif.mon_cb.rst_n;
    mon_seq_item.parallel_data = ser_vif.mon_cb.parallel_data;
    mon_seq_item.serial_out = ser_vif.mon_cb.serial_out;
    mon_seq_item_port.write(mon_seq_item);
end
endtask
endclass
endpackage