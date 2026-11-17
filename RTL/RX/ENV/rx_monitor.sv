`ifndef ALU_MONITOR_SV
`define ALU_MONITOR_SV

package alu_monitor_pkg;
    import uvm_pkg::*;
    import alu_config_pkg::*;
    import alu_transaction_pkg::*;
    `include "uvm_macros.svh"

    class alu_monitor extends uvm_monitor;
        `uvm_component_utils(alu_monitor)
        alu_config cfg;
        virtual alu_if vif;
        alu_transaction trans;
        uvm_analysis_port #(alu_transaction) monitor_ap;


        function new(string name = "alu_monitor", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            monitor_ap = new("mon_ap",this);
        endfunction

        task run_phase(uvm_phase phase);
            vif = cfg.get_vif();
            forever begin
                @(negedge vif.clk);
                trans = alu_transaction::type_id::create("trans");
                trans.A = vif.A;
                trans.B = vif.B;
                trans.shift_amt = vif.shift_amt;
                trans.AluControlout = vif.AluControlout;
                trans.Result = vif.Result;
                trans.overflow = vif.overflow;
                trans.ref_Result = vif.ref_Result;
                trans.ref_overflow = vif.ref_overflow;
                monitor_ap.write(trans);
            end
        endtask
    endclass
endpackage

`endif
