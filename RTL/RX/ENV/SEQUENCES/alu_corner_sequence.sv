`ifndef ALU_CORNER_SEQUENCE_SV
`define ALU_CORNER_SEQUENCE_SV

package alu_corner_sequence_pkg;

    import uvm_pkg::*;
    import alu_transaction_pkg::*;
    `include "uvm_macros.svh"

    class alu_corner_sequence extends uvm_sequence #(alu_transaction);

        `uvm_object_utils(alu_corner_sequence)

        function new(string name = "alu_corner_sequence");
            super.new(name);
        endfunction

        task body();

            alu_transaction tr;

            // 0
            repeat(50) begin

                tr = alu_transaction::type_id::create("tr");

                start_item(tr);

                assert(tr.randomize() with {
                    A == 32'sd0;
                    B == 32'sd0;
                });

                finish_item(tr);

            end

            // max positive
            repeat(50) begin

                tr = alu_transaction::type_id::create("tr");

                start_item(tr);

                assert(tr.randomize() with {
                    A == 32'sh7FFFFFFF;
                    B == 32'sh7FFFFFFF;
                });

                finish_item(tr);

            end

            // min negative
            repeat(50) begin

                tr = alu_transaction::type_id::create("tr");

                start_item(tr);

                assert(tr.randomize() with {
                    A == 32'sh80000000;
                    B == 32'sh80000000;
                });

                finish_item(tr);

            end

            // A = 0, B = MAX
            repeat(50) begin

                tr = alu_transaction::type_id::create("tr");

                start_item(tr);

                assert(tr.randomize() with {
                    A == 32'sd0;
                    B == 32'sh7FFFFFFF;
                });

                finish_item(tr);

            end

            // A = MAX, B = MIN
            repeat(50) begin

                tr = alu_transaction::type_id::create("tr");

                start_item(tr);

                assert(tr.randomize() with {
                    A == 32'sh7FFFFFFF;
                    B == 32'sh80000000;
                });

                finish_item(tr);

            end
            // try invalid alu control values
            repeat(50) begin

                tr = alu_transaction::type_id::create("tr");

                start_item(tr);

                assert(tr.randomize() with {
                    !(AluControlout inside {0,1,2,6,7,12,13,14,15});
                });

                finish_item(tr);

            end

        endtask

    endclass

endpackage

`endif