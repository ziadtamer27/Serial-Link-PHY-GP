`ifndef ALU_RANDOM_SEQUENCE_SV
`define ALU_RANDOM_SEQUENCE_SV

package alu_random_sequence_pkg;
    import uvm_pkg::*;
    import alu_transaction_pkg::*;
    `include "uvm_macros.svh"

    class alu_random_sequence extends uvm_sequence #(alu_transaction);
        `uvm_object_utils(alu_random_sequence)
        function new(string name = "alu_random_sequence");
            super.new(name);
        endfunction

        task body();
            alu_transaction tr;
            repeat(1000) begin
                tr = alu_transaction::type_id::create("tr");
                start_item(tr);
                assert(tr.randomize())
                else $fatal(1,"Randomization failed");
                finish_item(tr);
            end
        endtask
    endclass
endpackage

`endif