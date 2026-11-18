`ifndef ALU_SHIFT_SEQUENCE_SV
`define ALU_SHIFT_SEQUENCE_SV

package alu_shift_sequence_pkg;

    import uvm_pkg::*;
    import alu_transaction_pkg::*;
    `include "uvm_macros.svh"

    class alu_shift_sequence extends uvm_sequence #(alu_transaction);

        `uvm_object_utils(alu_shift_sequence)

        function new(string name = "alu_shift_sequence");
            super.new(name);
        endfunction

        task body();

            alu_transaction tr;

            // sll
            repeat(100) begin

                tr = alu_transaction::type_id::create("tr");

                start_item(tr);

                assert(tr.randomize() with {
                    AluControlout == 4'd15;
                    shift_amt inside {0,1,15,16,30,31};
                });

                finish_item(tr);

            end

            // srl
            repeat(100) begin

                tr = alu_transaction::type_id::create("tr");

                start_item(tr);

                assert(tr.randomize() with {
                    AluControlout == 4'd13;
                    shift_amt inside {0,1,15,16,30,31};
                });

                finish_item(tr);

            end

            // sra
            repeat(100) begin

                tr = alu_transaction::type_id::create("tr");

                start_item(tr);

                assert(tr.randomize() with {
                    AluControlout == 4'd14;
                    shift_amt inside {0,1,15,16,30,31};
                });

                finish_item(tr);

            end

        endtask

    endclass

endpackage

`endif