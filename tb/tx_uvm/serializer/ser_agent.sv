package ser_agent;
`include "uvm_macros.svh"
import uvm_pkg::*;
import ser_driver::*;
import ser_sequencer::*;
import ser_monitor::*;
import ser_config::*;
import ser_seq_item::*;

class ser_agent extends uvm_agent;
`uvm_component_utils(ser_agent);
ser_driver driver;
ser_sequencer sequencer;
ser_monitor monitor;
ser_config cfg;
uvm_analysis_port#(ser_seq_item) agent_analysis_port;

function new(string name="ser_agent",uvm_component parent=null);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
if(!uvm_config_db#(ser_config)::get(this,"","cfg",cfg))
 `uvm_fatal("SER_AGENT","virtual interface must be set for ser_if");

driver=ser_driver::type_id::create("driver",this);
sequencer=ser_sequencer::type_id::create("sequencer",this);
monitor=ser_monitor::type_id::create("monitor",this);

agent_analysis_port = new("agent_analysis_port",this);
endfunction

function void connect_phase (uvm_phase phase);
super.connect_phase(phase);
driver.ser_vif = cfg.ser_vif;
monitor.ser_vif = cfg.ser_vif;
driver.seq_item_port.connect(sequencer.seq_item_export);
monitor.mon_seq_item_port.connect(agent_analysis_port);
endfunction
endclass
endpackage