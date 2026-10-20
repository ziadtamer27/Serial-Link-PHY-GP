package ser_scoreboard;
import uvm_pkg::*;
import ser_seq_item::*;
`include "uvm_macros.svh"

class ser_scoreboard extends uvm_scoreboard;
`uvm_component_utils(ser_scoreboard);

uvm_analysis_export#(ser_seq_item) sb_export;
uvm_tlm_analysis_fifo#(ser_seq_item) sb_fifo;
ser_seq_item sb_seq_item;

int correct_count, error_count;

function new(string name="ser_scoreboard",uvm_component parent=null);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
sb_export = new("sb_export",this);
sb_fifo = new("sb_fifo",this);
endfunction

function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
sb_export.connect(sb_fifo.analysis_export);
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);
// 
endtask

function void report_phase(uvm_phase phase);
// 
endfunction

endclass
endpackage