package ser_env;
`include "uvm_macros.svh"
import uvm_pkg::*;
import ser_agent::*;
import ser_scoreboard::*;
import ser_seq_item::*;
import ser_coverage::*;

class ser_env extends uvm_env;
`uvm_component_utils(ser_env);
ser_agent agent;
ser_scoreboard scoreboard;
ser_coverage coverage;

function new(string name="ser_env",uvm_component parent=null);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
agent=ser_agent::type_id::create("agent",this);
scoreboard=ser_scoreboard::type_id::create("scoreboard",this);
coverage=ser_coverage::type_id::create("coverage",this);
endfunction

function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
agent.agent_analysis_port.connect(scoreboard.sb_export);
agent.agent_analysis_port.connect(coverage.cov_export);
endfunction

endclass
endpackage