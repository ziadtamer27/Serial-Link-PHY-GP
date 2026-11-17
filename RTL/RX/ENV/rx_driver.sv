`ifndef ALU_DRIVER_SV
`define ALU_DRIVER_SV

package alu_driver_pkg;
    import uvm_pkg::*;
    import alu_config_pkg::*;
    import alu_transaction_pkg::*;
    `include "uvm_macros.svh"

    class alu_driver extends uvm_driver #(alu_transaction);
        `uvm_component_utils(alu_driver)
        alu_config cfg;
        virtual alu_if vif;
        function new(string name = "alu_driver", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        task run_phase(uvm_phase phase);
            alu_transaction tr;
            vif = cfg.get_vif();
            forever begin
                @(posedge vif.clk);
                seq_item_port.get_next_item(tr);
                vif.A <= tr.A;
                vif.B <= tr.B;
                vif.shift_amt <= tr.shift_amt;
                vif.AluControlout <= tr.AluControlout;
                seq_item_port.item_done();
            end
        endtask
    endclass
endpackage

`endif